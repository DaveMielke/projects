# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="b5ae437466fd65f669b8b88a8f9c3f535093a17c"
CROS_WORKON_TREE=("5e90f79dec6430d855d27326141abc48491d5a63" "66c5b7f6cae30d3885e63e79aed859db594ddc5f")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"
CROS_WORKON_SUBTREE="common-mk hammerd"

PLATFORM_SUBDIR="hammerd"

inherit cros-workon platform user

DESCRIPTION="A daemon to update EC firmware of hammer, the base of the detachable."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/hammerd/"

LICENSE="BSD-Google"
SLOT=0
KEYWORDS="*"
IUSE="-hammerd_api"

RDEPEND="
	chromeos-base/libbrillo
	chromeos-base/metrics
	chromeos-base/system_api
	chromeos-base/vboot_reference
	dev-libs/openssl
	sys-apps/flashmap
"
DEPEND="${RDEPEND}"

pkg_preinst() {
	# Create user and group for hammerd
	enewuser "hammerd"
	enewgroup "hammerd"
}

src_install() {
	dobin "${OUT}/hammerd"

	# Install upstart configs and scripts.
	insinto /etc/init
	doins init/*.conf
	exeinto /usr/share/cros/init
	doexe init/*.sh

	# Install DBus config.
	insinto /etc/dbus-1/system.d
	doins dbus/org.chromium.hammerd.conf
}

platform_pkg_test() {
	platform_test "run" "${OUT}/unittest_runner"
}
