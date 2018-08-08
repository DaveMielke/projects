# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT=("778039ff8512a5dd53d8fa5b48ef5d3fa2ff6ce2" "f2e28a473ffbdd9f227d623165e74370d8b04bf1")
CROS_WORKON_TREE=("6589055d0d41e7fc58d42616ba5075408d810f7d" "dd5a971d6bd82822a20639b23956728f2e59c9c7" "15c6d2b3c8226508b7434556acbda449e788a508" "20ef8042a2b93c9cea9ec7eb8202ad6da6b3cd6c")
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
	"build common/v4l2_device include"
	"common-mk"
)
PLATFORM_GYP_FILE="common/v4l2_device/libcamera_v4l2_device.gyp"

inherit cros-camera cros-workon

DESCRIPTION="Chrome OS camera HAL v3 V4L2 device utility."

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND=""

DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_unpack() {
	cros-camera_src_unpack
}

src_install() {
	dolib.so "${OUT}/lib/libcamera_v4l2_device.so"

	cros-camera_doheader include/cros-camera/v4l2_device.h

	cros-camera_dopc common/v4l2_device/libcamera_v4l2_device.pc.template
}
