# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

: ${CMAKE_MAKEFILE_GENERATOR:=ninja}
CMAKE_MIN_VERSION=3.7.0-r1
PYTHON_COMPAT=( python2_7 )

inherit cros-constants cmake-utils git-r3 llvm python-any-r1 toolchain-funcs

DESCRIPTION="The LLVM linker (link editor)"
HOMEPAGE="https://llvm.org/"
SRC_URI=""
EGIT_REPO_URI="${CROS_GIT_HOST_URL}/external/llvm.org/lld
	https://git.llvm.org/git/lld.git"

EGIT_COMMIT="e260fac81cb305498a823b059ba8279b520296cc" #r339371

LICENSE="UoI-NCSA"
SLOT="0"
KEYWORDS="*"
IUSE="llvm-next"
RDEPEND="sys-devel/llvm"
DEPEND="${RDEPEND}"

pick_cherries() {
	CHERRIES=""
	CHERRIES+=" fc72aa17367e33a63c9619ed351a06b3486f80f5" # r340802
	CHERRIES+=" 78c2274fad7c6bf14e7067ce941f95009e3eda4f" # r341870
	pushd "${S}" >/dev/null || die
	for cherry in ${CHERRIES}; do
		epatch "${FILESDIR}/cherry/${cherry}.patch"
	done
	popd >/dev/null || die
}

pick_next_cherries() {
	CHERRIES=""
	CHERRIES+=" fc72aa17367e33a63c9619ed351a06b3486f80f5" # r340802
	CHERRIES+=" 78c2274fad7c6bf14e7067ce941f95009e3eda4f" # r341870
	pushd "${S}" >/dev/null || die
	for cherry in ${CHERRIES}; do
		epatch "${FILESDIR}/cherry/${cherry}.patch"
	done
	popd >/dev/null || die
}

python_check_deps() {
	has_version "dev-python/lit[${PYTHON_USEDEP}]"
}

pkg_setup() {
	llvm_pkg_setup
}

src_unpack() {
	if use llvm-next && has_version --host-root 'sys-devel/llvm[llvm-next]'; then
		export EGIT_COMMIT="e260fac81cb305498a823b059ba8279b520296cc" #r339371
	fi

	git-r3_fetch
	git-r3_checkout
}

src_prepare() {
	if use llvm-next  && has_version --host-root 'sys-devel/llvm[llvm-next]'; then
		pick_next_cherries
	else
		pick_cherries
	fi
	epatch "${FILESDIR}"/lld-8.0-revert-r330869.patch
	epatch "${FILESDIR}"/lld-8.0-revert-r326242.patch
	epatch "${FILESDIR}"/lld-8.0-revert-r325849.patch
	epatch "${FILESDIR}/$PN-invoke-name.patch"
}
src_configure() {
	# HACK: This is a temporary hack to detect the c++ library used in libLLVM.so
	# lld needs to link with same library as llvm but there is no good way to find
	# that. So grep the libc++ usage and if not used link with libstdc++.
	# Remove this hack once everything is migrated to libc++.
	# https://crbug.com/801681
	if tc-is-clang; then
		if [[ -n $(scanelf -qN libc++.so.1 /usr/$(get_libdir)/libLLVM.so) ]]; then
			append-flags -stdlib=libc++
			append-ldflags -stdlib=libc++
		else
			append-flags -stdlib=libstdc++
			append-ldflags -stdlib=libstdc++
		fi
	fi
	# End HACK
	local mycmakeargs=(
		#-DBUILD_SHARED_LIBS=ON
		# TODO: fix detecting pthread upstream in stand-alone build
		-DPTHREAD_LIB='-lpthread'
	)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	local binpath="/usr/bin"
	mv "${D}${binpath}/lld" "${D}${binpath}/lld.real" || die
	exeinto "${binpath}"
	newexe "${FILESDIR}/ldwrapper" "lld" || die
}
