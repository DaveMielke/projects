# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="6d9670b363e083d625fab9223e3373b6c96d0c2b"
CROS_WORKON_TREE="81155845efc5f33c1e2bfb5549bf53eb09517775"
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
	input_devices_st
	input_devices_weida
"

RDEPEND="
	input_devices_synaptics? ( chromeos-base/rmi4utils )
	input_devices_wacom? ( chromeos-base/wacom_fw_flash )
	input_devices_st? ( chromeos-base/st_flash )
	input_devices_weida? ( chromeos-base/weida_wdt_util )
	sys-apps/mosys
"

src_install() {
	exeinto "/opt/google/touch/scripts"
	doexe scripts/*.sh

	if [ -d "policies/${ARCH}" ]; then
		insinto "/opt/google/touch/policies"
		doins policies/${ARCH}/*.policy
	fi
}
