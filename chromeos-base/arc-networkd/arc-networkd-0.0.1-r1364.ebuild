# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="2779be40022b1d5dfb4c23f5b414f6231427a68b"
CROS_WORKON_TREE=("8fafe4805a3e397e87abc5fd68bec0a9d23fde07" "57dfde80cd9f02d1458f2be5175afdede0120a2c" "274de9796bda4f2a94315a01b31e4f88092492c6" "dc1506ef7c8cfd2c5ffd1809dac05596ec18773c")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
# TODO(garrick): Workaround for https://crbug.com/809389
CROS_WORKON_SUBTREE="common-mk arc/network shill/net .gn"

PLATFORM_SUBDIR="arc/network"
PLATFORM_GYP_FILE="arc-network.gyp"

inherit cros-workon libchrome platform user

DESCRIPTION="ARC connectivity management daemon"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
SLOT=0
KEYWORDS="*"

COMMON_DEPEND="
	chromeos-base/libbrillo
	dev-libs/protobuf:=
	net-libs/libndp
"

RDEPEND="
	${COMMON_DEPEND}
	chromeos-base/chromeos-nat-init
	net-misc/bridge-utils
"

DEPEND="
	${COMMON_DEPEND}
	chromeos-base/shill
	chromeos-base/shill-client
	chromeos-base/system_api
"

src_install() {
	# Main binary.
	dobin "${OUT}"/arc-networkd

	# Utility library.
	dolib.so "${OUT}"/lib/libarcnetwork-util.so

	"${S}"/preinstall.sh "${PV}" "/usr/include/chromeos" "${OUT}"
	insinto "/usr/$(get_libdir)/pkgconfig"
	doins "${OUT}"/libarcnetwork-util.pc

	insinto /usr/include/arc/network/
	doins mac_address_generator.h
	doins subnet.h
	doins subnet_pool.h

	insinto /etc/init
	doins "${S}"/init/arc-network.conf
	doins "${S}"/init/arc-network-bridge.conf
}

pkg_preinst() {
	# Service account used for privilege separation.
	enewuser arc-networkd
	enewgroup arc-networkd
}

platform_pkg_test() {
	platform_test "run" "${OUT}/arc_network_testrunner"
}

