# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=6

CROS_WORKON_COMMIT="75c3edc9dd613456c88f7a77fb793f908d4e7f3c"
CROS_WORKON_TREE=("c9338e2c2e898e065dce6d62921e358a85709cd3" "3bbe916b9bcd9a980b5fa7abc76e36393a43f8b3" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
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
