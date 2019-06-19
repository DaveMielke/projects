# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

CROS_WORKON_COMMIT="fb00b462dc21980b1e1056468e5158c0e44aa670"
CROS_WORKON_TREE="dddebfe3cdcac4e719b16ebd715802cbba7de098"
CROS_WORKON_LOCALNAME="../platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_SUBTREE="cros-fuzz"

inherit cros-workon cros-rust

DESCRIPTION="Support crate for running rust fuzzers on Chrome OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/cros-fuzz"

LICENSE="BSD-Google"
SLOT="0/${PR}"
KEYWORDS="*"
IUSE="test"

DEPEND="
	=dev-rust/rand_core-0.4*:=
"

src_unpack() {
	cros-workon_src_unpack
	S+="/cros-fuzz"

	cros-rust_src_unpack
}

src_compile() {
	use test && ecargo_test --no-run
}

src_test() {
	if ! use x86 && ! use amd64 ; then
		elog "Skipping unit tests on non-x86 platform"
	else
		ecargo_test
	fi
}

src_install() {
	cros-rust_publish "${PN}" "$(cros-rust_get_crate_version)"
}
