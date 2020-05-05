# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_WORKON_COMMIT="0b002b71029c0c9135633f2c045720c2cc25632d"
CROS_WORKON_TREE=("d802ce3091795ebf52e92b317fe508d6d6a1eafc" "1a0f41ea8e44335ad0b63e514b65695c6c462497" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"
CROS_WORKON_SUBTREE="common-mk vm_tools/sommelier .gn"

PLATFORM_SUBDIR="vm_tools/sommelier"

inherit cros-workon platform

DESCRIPTION="A Wayland compositor for use in CrOS VMs"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/vm_tools/sommelier"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="kvm_guest"

# This ebuild should only be used on VM guest boards.
REQUIRED_USE="kvm_guest"

COMMON_DEPEND="
	media-libs/mesa:=[gbm]
	x11-base/xwayland:=
	x11-libs/libxkbcommon:=
	x11-libs/pixman:=
"

RDEPEND="
	!<chromeos-base/vm_guest_tools-0.0.2-r722
	${COMMON_DEPEND}
"

DEPEND="
	${COMMON_DEPEND}
"

src_install() {
	dobin "${OUT}"/sommelier
}

platform_pkg_test() {
	# TODO(hollingum): maybe sommelier would break less if it had any tests...
	local tests=(
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}
