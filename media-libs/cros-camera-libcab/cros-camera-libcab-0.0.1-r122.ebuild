# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT=("220de68e4c7f0138e87a53bedfe1129cf2fe93d0" "daf80917c9edbd0adcc90249bb009bbf48c85ee2")
CROS_WORKON_TREE=("6589055d0d41e7fc58d42616ba5075408d810f7d" "2b88e2d40e45bd1c25c2fcfadd905ae25672af5a" "155980e1c2bd87fc6639347a774cfa3858c96903" "bfef2802b8fc411b9769b3112b451ad72ae0de7f" "6f3635a6f5b0951a7ffdebd896518c01b04cc21b")
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
PLATFORM_GYP_FILE="common/libcab.gyp"

inherit cros-camera cros-workon

DESCRIPTION="Camera algorithm bridge library for proprietary camera algorithm
isolation"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	!media-libs/arc-camera3-libcab
	media-libs/cros-camera-libcamera_common"

DEPEND="${RDEPEND}
	chromeos-base/libmojo
	media-libs/cros-camera-libcamera_ipc"

src_unpack() {
	cros-camera_src_unpack
}

src_install() {
	dobin "${OUT}/cros_camera_algo"

	dolib.a "${OUT}/libcab.pic.a"

	cros-camera_doheader include/cros-camera/camera_algorithm.h \
		include/cros-camera/camera_algorithm_bridge.h

	cros-camera_dopc common/libcab.pc.template

	insinto /etc/init
	doins common/init/cros-camera-algo.conf

	insinto "/usr/share/policy"
	newins "common/cros-camera-algo-${ARCH}.policy" cros-camera-algo.policy
}
