# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="01c740edaf2509324979359e2618478a46c7ed52"
CROS_WORKON_TREE=("2a8b5e5d33f20cd70c9e7296e1e2a69a05f38164" "dadf7359c38172a67f40d11a89077e23226d0cf1" "c5f6af8f478f68ea46983ef56638b3c5d16539a4" "dc1506ef7c8cfd2c5ffd1809dac05596ec18773c")
CROS_WORKON_USE_VCSID="1"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_INCREMENTAL_BUILD=1
# TODO(crbug.com/809389): Avoid directly including headers from other packages.
CROS_WORKON_SUBTREE="common-mk trunks u2fd .gn"

PLATFORM_SUBDIR="u2fd"

inherit cros-workon platform user

DESCRIPTION="U2FHID Emulation Daemon"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/u2fhid"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	chromeos-base/libbrillo
	chromeos-base/power_manager-client
	chromeos-base/trunks
	dev-libs/hidapi
	"

DEPEND="
	${RDEPEND}
	chromeos-base/system_api
	"

pkg_setup() {
	# Has to be done in pkg_setup() instead of pkg_preinst() since
	# src_install() needs the u2f user and group.
	enewuser "u2f"
	enewgroup "u2f"
	cros-workon_pkg_setup
}

src_install() {
	dobin "${OUT}"/u2fd

	insinto /etc/init
	doins init/*.conf

	local daemon_store="/etc/daemon-store/u2f"
	dodir "${daemon_store}"
	fperms 0700 "${daemon_store}"
	fowners u2f:u2f "${daemon_store}"
}
