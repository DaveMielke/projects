# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="c882eb0676a3616226063eaae36fac199b80d3d8"
CROS_WORKON_TREE=("85e4e098023fcccb8851b45c351a7045fa23f06f" "92a9a97f67e8be63fb16a10b1bd601ed2ed31af3" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk arc/vm/sensor_service .gn"

PLATFORM_SUBDIR="arc/vm/sensor_service"

inherit cros-workon platform

DESCRIPTION="ARC sensor service."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/arc/vm/sensor_service"

LICENSE="BSD-Google"
KEYWORDS="*"

RDEPEND="
"

DEPEND="
	${RDEPEND}
"

src_install() {
	dobin "${OUT}"/arc_sensor_service

	insinto /etc/init
	doins init/arc-sensor-service.conf

	insinto /etc/dbus-1/system.d
	doins init/dbus-1/org.chromium.ArcSensorService.conf
}
