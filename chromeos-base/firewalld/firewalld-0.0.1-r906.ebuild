# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT=("ad21acef48715679a19ce268d7e781bbe8a453b1" "90c4a0d3a66a84270aa8a8b4d46a97e6172074e9")
CROS_WORKON_TREE=("5ccc6063b1b537906cd9b6a040bb5d9cb8ffbea1" "643ebe0b50aab41fcafc91ef9d2df86269fe53ae")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME=("platform2" "aosp/system/firewalld")
CROS_WORKON_PROJECT=("chromiumos/platform2" "aosp/platform/system/firewalld")
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/platform2/firewalld")

PLATFORM_SUBDIR="firewalld"

inherit cros-workon platform

DESCRIPTION="System service for handling firewall rules"
HOMEPAGE="http://www.chromium.org/"

LICENSE="Apache-2.0"
SLOT=0
KEYWORDS="*"

RDEPEND="
	chromeos-base/chromeos-minijail
	chromeos-base/libbrillo
	sys-apps/dbus
"

DEPEND="${RDEPEND}
	chromeos-base/permission_broker-client
	chromeos-base/system_api
	test? ( dev-cpp/gmock )
	dev-cpp/gtest
"

src_install() {
	dobin "${OUT}/firewalld"

	# Install D-Bus configuration.
	insinto /etc/dbus-1/system.d
	doins dbus/org.chromium.Firewalld.conf

	# Install Upstart configuration.
	insinto /etc/init
	doins firewalld.conf

	local client_includes=/usr/include/firewalld-client
	local client_test_includes=/usr/include/firewalld-client-test

	# Install DBus proxy header.
	insinto "${client_includes}/firewalld"
	doins "${OUT}/gen/include/firewalld/dbus-proxies.h"
	insinto "${client_test_includes}/firewalld"
	doins "${OUT}/gen/include/firewalld/dbus-mocks.h"

	# Generate and install pkg-config for client libraries.
	insinto "/usr/$(get_libdir)/pkgconfig"
	./generate_pc_file.sh "${OUT}" libfirewalld-client "${client_includes}"
	doins "${OUT}/libfirewalld-client.pc"
	./generate_pc_file.sh "${OUT}" libfirewalld-client-test "${client_test_includes}"
	doins "${OUT}/libfirewalld-client-test.pc"
}

platform_pkg_test() {
	local tests=(
		firewalld_unittest
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}
