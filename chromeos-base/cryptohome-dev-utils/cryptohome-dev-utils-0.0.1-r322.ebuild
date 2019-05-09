# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

CROS_WORKON_COMMIT="9ca31bd2c27be5d7708650075bad67f1fe1579f6"
CROS_WORKON_TREE=("e91113c76a301817d0bdf72fff73b88789001d70" "dfbe94bcd04b78ccec29f6bf0f02fc4e0298ecaf" "af3ecc3924359691a89fb2dac19c12e197648f15" "dc1506ef7c8cfd2c5ffd1809dac05596ec18773c")
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
	)
	chromeos-base/attestation
	chromeos-base/chaps
	chromeos-base/libbrillo:=
	chromeos-base/libscrypt
	chromeos-base/metrics
	chromeos-base/tpm_manager
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
