# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="2c29acc5ec9d0d64df7906064fc3ee7b67581220"
CROS_WORKON_TREE=("588664a20657ea966fedd74358b3cc2ba5addd47" "f2205a78c0421cca294f9dcce68d0b6659908811" "dc1506ef7c8cfd2c5ffd1809dac05596ec18773c")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk dlcservice .gn"

PLATFORM_SUBDIR="dlcservice"

inherit cros-workon platform user

DESCRIPTION="A D-Bus service for Downloadable Content (DLC)"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/dlcservice/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	chromeos-base/libbrillo
	chromeos-base/imageloader
	dev-libs/protobuf:="

DEPEND="${RDEPEND}
	chromeos-base/dlcservice-client
	chromeos-base/imageloader-client
	chromeos-base/system_api
	chromeos-base/update_engine-client"

src_install() {
	dosbin "${OUT}/dlcservice"

	# Seccomp policy files.
	insinto /usr/share/policy
	newins seccomp/dlcservice-seccomp-${ARCH}.policy \
		dlcservice-seccomp.policy

	# Upstart configuration
	insinto /etc/init
	doins dlcservice.conf

	# D-Bus configuration
	insinto /etc/dbus-1/system.d
	doins org.chromium.DlcService.conf
	insinto /usr/share/dbus-1/system-services
	doins org.chromium.DlcService.service

	platform_fuzzer_install "${S}"/OWNERS "${OUT}"/dlcservice_boot_slot_fuzzer \
		--dict "${S}"/fuzz/path.dict

	into /usr/local
	dobin "${OUT}/dlcservice_util"
}

platform_pkg_test() {
	platform_test "run" "${OUT}/dlcservice_tests"
}

pkg_preinst() {
	enewuser "dlcservice"
	enewgroup "dlcservice"
}
