# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT=("a07b8addd62474da79a8950525c4e0cfaf3d41a9" "eec6d0a6c3962e71e3b1a7db2dfaa422ec88a15e")
CROS_WORKON_TREE=("6589055d0d41e7fc58d42616ba5075408d810f7d" "d94cdb151aea508d3de25b3bbe9f7647aef5886f" "1d995a5f11b89f06713e6b213ea3f8741ace4008")
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
	"build android"
	"common-mk"
)
PLATFORM_GYP_FILE="android/libcamera_client/libcamera_client.gyp"

inherit cros-camera cros-workon

DESCRIPTION="Android libcamera_client"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	!media-libs/arc-camera3-libcamera_client
	media-libs/cros-camera-libcamera_metadata"

DEPEND="${RDEPEND}
	media-libs/cros-camera-android-headers"

src_unpack() {
	cros-camera_src_unpack
}

src_install() {
	local INCLUDE_DIR="/usr/include/android"
	local LIB_DIR="/usr/$(get_libdir)"
	local SRC_DIR="android/libcamera_client"

	dolib.so "${OUT}/lib/libcamera_client.so"

	insinto "${INCLUDE_DIR}/camera"
	doins "${SRC_DIR}/include/camera"/*.h

	sed -e "s|@INCLUDE_DIR@|${INCLUDE_DIR}|" -e "s|@LIB_DIR@|${LIB_DIR}|" \
		"${SRC_DIR}/libcamera_client.pc.template" > \
		"${SRC_DIR}/libcamera_client.pc"
	insinto "${LIB_DIR}/pkgconfig"
	doins "${SRC_DIR}/libcamera_client.pc"
}
