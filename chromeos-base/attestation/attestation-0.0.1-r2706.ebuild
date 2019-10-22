# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

CROS_WORKON_COMMIT="e835325abfa6acfee13582dbdf2c779708818ff9"
CROS_WORKON_TREE=("bfa2dfdfdc1fd669d4e14dc30d8f0fc82490bad9" "78a85d5ebbfda73297884a072c3837eef7e5009b" "0e68beb1125d00c4c78094b77fa90ea37065f356" "38a36f76290e3e0f13d021ad8597ea5f250a05ba" "4aa72d025149303c5db01a50621f57e8a131f6a4" "26c78fd15c90622d10d92f30cdc76cf7db4fb266" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
# TODO(crbug.com/809389): Avoid directly including headers from other packages.
CROS_WORKON_SUBTREE="common-mk attestation chaps libhwsec tpm_manager trunks .gn"

PLATFORM_SUBDIR="attestation"

inherit cros-workon libchrome platform user

DESCRIPTION="Attestation service for Chromium OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/attestation/"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="distributed_cryptohome test tpm tpm2"

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
	test? ( chromeos-base/libhwsec )
	chromeos-base/vboot_reference
	tpm2? (
		chromeos-base/trunks[test?]
		chromeos-base/chromeos-ec-headers
	)
	"

pkg_preinst() {
	# Create user and group for attestation.
	enewuser "attestation"
	enewgroup "attestation"
	# Create group for /mnt/stateful_partition/unencrypted/preserve.
	enewgroup "preserve"
}

src_install() {
	if use tpm2 || use distributed_cryptohome; then
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

		insinto /usr/share/policy
		newins server/attestationd-seccomp-${ARCH}.policy attestationd-seccomp.policy
	fi

	dolib.so "${OUT}"/lib/libattestation.so


	insinto /usr/include/attestation/client
	doins client/dbus_proxy.h
	insinto /usr/include/attestation/common
	doins common/attestation_interface.h
	doins common/print_attestation_ca_proto.h
	doins common/print_interface_proto.h
	doins common/print_keystore_proto.h
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
