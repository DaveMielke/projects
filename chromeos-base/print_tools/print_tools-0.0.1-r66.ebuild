# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="c8123fd2eaecdc280f375d67144f2019866fab16"
CROS_WORKON_TREE=("f089191a0d3d6b85e2d71b4dbba970e0fc4966e1" "e32b875ee8bdcd1ae46bae8619e4d00d4d03636c" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk print_tools .gn"

PLATFORM_SUBDIR="print_tools"

inherit cros-workon platform

DESCRIPTION="Various tools for the native printing system."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/print_tools/"

LICENSE="BSD-Google"
KEYWORDS="*"

COMMON_DEPEND="
	chromeos-base/libipp:=
"
RDEPEND="${COMMON_DEPEND}"
DEPEND="${COMMON_DEPEND}"

src_install() {
	dobin "${OUT}"/printer_diag
}