# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="436083df7d7507d2fe14edfbf8963807c853fb47"
CROS_WORKON_TREE=("13228e56ac75327ed92fe81d6a0ed4f5c11c2a6a" "b0055e40e651dbc426d871c14a7dc0cbeb851996" "dc1506ef7c8cfd2c5ffd1809dac05596ec18773c")
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_SUBTREE="common-mk bluetooth .gn"

PLATFORM_SUBDIR="bluetooth"

inherit cros-workon platform

DESCRIPTION="Bluetooth service for Chromium OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/bluetooth"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="seccomp"

RDEPEND="
	chromeos-base/libbrillo
	chromeos-base/newblue
	net-wireless/bluez"

DEPEND="${RDEPEND}
	chromeos-base/system_api"

src_install() {
	dobin init/scripts/bluetooth-setup.sh
	dobin "${OUT}"/btdispatch
	dobin "${OUT}"/newblued

	insinto /etc/dbus-1/system.d
	doins dbus/org.chromium.Bluetooth.conf
	doins dbus/org.chromium.Newblue.conf

	insinto /etc/init
	doins init/upstart/bluetooth-setup.conf
	doins init/upstart/btdispatch.conf
	doins init/upstart/newblued.conf

	if use seccomp; then
		# Install seccomp policy files.
		insinto /usr/share/policy
		newins "seccomp_filters/btdispatch-seccomp-${ARCH}.policy" btdispatch-seccomp.policy
		newins "seccomp_filters/newblued-seccomp-${ARCH}.policy" newblued-seccomp.policy
	else
		# Remove seccomp flags from minijail parameters.
		sed -i '/^env seccomp_flags=/s:=.*:="":' "${ED}"/etc/init/btdispatch.conf || die
		sed -i '/^env seccomp_flags=/s:=.*:="":' "${ED}"/etc/init/newblued.conf || die
	fi
}

platform_pkg_test() {
	platform_test "run" "${OUT}/bluetooth_test"
}
