# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="18e9216a3aaef238718d0255a105ad56bd8c85ca"
CROS_WORKON_TREE="c6721f1b97ac1b6aafce3b23d79e97f41ba1663a"
CROS_WORKON_PROJECT="chromiumos/platform/arc-camera"
CROS_WORKON_LOCALNAME="../platform/arc-camera"

inherit cros-debug cros-workon libchrome toolchain-funcs

DESCRIPTION="Chrome OS camera HAL Jpeg compressor util."

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan"

RDEPEND="
	!media-libs/arc-camera3-libcamera_jpeg
	virtual/jpeg:0"

DEPEND="${RDEPEND}
	media-libs/libyuv
	virtual/pkgconfig"

src_configure() {
	asan-setup-env
	cros-workon_src_configure
}

src_compile() {
	cw_emake BASE_VER=${LIBCHROME_VERS} libcamera_jpeg
}

src_install() {
	local INCLUDE_DIR="/usr/include/cros-camera"
	local LIB_DIR="/usr/$(get_libdir)"

	dolib.a common/libcamera_jpeg.pic.a

	insinto "${INCLUDE_DIR}"
	doins include/cros-camera/jpeg_compressor.h

	sed -e "s|@INCLUDE_DIR@|${INCLUDE_DIR}|" -e "s|@LIB_DIR@|${LIB_DIR}|" \
		-e "s|@LIBCHROME_VERS@|${LIBCHROME_VERS}|" \
		common/libcamera_jpeg.pc.template > common/libcamera_jpeg.pc
	insinto "${LIB_DIR}/pkgconfig"
	doins common/libcamera_jpeg.pc
}
