# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="db9eb2fb535c8928aa9aae50e4ded6b6f2d5f2f0"
CROS_WORKON_TREE=("4d75f59d5b9cba741b59b0d28a456d711d58800c" "7578de769de579ec7f934e22698468366fdc76ea" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk libipp .gn"

PLATFORM_SUBDIR="libipp"

inherit cros-workon platform

DESCRIPTION="The library for building and parsing IPP (Internet Printing Protocol) frames."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/libipp/"

LICENSE="BSD-Google"
KEYWORDS="*"

src_install() {
	dolib.so "${OUT}/lib/libipp.so"

	insinto "/usr/$(get_libdir)/pkgconfig"
	doins libipp.pc

	insinto "/usr/include/chromeos/libipp"
	doins ipp.h ipp_attribute.h ipp_base.h ipp_collections.h ipp_enums.h \
			ipp_export.h ipp_operations.h ipp_package.h

	# Install fuzzer
	platform_fuzzer_install "${S}"/OWNERS "${OUT}"/libipp_fuzzer
}

platform_pkg_test() {
	platform_test "run" "${OUT}/libipp_test"
}