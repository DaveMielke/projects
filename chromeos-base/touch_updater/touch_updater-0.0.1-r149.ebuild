# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"
CROS_WORKON_COMMIT="998b2993ce74d750e4e749a50c2080abd5db702a"
CROS_WORKON_TREE="4b00e7b3a24ce2a519035f4f59775f8beb05a5a9"
CROS_WORKON_PROJECT="chromiumos/platform/touch_updater"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-workon user

DESCRIPTION="Touch firmware and config updater"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="input_devices_synaptics
	input_devices_wacom
	input_devices_etphidiap
	input_devices_st
	input_devices_st_touchscreen
	input_devices_weida
	input_devices_goodix
	input_devices_sis
	input_devices_pixart
	input_devices_g2touch
"

RDEPEND="
	input_devices_synaptics? ( chromeos-base/rmi4utils )
	input_devices_wacom? ( chromeos-base/wacom_fw_flash )
	input_devices_etphidiap? ( chromeos-base/etphidiap )
	input_devices_st? ( chromeos-base/st_flash )
	input_devices_st_touchscreen? ( sys-apps/st-touch-fw-updater )
	input_devices_weida? ( chromeos-base/weida_wdt_util )
	input_devices_goodix? ( chromeos-base/gdix_hid_firmware_update )
	input_devices_sis? ( chromeos-base/sisConsoletool )
	input_devices_pixart? ( chromeos-base/pixart_tpfwup )
	input_devices_g2touch? ( chromeos-base/g2update_tool )
	sys-apps/mosys
"

pkg_preinst() {
	if use input_devices_etphidiap || use input_devices_st_touchscreen; then
		enewgroup fwupdate-i2c
		enewuser fwupdate-i2c
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

}

src_install() {
	exeinto "/opt/google/touch/scripts"
	doexe scripts/*.sh

	if [ -d "policies/${ARCH}" ]; then
		insinto "/opt/google/touch/policies"
		doins policies/${ARCH}/*.policy
	fi
}
