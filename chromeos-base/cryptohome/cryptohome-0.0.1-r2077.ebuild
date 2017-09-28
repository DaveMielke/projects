# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="f9da3d359931723a523fc36086918e2431002085"
CROS_WORKON_TREE="baa6504b1ed8f70f5c154e68471f1b9aea611e6a"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"

PLATFORM_NATIVE_TEST="yes"
PLATFORM_SUBDIR="cryptohome"

inherit cros-workon platform systemd udev user

DESCRIPTION="Encrypted home directories for Chromium OS"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-cert_provision -direncryption systemd tpm tpm2"

REQUIRED_USE="tpm2? ( !tpm )"

RDEPEND="
	!chromeos-base/chromeos-cryptohome
	tpm? (
		app-crypt/trousers
	)
	tpm2? (
		chromeos-base/trunks
		chromeos-base/tpm_manager
		chromeos-base/attestation
	)
	chromeos-base/chaps
	chromeos-base/libbrillo
	chromeos-base/libscrypt
	chromeos-base/metrics
	chromeos-base/secure-erase-file
	chromeos-base/system_api
	dev-libs/dbus-glib
	dev-libs/glib
	dev-libs/openssl
	dev-libs/protobuf
	sys-apps/keyutils
	sys-fs/e2fsprogs
	sys-fs/ecryptfs-utils
	sys-fs/lvm2
"
DEPEND="${RDEPEND}
	chromeos-base/system_api
	chromeos-base/vboot_reference
"

src_install() {
	pushd "${OUT}" >/dev/null
	dosbin cryptohomed cryptohome cryptohome-path lockbox-cache tpm-manager
	dosbin mount-encrypted
	if use cert_provision; then
		dolib.so lib/libcert_provision.so
		dosbin cert_provision_client
	fi
	popd >/dev/null

	insinto /etc/dbus-1/system.d
	doins etc/Cryptohome.conf

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
		fi
		if use direncryption; then
			sed -i '/env DIRENCRYPTION_FLAG=/s:=.*:="--direncryption":' \
				"${D}/etc/init/cryptohomed.conf" ||
				die "Can't replace direncryption flag in cryptohomed.conf"
		fi
	fi
	insinto /usr/share/cros/init
	doins init/lockbox-cache.sh
	if use cert_provision; then
		insinto /usr/include/cryptohome
		doins cert_provision.h
	fi
}

platform_pkg_test() {
	platform_test "run" "${OUT}/cryptohome_testrunner"
}
