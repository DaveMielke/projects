# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="5ab4ce7ea48ee38e08fee9113895278836e99aa6"
CROS_WORKON_TREE="ed84865a9ea2ef527e744998ab6518da98a9e098"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

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
