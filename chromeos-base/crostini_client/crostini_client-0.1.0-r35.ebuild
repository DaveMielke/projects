# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=6
CROS_WORKON_COMMIT="cc621b27d426c23038b91d973b8fed1a372db8c4"
CROS_WORKON_TREE="30b1b36d9fe425706d87ccd12bb92b5a23b57b2f"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_SUBTREE="vm_tools/crostini_client"
CROS_WORKON_INCREMENTAL_BUILD=1

inherit cros-workon cros-rust

DESCRIPTION="Command-line client for controlling crostini"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/vm_tools/crostini_client/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

DEPEND="chromeos-base/system_api
	=dev-rust/dbus-0.6*:=
	=dev-rust/getopts-0.2*:=
	=dev-rust/lazy_static-1*:=
	>=dev-rust/libc-0.2.44:=
	!>=dev-rust/libc-0.3
	>=dev-rust/protobuf-2.8:=
	!>=dev-rust/protobuf-3
	>=dev-rust/protoc-rust-2.8:=
	!>=dev-rust/protoc-rust-3
"

src_unpack() {
	cros-workon_src_unpack
	# The compilation happens in the crostini_client subdirectory.
	S+="/vm_tools/crostini_client"
	cros-rust_src_unpack
}

src_compile() {
	ecargo_build
	use test && ecargo_test --no-run
}

src_test() {
	if ! use x86 && ! use amd64 ; then
		elog "Skipping unit tests on non-x86 platform"
	else
		ecargo_test --all
	fi
}

src_install() {
	local build_dir="$(cros-rust_get_build_dir)"
	dobin "${build_dir}/crostini_client"
	dosym "crostini_client" "/usr/bin/vmc"
}
