# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

CROS_WORKON_COMMIT="cf5b83edec68ee3bd13e24e0837b0bf263eea8d5"
CROS_WORKON_TREE=("c7c53e5e73240826942d7edceef245b060e54ac7" "190f2ef46fd76d827674764cc4b903db379c2c22" "af3ecc3924359691a89fb2dac19c12e197648f15" "dc1506ef7c8cfd2c5ffd1809dac05596ec18773c")
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"
CROS_WORKON_INCREMENTAL_BUILD=1
# TODO(crbug.com/809389): Avoid directly including headers from other packages.
CROS_WORKON_SUBTREE="common-mk cryptohome secure_erase_file .gn"

PLATFORM_SUBDIR="cryptohome/dev-utils"

inherit cros-workon platform

DESCRIPTION="Cryptohome developer and testing utilities for Chromium OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/cryptohome"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="tpm tpm2"

REQUIRED_USE="tpm2? ( !tpm )"

RDEPEND="
	tpm? (
		app-crypt/trousers
	)
	tpm2? (
		chromeos-base/trunks
		chromeos-base/tpm_manager
		chromeos-base/attestation
	)
	chromeos-base/chaps
	chromeos-base/libbrillo:=
	chromeos-base/libscrypt
	chromeos-base/metrics
	chromeos-base/secure-erase-file
	dev-libs/glib
	dev-libs/openssl:=
	dev-libs/protobuf:=
	sys-apps/keyutils
	sys-fs/e2fsprogs
	sys-fs/ecryptfs-utils
"

DEPEND="${RDEPEND}
	chromeos-base/vboot_reference
"

src_install() {
	dosbin "${OUT}"/cryptohome-tpm-live-test
}
