# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="04ebb8f654436f4b3f534b5482a11938b1f2ee27"
CROS_WORKON_PROJECT="chromiumos/platform/init"

inherit cros-workon

DESCRIPTION="Upstart init scripts for Chromium OS"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

DEPEND=""
# vpd for vpd-log.conf of upstart
# vboot_reference for crossystem
RDEPEND="chromeos-base/audioconfig-board
	chromeos-base/vboot_reference
	chromeos-base/vpd
	sys-apps/smartmontools
	sys-apps/upstart"

CROS_WORKON_LOCALNAME="init"

src_install() {
	into /	# We want /sbin, not /usr/sbin, etc.

	# Install Upstart configuration files.
	dodir /etc/init
	install --owner=root --group=root --mode=0644 \
		"${S}"/*.conf "${D}/etc/init/"

	dodir /etc
	install --owner=root --group=root --mode=0644 \
		"${S}/issue" "${D}/etc/"

	# Install various utility files
	dosbin "${S}/killers"
	dosbin "${S}/send_boot_metrics"

	# Install startup/shutdown scripts.
	dosbin "${S}/chromeos_startup" "${S}/chromeos_shutdown"
	dosbin "${S}/chromeos-boot-alert"
	dosbin "${S}/clobber-state"
	dosbin "${S}/clobber-log"

	# Install log cleaning script and run it daily.
	into /usr
	dosbin "${S}/chromeos-cleanup-logs"
	exeinto /etc/cron.daily
	doexe "${S}/cleanup-logs.daily"

	# Install lightup_screen
	into /usr
	dosbin "${S}/lightup_screen"

	# Install rsyslogd's configuration file.
	insinto /etc
	doins rsyslog.chromeos || die

	# Some daemons and utilities access the mounts through /etc/mtab.
	dosym /proc/mounts /etc/mtab || die
}
