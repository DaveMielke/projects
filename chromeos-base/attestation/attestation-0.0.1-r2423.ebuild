# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

CROS_WORKON_COMMIT="29690ea157f96b26cc9cc9488a329e722d1b2c57"
CROS_WORKON_TREE=("17f4a6efa079886fb3e23fd256264f932d59721d" "537fa56c45c06c4011fa56f3b5b67cca4764de94" "fe4393e097cb6e2abd29521a62d6ae6db0d16074" "b11bccc2a991609d2cbb91c01300902f7c6d382a" "54eb45a96be62a2b5336239e0adc6756d806a352")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
# TODO(crbug.com/809389): Avoid directly including headers from other packages.
CROS_WORKON_SUBTREE="common-mk attestation chaps tpm_manager trunks"

PLATFORM_SUBDIR="attestation"

inherit cros-workon libchrome platform user

DESCRIPTION="Attestation service for Chromium OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/attestation/"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="test tpm tpm2"

REQUIRED_USE="tpm2? ( !tpm )"

RDEPEND="
	tpm? (
		app-crypt/trousers
	)
	tpm2? (
		chromeos-base/trunks
	)
	chromeos-base/chaps
	chromeos-base/minijail
	chromeos-base/libbrillo
	chromeos-base/tpm_manager
	"

DEPEND="
	${RDEPEND}
	chromeos-base/vboot_reference
	tpm2? ( chromeos-base/trunks[test?] )
	"

pkg_preinst() {
	# Create user and group for attestation.
	enewuser "attestation"
	enewgroup "attestation"
	# Create group for /mnt/stateful_partition/unencrypted/preserve.
	enewgroup "preserve"
}

src_install() {
	insinto /etc/dbus-1/system.d
	doins server/org.chromium.Attestation.conf

	insinto /etc/init
	doins server/attestationd.conf
	if use tpm2; then
		sed -i 's/started tcsd/started tpm_managerd/' \
			"${D}/etc/init/attestationd.conf" ||
			die "Can't replace tcsd with tpm_managerd in attestationd.conf"
	fi

	dosbin "${OUT}"/attestationd
	dobin "${OUT}"/attestation_client
	dolib.so "${OUT}"/lib/libattestation.so

	insinto /usr/share/policy
	newins server/attestationd-seccomp-${ARCH}.policy attestationd-seccomp.policy

	insinto /usr/include/attestation/client
	doins client/dbus_proxy.h
	insinto /usr/include/attestation/common
	doins common/attestation_interface.h
	doins common/print_common_proto.h
	doins common/print_interface_proto.h
	doins "${OUT}"/gen/include/attestation/common/common.pb.h
	doins "${OUT}"/gen/include/attestation/common/interface.pb.h
	insinto /usr/share/protofiles/attestation
	doins common/common.proto
	doins common/interface.proto
}

platform_pkg_test() {
	local tests=(
		attestation_testrunner
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}
