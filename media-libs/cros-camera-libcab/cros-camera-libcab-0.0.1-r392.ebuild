# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="19d1bda232a0c8131bcdec40928510da75c29864"
CROS_WORKON_TREE=("e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb" "d58be6324ba2a1d0452d23bafb39c869c5ed2cd6" "1a09c812bb71c011b30f99f188c1fc7c39fc2f4c" "d08b0de17491f94bdaf6aa7564df6f074fb18383" "84441b28a7584715021e2faf292e0cf5864ea8bf" "cf397e9600a0b2d153f579c58419577cfca75ab7")
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="../platform2"
CROS_WORKON_SUBTREE=".gn camera/build camera/common camera/include camera/mojo common-mk"
CROS_WORKON_OUTOFTREE_BUILD="1"
CROS_WORKON_INCREMENTAL_BUILD="1"

PLATFORM_SUBDIR="camera/common/libcab"

inherit cros-camera cros-workon platform

DESCRIPTION="Camera algorithm bridge library for proprietary camera algorithm
isolation"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="camera_feature_portrait_mode ihd_cmrtlib"

RDEPEND="
	!media-libs/arc-camera3-libcab
	camera_feature_portrait_mode? ( media-libs/cros-camera-libcam_gpu_algo )
	media-libs/cros-camera-libcamera_common
	media-libs/cros-camera-libcamera_ipc"

DEPEND="${RDEPEND}"

src_install() {
	dobin "${OUT}/cros_camera_algo"

	dolib.a "${OUT}/libcab.pic.a"

	cros-camera_doheader ../../include/cros-camera/camera_algorithm.h \
		../../include/cros-camera/camera_algorithm_bridge.h

	cros-camera_dopc ../libcab.pc.template

	insinto /etc/init
	doins ../init/cros-camera-algo.conf

	insinto /etc/dbus-1/system.d
	doins ../dbus/CrosCameraAlgo.conf

	insinto "/usr/share/policy"
	newins "../cros-camera-algo-${ARCH}.policy" cros-camera-algo.policy

	# The sandboxed GPU service runs the camera GPU algorithm library and
	# the CMRT library.
	if use camera_feature_portrait_mode || use ihd_cmrtlib ; then
		insinto /etc/init
		doins ../init/cros-camera-gpu-algo.conf

		insinto "/usr/share/policy"
		newins "../cros-camera-gpu-algo-${ARCH}.policy" cros-camera-gpu-algo.policy
	fi
}