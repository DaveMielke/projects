# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT=("44c34946304cef80bc0335e3bd941b6b77dad83e" "25a5cbf24eda611a7c4a09d69733ef8758f02f28")
CROS_WORKON_TREE=("6589055d0d41e7fc58d42616ba5075408d810f7d" "469e9d0e025291b19f7d53e76b4544fc494e5326" "155980e1c2bd87fc6639347a774cfa3858c96903" "bfef2802b8fc411b9769b3112b451ad72ae0de7f" "6f3635a6f5b0951a7ffdebd896518c01b04cc21b")
CROS_WORKON_PROJECT=(
	"chromiumos/platform/arc-camera"
	"chromiumos/platform2"
)
CROS_WORKON_LOCALNAME=(
	"../platform/arc-camera"
	"../platform2"
)
CROS_WORKON_DESTDIR=(
	"${S}/platform/arc-camera"
	"${S}/platform2"
)
CROS_WORKON_SUBTREE=(
	"build common include mojo"
	"common-mk"
)
PLATFORM_GYP_FILE="common/libcamera_jpeg.gyp"

inherit cros-camera cros-workon

DESCRIPTION="Chrome OS camera HAL software JPEG compressor util."

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	!media-libs/arc-camera3-libcamera_jpeg
	media-libs/cros-camera-libcamera_common
	virtual/jpeg:0"

DEPEND="${RDEPEND}
	chromeos-base/libmojo
	media-libs/cros-camera-libcamera_ipc
	media-libs/libyuv
	virtual/pkgconfig"

src_unpack() {
	cros-camera_src_unpack
}

src_install() {
	dolib.so "${OUT}/lib/libcamera_jpeg.so"

	cros-camera_doheader include/cros-camera/jpeg_compressor.h

	cros-camera_dopc common/libcamera_jpeg.pc.template
}
