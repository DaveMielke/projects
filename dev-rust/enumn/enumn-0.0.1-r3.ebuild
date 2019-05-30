# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

CROS_WORKON_COMMIT="d7738ec486fbc472e76529355f43eb8ee0e7e820"
CROS_WORKON_TREE="d80b17140cf1a3c017ff4d6679768cf454242597"
CROS_WORKON_LOCALNAME="../platform/crosvm"
CROS_WORKON_PROJECT="chromiumos/platform/crosvm"
# We don't use CROS_WORKON_OUTOFTREE_BUILD here since project's Cargo.toml is
# using "provided by ebuild" macro which supported by cros-rust.
CROS_WORKON_SUBTREE="enumn"

inherit cros-workon cros-rust

DESCRIPTION="Convert number to enum"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/+/master/crosvm/enumn"

LICENSE="BSD-Google"
SLOT="${PV}/${PR}"
KEYWORDS="*"
IUSE="test"

DEPEND="
	=dev-rust/proc-macro2-0.4*
	=dev-rust/quote-0.6*
	=dev-rust/syn-0.15*
"

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
