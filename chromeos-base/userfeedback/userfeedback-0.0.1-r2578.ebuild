# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="f3b6ea89cb33a1480ad131ebc0fc31d0c3f8f7ae"
CROS_WORKON_TREE="bfc47388fc593671fa83fef3eae1de05910ef11e"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_DESTDIR="${S}"

inherit cros-workon systemd

DESCRIPTION="Log scripts used by userfeedback to report cros system information"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="+mmc systemd X"

RDEPEND="chromeos-base/chromeos-init
	chromeos-base/chromeos-installer
	chromeos-base/crash-reporter
	chromeos-base/modem-utilities
	chromeos-base/vboot_reference
	media-libs/fontconfig
	media-sound/alsa-utils
	sys-apps/coreboot-utils
	sys-apps/hdparm
	mmc? ( sys-apps/mmc-utils )
	sys-apps/mosys
	sys-apps/net-tools
	sys-apps/pciutils
	sys-apps/smartmontools
	sys-apps/usbutils
	X? ( x11-apps/setxkbmap )"

DEPEND=""

src_unpack() {
	cros-workon_src_unpack
	S+="/userfeedback"
}

src_test() {
	test/storage_info_unit_test || die "Unit test failed"
}

src_install() {
	exeinto /usr/share/userfeedback/scripts
	doexe scripts/*

	insinto /usr/share/userfeedback/etc
	doins etc/*

	# Install init scripts.
	if use systemd; then
		local units=("mosys-info.service" "firmware-version.service"
			"storage-info.service")
		systemd_dounit init/*.service
		for unit in "${units[@]}"; do
			systemd_enable_service system-services.target ${unit}
		done
	else
		insinto /etc/init
		doins init/*.conf
	fi
}
