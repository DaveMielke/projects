# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

CROS_WORKON_COMMIT="11fcbabac44b7fd8c0adf6d1d665439f220041d2"
CROS_WORKON_TREE=("2a8b5e5d33f20cd70c9e7296e1e2a69a05f38164" "a1fe73d0411a7b197d9434d702f88969762c779c" "dc1506ef7c8cfd2c5ffd1809dac05596ec18773c")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk trim .gn"

PLATFORM_SUBDIR="trim"

inherit cros-workon platform

DESCRIPTION="Stateful partition periodic trimmer"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND=""

RDEPEND="${DEPEND}
	chromeos-base/chromeos-common-script
	chromeos-base/chromeos-init
	sys-apps/util-linux"

platform_pkg_test() {
	platform_test "run" "tests/chromeos-trim-test"
	platform_test "run" "tests/chromeos-do_trim-test"
}

src_install() {
	insinto "/etc/init"
	doins "init/trim.conf"

	insinto "/usr/share/cros"
	doins "share/trim_utils.sh"

	dosbin "scripts/chromeos-trim"
}
