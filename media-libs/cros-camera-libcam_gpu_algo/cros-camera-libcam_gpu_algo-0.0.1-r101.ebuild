# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=6

CROS_WORKON_COMMIT="25ce3550a14c5075b1438527a8ae161bdcba1edd"
CROS_WORKON_TREE=("e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb" "d58be6324ba2a1d0452d23bafb39c869c5ed2cd6" "c2ced182d7894b403bf8a240c443858bc98ffc99" "584f7cc8998d8fa6c9b041054ce4a352016f477a" "7df66f898dfe1a70a7d79878e16378ce37cf6996")
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="../platform2"
CROS_WORKON_SUBTREE=".gn camera/build camera/common camera/include common-mk"
CROS_WORKON_OUTOFTREE_BUILD="1"
CROS_WORKON_INCREMENTAL_BUILD="1"

PLATFORM_SUBDIR="camera/common/libcam_gpu_algo"

inherit cros-camera cros-workon platform

DESCRIPTION="Chrome OS camera GPU algorithm library."

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND=""

DEPEND="${RDEPEND}"

src_install() {
	dolib.so "${OUT}/lib/libcam_gpu_algo.so"

	insinto /etc/init
	doins ../init/cros-camera-gpu-algo.conf

	insinto "/usr/share/policy"
	newins "../cros-camera-gpu-algo-${ARCH}.policy" cros-camera-gpu-algo.policy
}
