# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

CROS_WORKON_COMMIT="fd5e268ede644354238504818a4eb0fb365792d1"
CROS_WORKON_TREE=("4a87f2acd60231694d51adc7faab7765b0a1867b" "080c2ce779d178bb6ace7ae7454b00f5e211246c" "af3ecc3924359691a89fb2dac19c12e197648f15" "dc1506ef7c8cfd2c5ffd1809dac05596ec18773c")
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"
CROS_WORKON_INCREMENTAL_BUILD=1
# TODO(crbug.com/809389): Avoid directly including headers from other packages.
CROS_WORKON_SUBTREE="common-mk cryptohome secure_erase_file .gn"

PLATFORM_NATIVE_TEST="yes"
PLATFORM_SUBDIR="cryptohome"

inherit cros-workon platform systemd udev user

DESCRIPTION="Encrypted home directories for Chromium OS"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
# The flag distributed_cryptohome is for turning on tpm_manager and
# attestation for 1.2 devices.
IUSE="-cert_provision cryptohome_userdataauth_interface +device_mapper
	-direncryption distributed_cryptohome pinweaver selinux systemd test
	tpm tpm2"

REQUIRED_USE="
	device_mapper
	tpm2? ( !tpm )
"

RDEPEND="
	!chromeos-base/chromeos-cryptohome
	tpm? (
		app-crypt/trousers
	)
	tpm2? (
		chromeos-base/attestation
		chromeos-base/tpm_manager
		chromeos-base/trunks
	)
	distributed_cryptohome? (
		chromeos-base/attestation
		chromeos-base/tpm_manager
	)
	selinux? (
		sys-libs/libselinux
	)
	chromeos-base/chaps
	chromeos-base/libbrillo
	chromeos-base/libscrypt
	chromeos-base/metrics
	chromeos-base/secure-erase-file
	dev-libs/dbus-glib
	dev-libs/glib
	dev-libs/openssl:=
	dev-libs/protobuf:=
	sys-apps/keyutils
	sys-fs/e2fsprogs
	sys-fs/ecryptfs-utils
	sys-fs/lvm2
"
DEPEND="${RDEPEND}
	tpm2? ( chromeos-base/trunks[test?] )
	chromeos-base/bootlockbox-client
	chromeos-base/protofiles:=
	chromeos-base/system_api
	chromeos-base/vboot_reference
"

src_install() {
	pushd "${OUT}" >/dev/null
	dosbin cryptohomed cryptohome cryptohome-path lockbox-cache tpm-manager
	dosbin mount-encrypted
	if use tpm2; then
		dosbin bootlockboxd bootlockboxtool
	fi
	if use cert_provision; then
		dolib.so lib/libcert_provision.so
		dosbin cert_provision_client
	fi
	popd >/dev/null

	insinto /etc/dbus-1/system.d
	doins etc/Cryptohome.conf
	doins etc/org.chromium.UserDataAuth.conf
	if use tpm2; then
		doins etc/BootLockbox.conf
	fi

	# Install init scripts
	if use systemd; then
		if use tpm2; then
			sed 's/tcsd.service/attestationd.service/' \
				init/cryptohomed.service \
				> "${T}/cryptohomed.service"
			systemd_dounit "${T}/cryptohomed.service"
		else
			systemd_dounit init/cryptohomed.service
		fi
		systemd_dounit init/mount-encrypted.service
		systemd_dounit init/lockbox-cache.service
		systemd_enable_service boot-services.target cryptohomed.service
		systemd_enable_service system-services.target mount-encrypted.service
		systemd_enable_service ui.target lockbox-cache.service
	else
		insinto /etc/init
		doins init/*.conf
		if use tpm2; then
			sed -i 's/started tcsd/started attestationd/' \
				"${D}/etc/init/cryptohomed.conf" ||
				die "Can't replace tcsd with attestationd in cryptohomed.conf"
			insinto /usr/share/policy
			newins bootlockbox/seccomp/bootlockboxd-seccomp-${ARCH}.policy \
				bootlockboxd-seccomp.policy
			insinto /etc/init
			doins bootlockbox/bootlockboxd.conf
		fi
		if use direncryption; then
			sed -i '/env DIRENCRYPTION_FLAG=/s:=.*:="--direncryption":' \
				"${D}/etc/init/cryptohomed.conf" ||
				die "Can't replace direncryption flag in cryptohomed.conf"
		fi
	fi
	exeinto /usr/share/cros/init
	doexe init/lockbox-cache.sh
	if use cert_provision; then
		insinto /usr/include/cryptohome
		doins cert_provision.h
	fi

	platform_fuzzer_install "${S}"/OWNERS \
		"${OUT}"/cryptohome_cryptolib_rsa_oaep_decrypt_fuzzer \
		--seed_corpus "${S}"/fuzzers/cryptolib_rsa_oaep_decrypt_corpus
}

pkg_preinst() {
	enewuser "bootlockboxd"
	enewgroup "bootlockboxd"
}

platform_pkg_test() {
	platform_test "run" "${OUT}/cryptohome_testrunner"
	platform_test "run" "${OUT}/mount_encrypted_unittests"
	if use tpm2; then
		platform_test "run" "${OUT}/boot_lockbox_unittests"
	fi
}
