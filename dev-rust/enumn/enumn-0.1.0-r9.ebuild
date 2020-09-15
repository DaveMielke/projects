# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="36b2a0df713d82f1bf178941147c6fb76e2b4cc8"
CROS_WORKON_TREE="c5170d4e4312bcef4a4e4e49403be6bc421c18aa"
CROS_WORKON_LOCALNAME="../platform/crosvm"
CROS_WORKON_PROJECT="chromiumos/platform/crosvm"
# We don't use CROS_WORKON_OUTOFTREE_BUILD here since project's Cargo.toml is
# using "provided by ebuild" macro which supported by cros-rust.
CROS_WORKON_SUBTREE="enumn"

inherit cros-workon cros-rust

DESCRIPTION="Convert number to enum"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/+/master/crosvm/enumn"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="test"

DEPEND="
	=dev-rust/proc-macro2-1*:=
	=dev-rust/quote-1*:=
	=dev-rust/syn-1*:=
"

RDEPEND="!!<=dev-rust/enumn-0.0.1-r4"

src_unpack() {
	cros-workon_src_unpack
	S+="/enumn"

	cros-rust_src_unpack
}

src_compile() {
	use test && ecargo_test --no-run
}

src_test() {
	if use x86 || use amd64; then
		ecargo_test
	else
		elog "Skipping rust unit tests on non-x86 platform"
	fi
}

src_install() {
	cros-rust_publish "${PN}" "$(cros-rust_get_crate_version)"
}