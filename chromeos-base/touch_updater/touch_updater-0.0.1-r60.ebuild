# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="28c19c464ae075a4d701f99606ffdf809b5036f5"
CROS_WORKON_TREE="beeac2860d617a55cca573db65c49d47e0943a6c"
CROS_WORKON_PROJECT="chromiumos/platform/touch_updater"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-workon

DESCRIPTION="Touch firmware and config updater"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="input_devices_synaptics
	input_devices_wacom
"

RDEPEND="
	input_devices_synaptics? ( chromeos-base/rmi4utils )
	input_devices_wacom? ( chromeos-base/wacom_fw_flash )
"
src_install() {
	insinto "/etc/init"
	doins "scripts/chromeos-touch-update.conf"

	exeinto "/opt/google/touch/scripts"
	doexe scripts/*.sh

	insinto "/opt/google/touch/policies"
	doins policies/*.policy
}
