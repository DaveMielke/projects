# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="4e8e3c9540d4551c591de154f30863080f44c669"
CROS_WORKON_TREE=("500027955923ee4dc652a725c0bbeb405aac230a" "7d0edff0bc8ff7c394d944fadc399ca567e9b1bf" "dc1506ef7c8cfd2c5ffd1809dac05596ec18773c")
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
