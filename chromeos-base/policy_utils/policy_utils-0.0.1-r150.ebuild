# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="c882eb0676a3616226063eaae36fac199b80d3d8"
CROS_WORKON_TREE=("85e4e098023fcccb8851b45c351a7045fa23f06f" "bd13c84f484f05be0426fa99c88392099b9b64ee" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_SUBTREE="common-mk policy_utils .gn"

PLATFORM_SUBDIR="policy_utils"

inherit cros-workon platform

DESCRIPTION="Device-policy-management library and tool for Chrome OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/policy_utils/"

LICENSE="BSD-Google"
SLOT="0/0"
KEYWORDS="*"

COMMON_DEPEND="
"

DEPEND="
	${COMMON_DEPEND}
	chromeos-base/system_api
"

RDEPEND="
	${COMMON_DEPEND}
"

src_install() {
	dosbin "${OUT}/policy"
}

platform_pkg_test() {
	local tests=(
		libmgmt_test
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}