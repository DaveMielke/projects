# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_COMMIT="c0f14404e8270b5987726ea090950ee50db02348"
CROS_WORKON_TREE="bc2348a4d6692d35c2a9b5cc3e7d8d5cfc5faad9"
CROS_WORKON_PROJECT="chromiumos/third_party/sis-updater"

inherit cros-workon cros-common.mk libchrome udev user

DESCRIPTION="A tool to update SiS firmware on Mimo from Chromium OS."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/third_party/sis-updater"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

DEPEND="chromeos-base/libbrillo:="

RDEPEND="${DEPEND}"

src_install() {
	dosbin "${OUT}/sis-updater"
	udev_dorules conf/99-sis-usb.rules
}

pkg_preinst() {
	enewuser cfm-firmware-updaters
	enewgroup cfm-firmware-updaters
}