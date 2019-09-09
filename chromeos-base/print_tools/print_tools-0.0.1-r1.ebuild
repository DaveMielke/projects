# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=6

CROS_WORKON_COMMIT="d7adfd0ae2fab317071fff4ab5406ca0cbea8a49"
CROS_WORKON_TREE=("fd02e6090c8f07ce200c4a4a20eefc55a064dc6d" "119baa60a30cacbbec8b56391df59ed696d7cf3f" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
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
SLOT="0"
KEYWORDS="*"

RDEPEND="
	chromeos-base/libbrillo:=
	chromeos-base/libipp:=
"

DEPEND="${RDEPEND}"

src_install() {
	dobin "${OUT}"/printer_diag
}
