# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=6

CROS_WORKON_COMMIT="2bc6c5f46a8d9ad66b6b78fbbdf724bd66bf2a10"
CROS_WORKON_TREE=("1c9dedfb489b146ba061dcc365b6be84de5528d8" "c3c0b0f6948d2df5441409e471f0391b3281dd04" "d8ac2ad180aa54028a051524d3717bd021e37f0c" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
# TODO(crbug.com/809389): Avoid directly including headers from other packages.
CROS_WORKON_SUBTREE="common-mk libtpmcrypto trunks .gn"

PLATFORM_SUBDIR="libtpmcrypto"

inherit cros-workon platform

DESCRIPTION="Encrypts/Decrypts data to a serialized proto with TPM sealed key."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/libtpmcrypto/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="tpm tpm2"
REQUIRED_USE="tpm2? ( !tpm )"

# This depends on protobuf because it uses protoc and needs to be rebuilt
# whenever the protobuf library is updated since generated source files may be
# incompatible across different versions of the protobuf library.
RDEPEND="
	tpm2? (
		chromeos-base/trunks
	)
	!tpm2? (
		app-crypt/trousers
	)
	dev-libs/protobuf:=
"

DEPEND="
	${RDEPEND}
"

src_install() {
	dolib.so "${OUT}/lib/libtpmcrypto.so"

	"${S}"/platform2_preinstall.sh "${PV}" "/usr/include/chromeos" "${OUT}"
	insinto "/usr/$(get_libdir)/pkgconfig"
	doins "${OUT}/libtpmcrypto.pc"

	insinto "/usr/include/libtpmcrypto"
	doins *.h
}

platform_pkg_test() {
	local tests=(
		tpmcrypto_test
	)
	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}
