# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=7

CROS_WORKON_COMMIT="228dac9861b4df02de291e270450bd4689715e0d"
CROS_WORKON_TREE=("e00857edce9508718531aba86428bc1ae3c5919a" "f9717b507c2df65dc05165b9415ccd3154b01ecc" "076d90695122ec2235bc1b00ccc2da310da88372" "a6f407634a997b5e8601eba92cf78ac91a286e85" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="attestation common-mk hwsec-test-utils trunks .gn"

PLATFORM_SUBDIR="hwsec-test-utils"

inherit cros-workon platform

DESCRIPTION="Hwsec-related test-only features. This package resides in test images only."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/hwsec-test-utils/"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="test tpm tpm2"
REQUIRED_USE="tpm2? ( !tpm )"

RDEPEND="
	tpm2? (
		chromeos-base/trunks:=
	)
	!tpm2? (
		app-crypt/trousers:=
	)
"

DEPEND="${RDEPEND}
	tpm2? (
		chromeos-base/trunks:=[test?]
	)
	chromeos-base/attestation:=
	chromeos-base/system_api:=
	dev-libs/openssl:=
	dev-libs/protobuf:=
"

src_install() {

	# Installs attestation-injected-keys
	dobin "${OUT}/attestation-injected-keys"

	# Installs hwsec-test-va
	dobin "${OUT}/hwsec-test-va"

	# Install fake pca agent
	insinto /etc/init
	doins fake_pca_agent/fake_pca_agentd.conf
	dobin "${OUT}"/fake_pca_agentd

}

platform_pkg_test() {
	platform_test "run" "${OUT}/hwsec-test-utils_testrunner"
}