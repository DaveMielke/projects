# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=6

CROS_WORKON_COMMIT="c6e430949b7789fd1155da1ce6451cc5c30f2555"
CROS_WORKON_TREE=("3ec7544c4b108a15d3ea61facc0a4bbeace58eed" "f543a07bb08e1844aa89baf2539cd77ac0ea0b61" "4d25ccf33850d2e311322aea6ea53fa611721500" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_OUTOFTREE_BUILD=1
# TODO(crbug.com/809389): Avoid directly including headers from other packages.
CROS_WORKON_SUBTREE="common-mk metrics p2p .gn"

PLATFORM_SUBDIR="p2p"

inherit cros-debug cros-workon platform user

DESCRIPTION="Chromium OS P2P"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="fuzzer"

RDEPEND="chromeos-base/metrics
	dev-libs/glib
	net-dns/avahi-daemon
	net-firewall/iptables"

DEPEND="${RDEPEND}"

platform_pkg_test() {
	local tests=(
		p2p-client-unittests
		p2p-server-unittests
		p2p-http-server-unittests
		p2p-common-unittests
	)

	local test_bin
	cd "${OUT}"
	for test_bin in "${tests[@]}"; do
		platform_test "run" "./${test_bin}"
	done
}

pkg_preinst() {
	# Groups are managed in the central account database.
	enewgroup p2p
	enewuser p2p
}

src_install() {
	dosbin "${OUT}"/p2p-client
	dosbin "${OUT}"/p2p-server
	dosbin "${OUT}"/p2p-http-server

	insinto /etc/init
	doins data/p2p.conf

	# Install fuzzer
	platform_fuzzer_install "${S}"/OWNERS \
			"${OUT}"/p2p_http_server_fuzzer
}
