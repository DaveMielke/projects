# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_COMMIT="003f782cb23b092b5fd21b14916bafc4b8bf862c"
CROS_WORKON_TREE=("1319841568b5f67d3de28c685396b374735f5d15" "5ccb08cadb8fd6ac13651a22a975049b033a62f3" "60166b301c17c89f9c4d48957638c231e8793ab4" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
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
IUSE="+bluetooth_suspend_management fuzzer seccomp unibuild"

RDEPEND="
	unibuild? ( chromeos-base/chromeos-config:= )
	chromeos-base/newblue:=
	net-wireless/bluez:=
"

DEPEND="${RDEPEND}
	chromeos-base/system_api:=[fuzzer?]"

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

	platform_fuzzer_install "${S}"/OWNERS "${OUT}"/bluetooth_parsedataintouuids_fuzzer
	platform_fuzzer_install "${S}"/OWNERS "${OUT}"/bluetooth_parsedataintoservicedata_fuzzer
	platform_fuzzer_install "${S}"/OWNERS "${OUT}"/bluetooth_parseeir_fuzzer
	platform_fuzzer_install "${S}"/OWNERS "${OUT}"/bluetooth_parsereportdescriptor_fuzzer
	platform_fuzzer_install "${S}"/OWNERS "${OUT}"/bluetooth_trimadapterfromobjectpath_fuzzer
	platform_fuzzer_install "${S}"/OWNERS "${OUT}"/bluetooth_trimdevicefromobjectpath_fuzzer
	platform_fuzzer_install "${S}"/OWNERS "${OUT}"/bluetooth_trimservicefromobjectpath_fuzzer
	platform_fuzzer_install "${S}"/OWNERS "${OUT}"/bluetooth_trimcharacteristicfromobjectpath_fuzzer
	platform_fuzzer_install "${S}"/OWNERS "${OUT}"/bluetooth_trimdescriptorfromobjectpath_fuzzer
}

platform_pkg_test() {
	platform_test "run" "${OUT}/bluetooth_test"
}
