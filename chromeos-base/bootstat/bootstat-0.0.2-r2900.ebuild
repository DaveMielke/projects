# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="25a5cbf24eda611a7c4a09d69733ef8758f02f28"
CROS_WORKON_TREE=("6f3635a6f5b0951a7ffdebd896518c01b04cc21b" "011a726a0d0604c4321b89e67780a36e6896bcf0" "dc1506ef7c8cfd2c5ffd1809dac05596ec18773c")
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"
CROS_WORKON_SUBTREE="common-mk bootstat .gn"

PLATFORM_SUBDIR="bootstat"

inherit cros-workon platform

DESCRIPTION="Chrome OS Boot Time Statistics Utilities"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	sys-apps/rootdev
	"
DEPEND="${RDEPEND}
	chromeos-base/libbrillo
"

src_install() {
	dosbin "${OUT}"/bootstat
	dosbin bootstat_archive
	dosbin bootstat_get_last
	dobin bootstat_summary

	dolib.so "${OUT}"/lib/libbootstat.so

	insinto /usr/include/metrics
	doins bootstat.h
}

platform_pkg_test() {
	platform_test "run" "${OUT}/libbootstat_unittests"
}
