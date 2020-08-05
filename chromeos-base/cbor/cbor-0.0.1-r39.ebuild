# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT=("f8d0f6ce00239e339c164c792481e996d3948ee1" "2f808cae22b72aab029623efad3d9a71440ac6a1")
CROS_WORKON_TREE=("638bfde957a502ad58d182712c1ebdf335f9a3da" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb" "64ddc93776d2e8ce9987bcce636e68a05565c96f")
CROS_WORKON_PROJECT=(
	"chromiumos/platform2"
	"chromiumos/platform/cbor"
)

CROS_WORKON_LOCALNAME=(
	"platform2"
	"platform/cbor"
)

CROS_WORKON_DESTDIR=(
	"${S}/platform2"
	# This needs to be platform2/cbor instead of platform/cbor because we are
	# using the platform2 build system.
	"${S}/platform2/cbor"
)

CROS_WORKON_SUBTREE=("common-mk .gn" "")

PLATFORM_SUBDIR="cbor"

inherit cros-workon platform

DESCRIPTION="Concise Binary Object Representation (CBOR) library for Chromium OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/cbor"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

src_install() {
	dolib.so "${OUT}"/lib/libcbor.so
	insinto /usr/include/chromeos/cbor/
	doins ./*.h
	insinto "/usr/$(get_libdir)/pkgconfig"
	doins "${OUT}"/obj/cbor/cbor.pc

	platform_fuzzer_install "${S}/OWNERS" "${OUT}"/reader_fuzzer
}

platform_pkg_test() {
	platform_test "run" "${OUT}/cbor_unittests"
}
