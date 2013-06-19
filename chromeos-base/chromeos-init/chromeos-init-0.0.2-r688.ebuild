# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="d4856fb9849a5971f56664516e4a6c45ae78051a"
CROS_WORKON_TREE="80ad947ba0ae9c358eb500c94733d01e839b2b10"
CROS_WORKON_PROJECT="chromiumos/platform/init"
CROS_WORKON_LOCALNAME="init"

inherit cros-workon

DESCRIPTION="Upstart init scripts for Chromium OS"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"

# NOTE: vt can only be turned off for embedded currently.
IUSE="cros_embedded nfs vt"

DEPEND=""
# vpd for vpd-log.conf of upstart
# vboot_reference for crossystem
RDEPEND="
	chromeos-base/crash-reporter
	!<chromeos-base/shill-0.0.1-r805
	chromeos-base/vboot_reference
	net-firewall/iptables[ipv6]
	sys-apps/rootdev
	sys-apps/upstart
	!cros_embedded? (
		chromeos-base/chromeos-disableecho
		chromeos-base/vpd
		sys-apps/chvt
		sys-apps/smartmontools
	)
"

src_install() {
	# Install log cleaning script and run it daily.
	dosbin chromeos-cleanup-logs
	dosbin simple-rotate
	dosbin netfilter-common

	insinto /etc
	doins issue rsyslog.chromeos

	into /	# We want /sbin, not /usr/sbin, etc.

	# Install various utility files.
	dosbin killers

	# Install startup/shutdown scripts.
	dosbin chromeos_startup chromeos_shutdown
	dosbin clobber-state
	dosbin clobber-log

	if use cros_embedded; then
		insinto /etc/init
		doins startup.conf
		doins embedded-init/boot-services.conf
		doins embedded-init/login-prompt-visible.conf

		doins boot-complete.conf cgroups.conf crash-reporter.conf cron-lite.conf
		doins dbus.conf failsafe-delay.conf failsafe.conf halt.conf
		doins install-completed.conf ip6tables.conf iptables.conf
		doins pre-shutdown.conf pstore.conf reboot.conf shill.conf
		doins shill_respawn.conf syslog.conf system-services.conf tlsdated.conf
		doins update-engine.conf wpasupplicant.conf

		use vt && doins tty2.conf

		# TODO(petkov): Consider a separate USE flag for mounting encrypted
		# vs. unencrypted /var and /home/chronos (crbug.com/242840).
		insinto /usr/share/cros
		doins embedded-init/startup_utils.sh
	else
		insinto /etc/init
		doins *.conf

		dosbin date-proxy-watcher
		dosbin chromeos-boot-alert
		dosbin display_low_battery_alert

		insinto /usr/share/cros
		doins startup_utils.sh

		into /usr
		dosbin lightup_screen

		if use nfs; then
			# With USE=nfs we remove the iptables rules to allow mounting
			# of the root device.
			rm "${D}/etc/init/iptables.conf" || die
			rm "${D}/etc/init/ip6tables.conf" || die
			# If nfs mounted use a tmpfs stateful partition like factory
			sed -i 's/ext4/tmpfs/; s/,commit=600//' \
				"${D}/sbin/chromeos_startup" || die
		fi
	fi
}
