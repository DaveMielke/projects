# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="cbed97c5bfe708c42bd3601891bf08a422bc3b63"
CROS_WORKON_TREE=("ce18fba0c0aae39b3917fd9511c2a282b7fb703b" "9545385d9564a21d5199a6b3d60c1b1baa062c98")
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_SUBTREE="common-mk vm_tools"

PLATFORM_SUBDIR="vm_tools"

inherit cros-workon platform udev user

DESCRIPTION="VM host tools for Chrome OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/vm_tools"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="+kvm_host"
REQUIRED_USE="kvm_host"

RDEPEND="
	!!chromeos-base/vm_tools
	chromeos-base/crosvm
	chromeos-base/libbrillo
	chromeos-base/minijail
	dev-libs/grpc
	dev-libs/protobuf:=
"
DEPEND="
	${RDEPEND}
	>=chromeos-base/system_api-0.0.1-r3259
"

src_install() {
	dobin "${OUT}"/maitred_client
	dobin "${OUT}"/vmlog_forwarder
	dobin "${OUT}"/vsh
	dobin "${OUT}"/vm_concierge
	dobin "${OUT}"/concierge_client

	insinto /etc/init
	doins init/*.conf

	insinto /etc/dbus-1/system.d
	doins dbus/org.chromium.VmConcierge.conf

	udev_dorules udev/99-vm.rules
}

platform_pkg_test() {
	local tests=(
		concierge_test
		syslog_forwarder_test
	)

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
