# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="a5530b3773e73303254f6ffd1ded5284666aa1ba"
CROS_WORKON_TREE=("720cf19b24f85b5cb772bba081aeb033fd4318b4" "faf2fdc3a0b5a709f3edecfb000cbb7630bb2a64" "dc1506ef7c8cfd2c5ffd1809dac05596ec18773c")
CROS_GO_PACKAGES=(
	"chromiumos/vm_tools/tremplin_proto"
)

CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_SUBTREE="common-mk vm_tools .gn"

PLATFORM_SUBDIR="vm_tools"

inherit cros-go cros-workon platform user

DESCRIPTION="VM guest tools for Chrome OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/vm_tools"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="kvm_guest vm-containers"

# This ebuild should only be used on VM guest boards.
REQUIRED_USE="kvm_guest"

RDEPEND="
	!!chromeos-base/vm_tools
	chromeos-base/libbrillo
	chromeos-base/minijail
	net-libs/grpc:=
	dev-libs/protobuf:=
	media-libs/mesa[gbm]
	x11-base/xwayland
	x11-libs/libxkbcommon
	x11-libs/pixman
"
DEPEND="
	${RDEPEND}
	dev-go/grpc
	dev-go/protobuf
	>=sys-kernel/linux-headers-4.4-r16
"

src_configure() {
	platform_src_configure "vm_tools/sommelier/sommelier.gyp"
}

src_install() {
	dobin "${OUT}"/vm_syslog
	dosbin "${OUT}"/vshd

	if use vm-containers; then
		dobin "${OUT}"/garcon
		dobin "${OUT}"/notificationd
		dobin "${OUT}"/sommelier
		dobin "${OUT}"/virtwl_guest_proxy
		dobin "${OUT}"/wayland_demo
		dobin "${OUT}"/x11_demo
	fi

	into /
	newsbin "${OUT}"/maitred init

	dosym /run/resolv.conf /etc/resolv.conf

	CROS_GO_WORKSPACE="${OUT}/gen/go"
	cros-go_src_install
}

platform_pkg_test() {
	local tests=(
		maitred_service_test
		maitred_syslog_test
	)

	local container_tests=(
		garcon_app_search_test
		garcon_desktop_file_test
		garcon_icon_index_file_test
		garcon_icon_finder_test
		garcon_mime_types_parser_test
		notificationd_test
	)

	if use vm-containers; then
		tests+=( "${container_tests[@]}" )
	fi

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}

pkg_preinst() {
	# We need the syslog user and group for both host and guest builds.
	enewuser syslog
	enewgroup syslog
}
