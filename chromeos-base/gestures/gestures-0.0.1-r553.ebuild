# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="47a5cca80ce8f553c643b31ffe92bcc318f53f64"
CROS_WORKON_TREE="6f466cc3a86a1655c128d570cbe8bb51d3cf07f3"
CROS_WORKON_PROJECT="chromiumos/platform/gestures"
CROS_WORKON_USE_VCSID=1

inherit toolchain-funcs multilib cros-debug cros-workon

DESCRIPTION="Gesture recognizer library"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="-asan +X"

RDEPEND="chromeos-base/gestures-conf
	chromeos-base/libevdev
	dev-libs/jsoncpp
	virtual/udev"
DEPEND="dev-cpp/gtest
	X? ( x11-libs/libXi )
	${RDEPEND}"

# The last dir must be named "gestures" for include path reasons.
S="${WORKDIR}/gestures"

src_configure() {
	asan-setup-env
	cros-workon_src_configure
	export USE_X11=$(usex X 1 0)
}

src_compile() {
	tc-export CXX
	cros-debug-add-NDEBUG

	emake clean  # TODO(adlr): remove when a better solution exists
	emake
}

src_test() {
	emake test

	if ! use x86 && ! use amd64 ; then
		einfo "Skipping tests on non-x86 platform..."
	else
		./test || die
	fi
}

src_install() {
	emake DESTDIR="${D}" LIBDIR="/usr/$(get_libdir)" install
}
