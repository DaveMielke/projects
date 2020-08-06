# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

CROS_RUST_REMOVE_DEV_DEPS=1
inherit cros-rust

DESCRIPTION="A Rust library for creating intrusive collections"
HOMEPAGE="https://github.com/Amanieu/intrusive-rs"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND=">=dev-rust/memoffset-0.5.4:= <dev-rust/memoffset-0.6"
