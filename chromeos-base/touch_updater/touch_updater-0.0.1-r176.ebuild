# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"
CROS_WORKON_COMMIT="81beb6ce46fb3b3b68a76ebf0c41122a6ac721d2"
CROS_WORKON_TREE=("7b957ecc47f1c55e13cf2680cdd682e254f6b3b7" "e62369b9e0494a8cdc934cb52aa4e0161916d4d1")
CROS_WORKON_PROJECT="chromiumos/platform/touch_updater"
CROS_WORKON_SUBTREE="policies scripts"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-workon user

DESCRIPTION="Touch firmware and config updater"
HOMEPAGE="https://www.chromium.org/chromium-os"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="
	input_devices_synaptics
	input_devices_wacom
	input_devices_etphidiap
	input_devices_st
	input_devices_st_touchscreen
	input_devices_weida
	input_devices_goodix
	input_devices_sis
	input_devices_pixart
	input_devices_g2touch
	input_devices_cirque
	input_devices_elan_i2chid
	input_devices_melfas
"

# Third party firmware updaters usually belong in sys-apps/.  If you just
# checked in a new one to chromeos-base/, please move it to sys-apps/ before
# adding it as a dependency here.
RDEPEND="
	chromeos-base/chromeos-touch-common
	input_devices_synaptics? ( chromeos-base/rmi4utils )
	input_devices_wacom? ( chromeos-base/wacom_fw_flash )
	input_devices_etphidiap? ( chromeos-base/chromeos-touch-etphidiap )
	input_devices_st? ( chromeos-base/st_flash )
	input_devices_st_touchscreen? ( chromeos-base/chromeos-touch-stupdate )
	input_devices_weida? ( chromeos-base/weida_wdt_util )
	input_devices_goodix? ( chromeos-base/gdix_hid_firmware_update )
	input_devices_sis? ( chromeos-base/sisConsoletool )
	input_devices_pixart? ( chromeos-base/pixart_tpfwup )
	input_devices_g2touch? ( chromeos-base/g2update_tool )
	input_devices_cirque? ( chromeos-base/cirque_fw_update )
	input_devices_elan_i2chid? ( chromeos-base/elan_i2chid_tools )
	input_devices_melfas? ( chromeos-base/mfs-console-tool )
"

pkg_preinst() {
	if use input_devices_elan_i2chid || use input_devices_melfas; then
		enewgroup fwupdate-hidraw
		enewuser fwupdate-hidraw
	fi
	if use input_devices_sis; then
		enewgroup sisfwupdate
		enewuser sisfwupdate
	fi
	if use input_devices_pixart; then
		enewgroup pixfwupdate
		enewuser pixfwupdate
	fi
	if use input_devices_g2touch; then
		enewgroup g2touch
		enewuser g2touch
	fi
	if use input_devices_goodix; then
		enewgroup goodixfwupdate
		enewuser goodixfwupdate
	fi
	if use input_devices_cirque; then
		enewgroup cirque
		enewuser cirque
	fi
}

src_install() {
	exeinto "/opt/google/touch/scripts"
	doexe scripts/*.sh

	if [ -d "policies/${ARCH}" ]; then
		insinto "/opt/google/touch/policies"
		doins policies/${ARCH}/*.policy
	fi
}
