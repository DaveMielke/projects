# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="ade0599d38569698afc4832f8686dc1ca76c5336"
CROS_WORKON_TREE=("5e2f6a416f94eb6dd70589e548bbeac32fbf7c13" "40a1a5c0ee48dc0634ac9ac8b03574312a85a07d" "dc1506ef7c8cfd2c5ffd1809dac05596ec18773c")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk tpm2-simulator .gn"

PLATFORM_SUBDIR="tpm2-simulator"

inherit cros-workon platform user

DESCRIPTION="TPM 2.0 Simulator"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	dev-libs/openssl
	chromeos-base/libbrillo
	"

DEPEND="
	chromeos-base/tpm2
	${RDEPEND}
	"

src_install() {
	dobin "${OUT}"/tpm2-simulator
}
