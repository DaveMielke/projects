# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="4ad348fb1b8584680e10878c4bede8b83bd803fb"
CROS_WORKON_TREE="cc0d0ec4053f547c081b840001696d7f670998a2"
CROS_WORKON_PROJECT="chromiumos/platform/arc-camera"
CROS_WORKON_LOCALNAME="../platform/arc-camera"

inherit cros-debug cros-workon libchrome toolchain-funcs

DESCRIPTION="Test for camera algorithm bridge library"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	media-libs/arc-camera3-libcab"

DEPEND="${RDEPEND}"

src_compile() {
	tc-export CC CXX PKG_CONFIG
	cros-debug-add-NDEBUG
	emake BASE_VER=${LIBCHROME_VERS} libcab_test
}

src_install() {
	dobin common/libcab_test
	dolib common/libcam_algo.so
}
