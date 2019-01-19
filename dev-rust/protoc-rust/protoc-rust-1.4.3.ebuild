# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit cros-rust

DESCRIPTION="protoc --rust_out=... available as API. protoc needs to be in $PATH, protoc-gen-run does not"
HOMEPAGE="https://github.com/stepancheg/rust-protobuf/protoc-rust/"
SRC_URI="https://crates.io/api/v1/crates/${PN}/${PV}/download -> ${P}.crate"

LICENSE="|| ( MIT Apache-2.0 )"
SLOT="${PV}/${PR}"
KEYWORDS="*"

DEPEND="
	~dev-rust/protobuf-1.4.3:=
	~dev-rust/protoc-1.4.3:=
	~dev-rust/tempdir-0.3.7:=
"
