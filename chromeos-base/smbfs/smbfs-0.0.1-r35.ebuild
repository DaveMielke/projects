# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

CROS_WORKON_COMMIT="78abf1c851666302239352f0fb03efa8feffb30e"
CROS_WORKON_TREE=("587fcc1fc96e0444ffe553cf04588b83796f3de2" "c73e1f37fdaafa35e9ffaf067aca34722c2144cd" "1435022cff005e8270967c2856fbc1f4df4d4d2b" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"
# TODO(crbug.com/809389): Avoid directly including headers from other packages.
CROS_WORKON_SUBTREE="common-mk libpasswordprovider smbfs .gn"

PLATFORM_SUBDIR="smbfs"

inherit cros-workon platform user

DESCRIPTION="FUSE filesystem to mount SMB shares."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/smbfs/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	=sys-fs/fuse-2.9*
	net-fs/samba
"

DEPEND="
	${RDEPEND}
	chromeos-base/system_api
	chromeos-base/libpasswordprovider
"

pkg_preinst() {
	enewuser "fuse-smbfs"
	enewgroup "fuse-smbfs"
}

src_install() {
	dosbin "${OUT}"/smbfs
}

platform_pkg_test() {
	local tests=(
		smbfs_test
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}
