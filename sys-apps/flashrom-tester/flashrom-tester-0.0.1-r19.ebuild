# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

CROS_WORKON_COMMIT="42147cc6d125db94a3f2ac38f482ba34a609f33c"
CROS_WORKON_TREE="63045e788d5ab6ca9f4bd60edd8c6753ef190864"
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
	=dev-rust/log-0.4*:=
	=dev-rust/env_logger-0.6.1:=
	=dev-rust/built-0.3*:=
	=dev-rust/sys-info-0.5.7:=
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
