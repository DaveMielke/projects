# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/coreutils/coreutils-8.22.ebuild,v 1.3 2014/01/17 04:23:16 vapier Exp $

EAPI="3"

inherit eutils flag-o-matic toolchain-funcs

PATCH_VER="1.0"
DESCRIPTION="Standard GNU file utilities (chmod, cp, dd, dir, ls...), text utilities (sort, tr, head, wc..), and shell utilities (whoami, who,...)"
HOMEPAGE="http://www.gnu.org/software/coreutils/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.xz
	mirror://gentoo/${P}-patches-${PATCH_VER}.tar.xz
	http://dev.gentoo.org/~vapier/dist/${P}-patches-${PATCH_VER}.tar.xz
	mirror://gentoo/${P}-man.tar.xz
	http://dev.gentoo.org/~vapier/dist/${P}-man.tar.xz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"
IUSE="acl caps gmp multicall nls selinux static userland_BSD vanilla xattr"

LIB_DEPEND="acl? ( sys-apps/acl[static-libs] )
	caps? ( sys-libs/libcap )
	gmp? ( dev-libs/gmp[static-libs] )
	xattr? ( !userland_BSD? ( sys-apps/attr[static-libs] ) )"
RDEPEND="!static? ( ${LIB_DEPEND//\[static-libs]} )
	selinux? ( sys-libs/libselinux )
	nls? ( virtual/libintl )
	!app-misc/realpath
	!<sys-apps/util-linux-2.13
	!sys-apps/stat
	!net-mail/base64
	!sys-apps/mktemp
	!<app-forensics/tct-1.18-r1
	!<net-fs/netatalk-2.0.3-r4
	!<sci-chemistry/ccp4-6.1.1"
DEPEND="${RDEPEND}
	static? ( ${LIB_DEPEND} )
	app-arch/xz-utils"

src_prepare() {
	if ! use vanilla ; then
		use_if_iuse unicode || rm -f "${WORKDIR}"/patch/000_all_coreutils-i18n.patch
		EPATCH_SUFFIX="patch" \
		PATCHDIR="${WORKDIR}/patch" \
		EPATCH_EXCLUDE="001_all_coreutils-gen-progress-bar.patch" \
		epatch

		# Single-binary patches.
		epatch "${FILESDIR}/${P}-single-binary.patch"

		# Since we modified configure.ac and some .mk we need to rerun autoreconf,
		# but can't do this on a system where coreutils is not installed yet, since
		# autoconf and some of the files we need to generate rely on these tools.
		# Instead, we patch the files with the output of an autoreconf run and
		# touch some dependencies in order to avoid the Makefile to attempt
		# regenerating them.
		epatch "${FILESDIR}/${P}-single-binary-autoreconf.patch"

		# coreutils Makefile includes dependencies used by developpers to rerun
		# autoconf, automake or configure when the required files change. Avoid
		# running autoreconf by touching the dependencies in order.
		touch config.status
		touch m4/cu-progs.m4
		touch aclocal.m4
		touch src/cu-progs.mk
		touch src/single-binary.mk
		touch Makefile.in
	fi

	# Since we've patched many .c files, the make process will try to
	# re-build the manpages by running `./bin --help`.  When doing a
	# cross-compile, we can't do that since 'bin' isn't a native bin.
	# Also, it's not like we changed the usage on any of these things,
	# so let's just update the timestamps and skip the help2man step.
	set -- man/*.x
	touch ${@/%x/1}

	# Avoid perl dep for compiled in dircolors default #348642
	if ! has_version dev-lang/perl ; then
		touch src/dircolors.h
		touch ${@/%x/1}
	fi
}

src_configure() {
	local myconf=''
	if tc-is-cross-compiler && [[ ${CHOST} == *linux* ]] ; then
		export fu_cv_sys_stat_statfs2_bsize=yes #311569
		export gl_cv_func_realpath_works=yes #416629
	fi

	export gl_cv_func_mknod_works=yes #409919
	use static && append-ldflags -static && sed -i '/elf_sys=yes/s:yes:no:' configure #321821
	use selinux || export ac_cv_{header_selinux_{context,flash,selinux}_h,search_setfilecon}=no #301782
	use userland_BSD && myconf="${myconf} -program-prefix=g --program-transform-name=s/stat/nustat/"
	# kill/uptime - procps
	# groups/su   - shadow
	# hostname    - net-tools
	econf \
		--with-packager="Gentoo" \
		--with-packager-version="${PVR} (p${PATCH_VER:-0})" \
		--with-packager-bug-reports="http://bugs.gentoo.org/" \
		--enable-install-program="arch" \
		--enable-no-install-program="groups,hostname,kill,su,uptime" \
		--enable-largefile \
		$(use caps || echo --disable-libcap) \
		$(use_enable multicall single-binary shebangs) \
		$(use_enable nls) \
		$(use_enable acl) \
		$(use_enable xattr) \
		$(use_with gmp) \
		${myconf}
}

src_test() {
	# Non-root tests will fail if the full path isnt
	# accessible to non-root users
	chmod -R go-w "${WORKDIR}"
	chmod a+rx "${WORKDIR}"

	# coreutils tests like to do `mount` and such with temp dirs
	# so make sure /etc/mtab is writable #265725
	# make sure /dev/loop* can be mounted #269758
	mkdir -p "${T}"/mount-wrappers
	mkwrap() {
		local w ww
		for w in "$@" ; do
			ww="${T}/mount-wrappers/${w}"
			cat <<-EOF > "${ww}"
				#!${EPREFIX}/bin/sh
				exec env SANDBOX_WRITE="\${SANDBOX_WRITE}:/etc/mtab:/dev/loop" $(type -P $w) "\$@"
			EOF
			chmod a+rx "${ww}"
		done
	}
	mkwrap mount umount

	addwrite /dev/full
	#export RUN_EXPENSIVE_TESTS="yes"
	#export FETISH_GROUPS="portage wheel"
	env PATH="${T}/mount-wrappers:${PATH}" \
	emake -j1 -k check || die "make check failed"
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc AUTHORS ChangeLog* NEWS README* THANKS TODO

	insinto /etc
	newins src/dircolors.hin DIR_COLORS || die

	if [[ ${USERLAND} == "GNU" ]] ; then
		cd "${ED}"/usr/bin
		dodir /bin
		if use multicall; then
			# move the coreutils single binary to /bin but keep a
			# symlink from here.
			mv coreutils ../../bin/ || die "could not move coreutils bin"
			ln -s ../../bin/coreutils coreutils || die "could not symlink coreutils bin"
		fi
		# move critical binaries into /bin (required by FHS)
		local fhs="cat chgrp chmod chown cp date dd df echo false ln ls
		           mkdir mknod mv pwd rm rmdir stty sync true uname"
		mv ${fhs} ../../bin/ || die "could not move fhs bins"
		# move critical binaries into /bin (common scripts)
		local com="basename chroot cut dir dirname du env expr head mkfifo
		           mktemp readlink seq sleep sort tail touch tr tty vdir wc yes"
		mv ${com} ../../bin/ || die "could not move common bins"
		# create a symlink for uname in /usr/bin/ since autotools require it
		local x
		for x in ${com} uname ; do
			dosym /bin/${x} /usr/bin/${x} || die
		done
	else
		# For now, drop the man pages, collides with the ones of the system.
		rm -rf "${ED}"/usr/share/man
	fi

}

pkg_postinst() {
	ewarn "Make sure you run 'hash -r' in your active shells."
	ewarn "You should also re-source your shell settings for LS_COLORS"
	ewarn "  changes, such as: source /etc/profile"

	# /bin/dircolors sometimes sticks around #224823
	if [ -e "${EROOT}/usr/bin/dircolors" ] && [ -e "${EROOT}/bin/dircolors" ] ; then
		if strings "${EROOT}/bin/dircolors" | grep -qs "GNU coreutils" ; then
			einfo "Deleting orphaned GNU /bin/dircolors for you"
			rm -f "${EROOT}/bin/dircolors"
		fi
	fi

	# Help out users using experimental filesystems
	if grep -qs btrfs "${EROOT}"/etc/fstab /proc/mounts ; then
		case $(uname -r) in
		2.6.[12][0-9]|2.6.3[0-7]*)
			ewarn "You are running a system with a buggy btrfs driver."
			ewarn "Please upgrade your kernel to avoid silent corruption."
			ewarn "See: https://bugs.gentoo.org/353907"
			;;
		esac
	fi
}
