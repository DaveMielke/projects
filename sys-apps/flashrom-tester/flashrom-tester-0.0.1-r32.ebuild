# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

CROS_WORKON_COMMIT="e5cd4db5f8e55be6e8d5dd0a8806504acd349ce9"
CROS_WORKON_TREE="9850cac59d26f6d3267f8a152e3035e995fc04cd"
CROS_WORKON_USE_VCSID="1"
CROS_WORKON_PROJECT="chromiumos/third_party/flashrom"
CROS_WORKON_LOCALNAME="flashrom"
CROS_WORKON_SUBTREE="util/flashrom_tester"
CROS_WORKON_SUBDIRS_TO_COPY="util/flashrom_tester"

inherit cros-workon cros-rust

DESCRIPTION="Utility for AVL qualification of SPI flash chips with flashrom"
HOMEPAGE="https://www.flashrom.org/Flashrom"

LICENSE="GPL-2"
SLOT="${PV}/${PR}"
KEYWORDS="*"
DEPEND=">=dev-rust/rand-0.6.4:=
	=dev-rust/chrono-0.4*:=
	=dev-rust/clap-2.33*:=
	=dev-rust/log-0.4*:=
	=dev-rust/built-0.3*:=
	=dev-rust/sys-info-0.5.7:=
	=dev-rust/serde_json-1*:=
"

src_unpack() {
	cros-workon_src_unpack
	S=$S/$CROS_WORKON_SUBTREE
	cros-rust_src_unpack
}

src_compile() {
	# Override HOST_CFLAGS so that build dependencies use the correct
	# flags on cross-compiled targets using cc-rs.
	tc-export_build_env
	export HOST_CFLAGS="${BUILD_CFLAGS}"
	ecargo_build
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
	dobin "$(cros-rust_get_build_dir)/flashrom_tester"
}
