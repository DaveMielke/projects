# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=6
CROS_WORKON_COMMIT="64b4238ba8e4638d7ca75e0e1bab936e5a58429f"
CROS_WORKON_TREE=("ea6e2e1b6bec83695699ef78cec2f03321d97dd7" "286aebf05e21184e060f315519b20a2e0b6f96f3" "1838613d856f62da1bb0848ae0d75163013e6c14" "dc1506ef7c8cfd2c5ffd1809dac05596ec18773c")
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
