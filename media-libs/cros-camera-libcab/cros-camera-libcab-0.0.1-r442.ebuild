# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="3c24751e7b54732387b6da5896a990a12a870e65"
CROS_WORKON_TREE=("e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb" "c920da127f686c434165b6056b1cd740f228df6b" "201db92dbc5645d9a9fb9b33e26a0e669f52577d" "85dcd31292e99125b2eb2744c83442e00dece79f" "7efb7c7abf456762653f85c43a01f05aae4fb7ee" "3f47c000ac2656a574bb06b430a66f6783c3842a")
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
IUSE="camera_feature_portrait_mode ipu6se"

RDEPEND="
	!media-libs/arc-camera3-libcab
	camera_feature_portrait_mode? ( media-libs/cros-camera-libcam_gpu_algo )
	media-libs/cros-camera-libcamera_common
	media-libs/cros-camera-libcamera_ipc"

DEPEND="${RDEPEND}"

src_install() {
	platform_src_install
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

	# The sandboxed GPU service is used by Portrait Mode feature and IPU6SE
	# camera HAL.
	if use camera_feature_portrait_mode || use ipu6se ; then
		insinto /etc/init
		doins ../init/cros-camera-gpu-algo.conf

		insinto "/usr/share/policy"
		newins "../cros-camera-gpu-algo-${ARCH}.policy" cros-camera-gpu-algo.policy
	fi
}