# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

CROS_WORKON_COMMIT="c60230e290048c05188d7cf9871fe98ac1624275"
CROS_WORKON_TREE=("730940d1ad982b0928be2d517a8583b66235e15e" "4b007bb876124ea5e3a6a5345979cefcd3dbbd77" "8858dcb1ef3c2b043abf24cfd0d74c156a637a41" "8a0607d17f7c87e437fca0b84884d1a1afcabc34" "fda343644d509468f777bd4c0d2054daef34e9e9" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
# TODO(crbug.com/809389): Avoid directly including headers from other packages.
CROS_WORKON_SUBTREE="common-mk attestation chaps tpm_manager trunks .gn"

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
