# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="12512426edb7099848235e15fc1fc27005df2364"
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
	chromeos-base/libchrome
	chromeos-base/libchromeos
	${RDEPEND}"

CROS_WORKON_LOCALNAME=$(basename ${CROS_WORKON_PROJECT})

src_compile() {
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	cros-debug-add-NDEBUG
	export CCFLAGS="$CFLAGS"

	# Only build the tool
	scons minijail || die "minijail compile failed."
}

src_test() {
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	cros-debug-add-NDEBUG
	export CCFLAGS="$CFLAGS"

	# Only build the tests
	# TODO(wad) eclass-ify this.
	scons minijail_unittests ||
		die "minijail_unittests compile failed."

	if use x86 ; then
		./minijail_unittests ${GTEST_ARGS} || \
		    die "unit tests (with ${GTEST_ARGS}) failed!"
	fi
}

src_install() {
        into /
        dosbin minijail || die
}
