# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="ade0599d38569698afc4832f8686dc1ca76c5336"
CROS_WORKON_TREE=("5e2f6a416f94eb6dd70589e548bbeac32fbf7c13" "301ed0747d7b6772c181637ff9d6d71cb7e9d4fc" "dc1506ef7c8cfd2c5ffd1809dac05596ec18773c")
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk cecservice .gn"

PLATFORM_SUBDIR="cecservice"

inherit cros-workon platform udev user

DESCRIPTION="Chrome OS CEC service"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/cecservice"
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	chromeos-base/libbrillo
"
DEPEND="
	chromeos-base/system_api
	${RDEPEND}
"

pkg_preinst() {
	enewuser "cecservice"
	enewgroup "cecservice"
}

platform_pkg_test() {
	platform_test "run" "${OUT}/cecservice_testrunner"
}

src_install() {
	dosbin "${OUT}"/cecservice

	udev_dorules share/99-cec.rules

	# Install DBus config.
	insinto /etc/dbus-1/system.d
	doins share/org.chromium.CecService.conf

	# Install upstart script.
	insinto /etc/init
	doins share/cecservice.conf
}
