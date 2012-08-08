# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="a6b034dedfb1109adcd88eb1bcea15a29067824c"
CROS_WORKON_TREE="3a622455dbd0d057415214ed8f9a0f32ca139f8b"

EAPI=2
CROS_WORKON_PROJECT="chromiumos/platform/minijail"

inherit cros-debug cros-workon toolchain-funcs

DESCRIPTION="Chrome OS helper binary for restricting privs of services."
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="test"

RDEPEND="sys-libs/libcap"
DEPEND="test? ( dev-cpp/gtest )
	test? ( dev-cpp/gmock )
	${RDEPEND}"

CROS_WORKON_LOCALNAME=$(basename ${CROS_WORKON_PROJECT})

src_compile() {
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	cros-debug-add-NDEBUG
	export CCFLAGS="$CFLAGS"

	# Only build the tools
	emake LIBDIR=$(get_libdir) || die
}

src_test() {
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	cros-debug-add-NDEBUG
	export CCFLAGS="$CFLAGS"

	# TODO(wad) switch to common.mk to get qemu and valgrind coverage
	emake libminijail_unittest || die "libminijail_unittest compile failed."
	if use x86 || use amd64 ; then
		./libminijail_unittest  || \
		    die "unit tests failed!"
	fi

	emake syscall_filter_unittest || die "syscall_filter_unittest compile failed."
	if use x86 || use amd64 ; then
		./syscall_filter_unittest || \
		    die "syscall filter unit tests failed!"
	fi
}

src_install() {
	into /
	dosbin minijail0 || die
	dolib.so libminijail.so || die
	dolib.so libminijailpreload.so || die
	insinto /usr/include/chromeos
	doins libminijail.h || die
}
