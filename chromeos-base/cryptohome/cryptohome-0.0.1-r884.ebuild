# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="cf593f50007c93b62108c3bf784ba0357e056d68"
CROS_WORKON_TREE="b8ccae7b81fc67e5f6194d01406295cfc4db2f82"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"

PLATFORM_NATIVE_TEST="yes"
PLATFORM_SUBDIR="cryptohome"

inherit cros-workon platform udev user

DESCRIPTION="Encrypted home directories for Chromium OS"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="test -tpm2"

RDEPEND="
	!chromeos-base/chromeos-cryptohome
	!tpm2? (
		app-crypt/trousers
	)
	tpm2? (
		chromeos-base/trunks
	)
	chromeos-base/chaps
	chromeos-base/libchromeos
	chromeos-base/libscrypt
	chromeos-base/metrics
	dev-libs/dbus-glib
	dev-libs/glib
	dev-libs/openssl
	dev-libs/protobuf
	sys-apps/keyutils
	sys-fs/ecryptfs-utils
	sys-fs/lvm2
"
DEPEND="${RDEPEND}
	chromeos-base/system_api
	chromeos-base/vboot_reference
	dev-cpp/gtest
"

src_install() {
	pushd "${OUT}" >/dev/null
	dosbin cryptohomed cryptohome cryptohome-path lockbox-cache tpm-manager
	dosbin mount-encrypted
	popd >/dev/null

	insinto /etc/dbus-1/system.d
	doins etc/Cryptohome.conf

	insinto /etc/init
	doins init/*.conf
}

platform_pkg_test() {
	platform_test "run" "${OUT}/cryptohome_testrunner"
}
