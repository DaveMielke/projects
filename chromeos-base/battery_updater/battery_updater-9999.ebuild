# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_PROJECT="chromiumos/platform/battery_updater"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-workon

DESCRIPTION="Battery Firmware Updater"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/battery_updater/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0/0"
KEYWORDS="~*"
IUSE=""

src_install() {
	insinto "/etc/init"
	doins "scripts/chromeos-battery-update.conf"
	exeinto "/opt/google/battery/scripts"
	doexe scripts/chromeos-battery-update.sh
}
