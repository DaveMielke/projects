# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=6
CROS_WORKON_COMMIT="c1c151873f4d6e6157db75aa2bcf27d3ca8666f9"
CROS_WORKON_TREE=("1e8218a3d15868b67db7aac03b06e3d7de327778" "31a2d32fe782fa5833d0fd5c173174d3e9853e71" "dd8cdec7f4859621c43fd4840520725362694359" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_INCREMENTAL_BUILD=1
# TODO(dverkamp): shill should be removed once https://crbug.com/809389 is fixed.
CROS_WORKON_SUBTREE="common-mk portier shill .gn"

PLATFORM_SUBDIR="portier"

inherit cros-workon platform user

DESCRIPTION="ND Proxy Service for Chrome OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/portier"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	chromeos-base/libbrillo
"
DEPEND="
	${RDEPEND}
	>=chromeos-base/system_api-0.0.1-r3259
	chromeos-base/shill
"

platform_pkg_test() {
	local tests=(
		portier_test
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}

src_install() {
	dobin "${OUT}"/portier_cli
	dobin "${OUT}"/portierd
}
