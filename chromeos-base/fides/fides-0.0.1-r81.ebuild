# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="8006a813c5d0f518dc2e69d1822ecb944cbb3cff"
CROS_WORKON_TREE="adb2d8134fcb5179b65c31166fe222eab45bf075"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="fides"

inherit cros-workon libchrome platform

DESCRIPTION="Device Configuration Management Services"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
SLOT=0
KEYWORDS="*"

DEPEND="
	test? ( dev-cpp/gtest )
"

platform_pkg_test() {
	local tests=(
		fides_testrunner
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}
