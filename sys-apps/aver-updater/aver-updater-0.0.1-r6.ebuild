# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="8374074e70d8ae757ef44214b6d689055cd517af"
CROS_WORKON_TREE="67a0e9d7a478dfbc9ac7c32db055a89a2dcc9412"
CROS_WORKON_PROJECT="chromiumos/third_party/aver-updater"

inherit cros-workon libchrome udev user

DESCRIPTION="AVer firmware updater"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/third_party/aver-updater"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	chromeos-base/libbrillo
"

src_configure() {
	cros-workon_src_configure
}

src_install() {
	dosbin aver-updater
	udev_dorules conf/99-run-aver-updater.rules
}

pkg_preinst() {
	enewuser cfm-firmware-updaters
	enewgroup cfm-firmware-updaters
}
