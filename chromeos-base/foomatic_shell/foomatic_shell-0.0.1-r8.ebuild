# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="10cb5439e0fb4c84150942916eade924c6d72719"
CROS_WORKON_TREE=("dd4323fe3640909500f29f7acde8c0868024c48a" "3f76f020569718d57c680d94f2164775b57da9cd" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk foomatic_shell .gn"

PLATFORM_SUBDIR="foomatic_shell"

inherit cros-workon platform

DESCRIPTION="Mini shell used by foomatic-rip to execute scripts in PPD files."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/HEAD/foomatic_shell/"

LICENSE="BSD-Google"
KEYWORDS="*"

src_install() {
	dobin "${OUT}/foomatic_shell"

	# Install fuzzer
	platform_fuzzer_install "${S}"/OWNERS "${OUT}"/foomatic_shell_fuzzer
}

platform_pkg_test() {
	platform_test "run" "${OUT}/foomatic_shell_test"
}