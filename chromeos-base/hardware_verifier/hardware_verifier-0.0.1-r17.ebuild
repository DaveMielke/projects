# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=6

CROS_WORKON_COMMIT="069f2a92133ad5b96ec25ee8c150344666b7ebad"
CROS_WORKON_TREE=("3203fc5c38912e1d0625e33126a801b6ae1a0c59" "f6f6a80edc913e2e5845bf2f30dea4abc3d75060" "dc1506ef7c8cfd2c5ffd1809dac05596ec18773c")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk hardware_verifier .gn"

PLATFORM_SUBDIR="hardware_verifier"

inherit cros-workon platform

DESCRIPTION="Hardware Verifier Tool/Lib for Chrome OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/hardware_verifier/"

LICENSE="BSD-Google"
SLOT=0
KEYWORDS="*"

RDEPEND="
	chromeos-base/libbrillo:=
"
DEPEND="
	${RDEPEND}
	chromeos-base/system_api
	chromeos-base/vboot_reference
"

src_install() {
	dobin "${OUT}/hardware_verifier"
}

platform_pkg_test() {
	platform_test "run" "${OUT}/unittest_runner"
}
