# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_COMMIT="4fc06e2ba9ad77efcea3e2a41b75ae1be0c7dc0d"
CROS_WORKON_TREE=("f089191a0d3d6b85e2d71b4dbba970e0fc4966e1" "49dbcf05f1de5623a8ab1699d47122980405a499" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
CROS_WORKON_USE_VCSID="1"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk biod .gn"

PLATFORM_SUBDIR="biod/biod_proxy"

inherit cros-workon platform

DESCRIPTION="DBus Proxy Library for Biometrics Daemon for Chromium OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/biod/README.md"

LICENSE="BSD-Google"
KEYWORDS="*"

RDEPEND=""

DEPEND="
	chromeos-base/system_api:=
"

src_install() {
	dolib.so "${OUT}"/lib/libbiod_proxy.so
}

platform_pkg_test() {
	platform_test "run" "${OUT}/biod_proxy_test_runner"
}