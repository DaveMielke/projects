# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

CROS_WORKON_COMMIT="243acd68e223a03b0c2639514dc922a444482da3"
CROS_WORKON_TREE=("5e2f6a416f94eb6dd70589e548bbeac32fbf7c13" "8d997df878743011afd1437225b8bcaba75aacbb" "dc1506ef7c8cfd2c5ffd1809dac05596ec18773c")
CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk arc/vm/libvda .gn"

PLATFORM_SUBDIR="arc/vm/libvda"

inherit cros-workon multilib platform

DESCRIPTION="libvda CrOS video decoding library"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/arc/vm/libvda"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="libvda_test"

RDEPEND="
	chromeos-base/libbrillo:=
	media-libs/minigbm:=
"

DEPEND="
	${RDEPEND}
	chromeos-base/system_api:=
"

src_install() {
	dolib.so "${OUT}"/lib/libvda.so
	insinto "/usr/$(get_libdir)/pkgconfig"
	doins "${OUT}"/obj/arc/vm/libvda/libvda.pc
}

platform_pkg_test() {
	platform_test "run" "${OUT}/libvda_fake_unittest"
}
