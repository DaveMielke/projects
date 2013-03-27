# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/nss/nss-3.14.3.ebuild,v 1.11 2013/03/14 19:48:16 vapier Exp $

EAPI=3
inherit eutils flag-o-matic multilib toolchain-funcs

NSPR_VER="4.9.5"
RTM_NAME="NSS_${PV//./_}_RTM"

DESCRIPTION="Mozilla's Network Security Services library that implements PKI support"
HOMEPAGE="http://www.mozilla.org/projects/security/pki/nss/"
SRC_URI="ftp://ftp.mozilla.org/pub/mozilla.org/security/nss/releases/${RTM_NAME}/src/${P}.tar.gz"

LICENSE="|| ( MPL-2.0 GPL-2 LGPL-2.1 )"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 ~s390 ~sh sparc x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"

DEPEND="virtual/pkgconfig
	>=dev-libs/nspr-${NSPR_VER}"

RDEPEND=">=dev-libs/nspr-${NSPR_VER}
	>=dev-db/sqlite-3.5
	sys-libs/zlib
	!<app-crypt/nss-${PV}"

src_setup() {
	export LC_ALL="C"
}

src_prepare() {
	# Custom changes for gentoo
	epatch "${FILESDIR}/${PN}-3.14.1-gentoo-fixups-r1.patch"
	epatch "${FILESDIR}/${PN}-3.12.6-gentoo-fixup-warnings.patch"
	epatch "${FILESDIR}/${PN}-3.14.2-x32.patch"
	epatch "${FILESDIR}/${PN}-3.14.2-sqlite.patch"
	# Add a public API to set the certificate nickname (PKCS#11 CKA_LABEL
	# attribute). See http://crosbug.com/19403 for details.
	epatch "${FILESDIR}"/${PN}-3.14-chromeos-cert-nicknames.patch

	# Abort the process if /dev/urandom cannot be opened (eg: when sandboxed)
	# See http://crosbug.com/29623 for details.
	epatch "${FILESDIR}"/${PN}-3.14-abort-on-failed-urandom-access.patch

	cd "${S}"/mozilla/security/coreconf || die
	# hack nspr paths
	echo 'INCLUDES += -I$(DIST)/include/dbm' \
		>> headers.mk || die "failed to append include"

	# modify install path
	sed -e 's:SOURCE_PREFIX = $(CORE_DEPTH)/\.\./dist:SOURCE_PREFIX = $(CORE_DEPTH)/dist:' \
		-i source.mk || die

	# Respect LDFLAGS
	sed -i -e 's/\$(MKSHLIB) -o/\$(MKSHLIB) \$(LDFLAGS) -o/g' rules.mk || die

	# Ensure we stay multilib aware
	sed -i -e "s:gentoo\/nss:$(get_libdir):" "${S}"/mozilla/security/nss/config/Makefile || die "Failed to fix for multilib"

	# Fix pkgconfig file for Prefix
	sed -i -e "/^PREFIX =/s:= /usr:= ${EPREFIX}/usr:" \
		"${S}"/mozilla/security/nss/config/Makefile || die

	epatch "${FILESDIR}/nss-3.14.2-solaris-gcc.patch"

	# use host shlibsign if need be #436216
	if tc-is-cross-compiler ; then
		sed -i \
			-e 's:"${2}"/shlibsign:nssshlibsign:' \
			"${S}"/mozilla/security/nss/cmd/shlibsign/sign.sh || die
	fi

	# dirty hack
	cd "${S}"/mozilla/security/nss || die
	sed -i -e "/CRYPTOLIB/s:\$(SOFTOKEN_LIB_DIR):../freebl/\$(OBJDIR):" \
		lib/ssl/config.mk || die
	sed -i -e "/CRYPTOLIB/s:\$(SOFTOKEN_LIB_DIR):../../lib/freebl/\$(OBJDIR):" \
		cmd/platlibs.mk || die
}

nssarch() {
	# Most of the arches are the same as $ARCH
	local t=${1:-${CHOST}}
	case ${t} in
	hppa*)   echo "parisc";;
	i?86*)   echo "i686";;
	x86_64*) echo "x86_64";;
	*)       tc-arch ${t};;
	esac
}

nssbits() {
	local cc="${1}CC" cppflags="${1}CPPFLAGS" cflags="${1}CFLAGS"
	echo > "${T}"/test.c || die
	${!cc} ${!cppflags} ${!cflags} -c "${T}"/test.c -o "${T}"/test.o || die
	case $(file "${T}"/test.o) in
	*32-bit*x86-64*) echo USE_x32=1;;
	*64-bit*|*ppc64*|*x86_64*) echo USE_64=1;;
	*32-bit*|*ppc*|*i386*) ;;
	*) die "Failed to detect whether your arch is 64bits or 32bits, disable distcc if you're using it, please";;
	esac
}

src_compile() {
	strip-flags

	tc-export AR RANLIB {BUILD_,}{CC,PKG_CONFIG}
	local makeargs=(
		CC="${CC}"
		AR="${AR} rc \$@"
		RANLIB="${RANLIB}"
		OPTIMIZER=
		$(nssbits)
	)

	# Take care of nspr settings #436216
	append-cppflags $(${PKG_CONFIG} nspr --cflags)
	append-ldflags $(${PKG_CONFIG} nspr --libs-only-L)
	unset NSPR_INCLUDE_DIR
	export NSPR_LIB_DIR=${T}/fake-dir

	# Do not let `uname` be used.
	if use kernel_linux ; then
		makeargs+=(
			OS_TARGET=Linux
			OS_RELEASE=2.6
			OS_TEST="$(nssarch)"
		)
	fi

	export BUILD_OPT=1
	export NSS_USE_SYSTEM_SQLITE=1
	export NSDISTMODE=copy
	export NSS_ENABLE_ECC=1
	export XCFLAGS="${CFLAGS} ${CPPFLAGS}"
	export FREEBL_NO_DEPEND=1
	export ASFLAGS=""

	local d

	# Build the host tools first.
	LDFLAGS="${BUILD_LDFLAGS}" \
	XCFLAGS="${BUILD_CFLAGS}" \
	emake -j1 -C mozilla/security/coreconf \
		CC="${BUILD_CC}" \
		$(nssbits BUILD_) \
		|| die
	makeargs+=( NSINSTALL="${PWD}/$(find -type f -name nsinstall)" )

	# Then build the target tools.
	for d in dbm nss ; do
		emake -j1 "${makeargs[@]}" -C mozilla/security/${d} || die "${d} make failed"
	done
}

# Altering these 3 libraries breaks the CHK verification.
# All of the following cause it to break:
# - stripping
# - prelink
# - ELF signing
# http://www.mozilla.org/projects/security/pki/nss/tech-notes/tn6.html
# Either we have to NOT strip them, or we have to forcibly resign after
# stripping.
#local_libdir="$(get_libdir)"
#export STRIP_MASK="
#	*/${local_libdir}/libfreebl3.so*
#	*/${local_libdir}/libnssdbm3.so*
#	*/${local_libdir}/libsoftokn3.so*"

export NSS_CHK_SIGN_LIBS="freebl3 nssdbm3 softokn3"

generate_chk() {
	local shlibsign="$1"
	local libdir="$2"
	einfo "Resigning core NSS libraries for FIPS validation"
	shift 2
	local i
	for i in ${NSS_CHK_SIGN_LIBS} ; do
		local libname=lib${i}.so
		local chkname=lib${i}.chk
		"${shlibsign}" \
			-i "${libdir}"/${libname} \
			-o "${libdir}"/${chkname}.tmp \
		&& mv -f \
			"${libdir}"/${chkname}.tmp \
			"${libdir}"/${chkname} \
		|| die "Failed to sign ${libname}"
	done
}

cleanup_chk() {
	local libdir="$1"
	shift 1
	local i
	for i in ${NSS_CHK_SIGN_LIBS} ; do
		local libfname="${libdir}/lib${i}.so"
		# If the major version has changed, then we have old chk files.
		[ ! -f "${libfname}" -a -f "${libfname}.chk" ] \
			&& rm -f "${libfname}.chk"
	done
}

src_install() {
	cd "${S}"/mozilla/security/dist || die

	dodir /usr/$(get_libdir) || die
	cp -L */lib/*$(get_libname) "${ED}"/usr/$(get_libdir) || die "copying shared libs failed"
	# We generate these after stripping the libraries, else they don't match.
	#cp -L */lib/*.chk "${ED}"/usr/$(get_libdir) || die "copying chk files failed"
	cp -L */lib/libcrmf.a "${ED}"/usr/$(get_libdir) || die "copying libs failed"

	# Install nss-config and pkgconfig file
	dodir /usr/bin || die
	cp -L */bin/nss-config "${ED}"/usr/bin || die
	dodir /usr/$(get_libdir)/pkgconfig || die
	cp -L */lib/pkgconfig/nss.pc "${ED}"/usr/$(get_libdir)/pkgconfig || die

	# all the include files
	insinto /usr/include/nss
	doins public/nss/*.h || die
	cd "${ED}"/usr/$(get_libdir) || die

	local f nssutils
	# Always enabled because we need it for chk generation.
	nssutils="shlibsign"
	cd "${S}"/mozilla/security/dist/*/bin/ || die
	for f in $nssutils; do
		# TODO(cmasone): switch to normal nss tool names
		newbin ${f} nss${f}|| die
	done

	# Prelink breaks the CHK files. We don't have any reliable way to run
	# shlibsign after prelink.
	local l libs=()
	for l in ${NSS_CHK_SIGN_LIBS} ; do
		libs+=("${EPREFIX}/usr/$(get_libdir)/lib${l}.so")
	done
	OLD_IFS="${IFS}" IFS=":" ; liblist="${libs[*]}" ; IFS="${OLD_IFS}"
	echo -e "PRELINK_PATH_MASK=${liblist}" >"${T}/90nss" || die
	unset libs liblist
	doenvd "${T}/90nss" || die
}

pkg_postinst() {
	# We must re-sign the libraries AFTER they are stripped.
	local shlibsign="${EROOT}/usr/bin/nssshlibsign"
	# See if we can execute it (cross-compiling & such). #436216
	"${shlibsign}" -h >&/dev/null
	if [[ $? -gt 1 ]] ; then
		shlibsign="nssshlibsign"
	fi
	generate_chk "${shlibsign}" "${EROOT}"/usr/$(get_libdir)
}

pkg_postrm() {
	cleanup_chk "${EROOT}"/usr/$(get_libdir)
}
