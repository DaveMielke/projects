# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="63b51b8b9202b3963c87df283f49d53cf961ba98"
CROS_WORKON_TREE=("e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb" "d58be6324ba2a1d0452d23bafb39c869c5ed2cd6" "9a69029420ce9f63dca298cd60bfb34ed711f093" "4cc600d625ecfdac13d984d9190d63a8970b0a4b" "825512278f3738ba8ac7c5f167aacd4677cfebf7")
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="../platform2"
CROS_WORKON_SUBTREE=".gn camera/build camera/common camera/include common-mk"
CROS_WORKON_OUTOFTREE_BUILD="1"
CROS_WORKON_INCREMENTAL_BUILD="1"

PLATFORM_SUBDIR="camera/common/libcbm"
CROS_CAMERA_TESTS=(
	"cbm_unittest"
)

inherit cros-camera cros-workon platform

DESCRIPTION="Chrome OS camera HAL buffer manager."

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	!media-libs/arc-camera3-libcbm
	media-libs/minigbm
	x11-libs/libdrm"

DEPEND="${RDEPEND}
	media-libs/cros-camera-android-headers
	virtual/pkgconfig"

src_install() {
	dolib.so "${OUT}/lib/libcbm.so"

	cros-camera_doheader ../../include/cros-camera/camera_buffer_manager.h

	cros-camera_dopc ../libcbm.pc.template
}