# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_COMMIT="f8d0f6ce00239e339c164c792481e996d3948ee1"
CROS_WORKON_TREE=("638bfde957a502ad58d182712c1ebdf335f9a3da" "ec73a00693eb4b63b8b5d70cc49af62e6329aa3f" "9dd97fa7ab754a35fc2263f8478100af08c52bec" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_SUBTREE="common-mk chromeos-config bluetooth .gn"

PLATFORM_SUBDIR="bluetooth"

inherit cros-workon platform

DESCRIPTION="Bluetooth service for Chromium OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/bluetooth"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="+bluetooth_suspend_management fuzzer generated_cros_config seccomp unibuild"

RDEPEND="
	chromeos-base/chromeos-config-tools:=
	unibuild? (
		!generated_cros_config? ( chromeos-base/chromeos-config )
		generated_cros_config? ( chromeos-base/chromeos-config-bsp:= )
	)
	net-wireless/bluez:=
"

DEPEND="${RDEPEND}
	chromeos-base/system_api:=[fuzzer?]"

src_install() {
	dobin "${OUT}"/btdispatch

	insinto /etc/dbus-1/system.d
	doins dbus/org.chromium.Bluetooth.conf

	insinto /etc/init
	doins init/upstart/btdispatch.conf

	if use seccomp; then
		# Install seccomp policy files.
		insinto /usr/share/policy
		newins "seccomp_filters/btdispatch-seccomp-${ARCH}.policy" btdispatch-seccomp.policy
	else
		# Remove seccomp flags from minijail parameters.
		sed -i '/^env seccomp_flags=/s:=.*:="":' "${ED}"/etc/init/btdispatch.conf || die
	fi
}

platform_pkg_test() {
	platform_test "run" "${OUT}/bluetooth_test"
}