# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

CROS_WORKON_COMMIT="ab1cb3e54fd07f106a6d6c9a2e48bb4451bc2734"
CROS_WORKON_TREE="None"
CROS_WORKON_LOCALNAME="third_party/cups"
CROS_WORKON_PROJECT="chromiumos/third_party/cups"
CROS_WORKON_SUBTREE="fuzzers"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-fuzzer cros-sanitizers cros-workon flag-o-matic libchrome toolchain-funcs

DESCRIPTION="Fuzzer for PPD and IPP functions in CUPS"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="asan fuzzer"

RDEPEND="net-print/cups[fuzzer]"
DEPEND="${RDEPEND}"

# We really don't want to be building this otherwise.
REQUIRED_USE="fuzzer"

src_unpack() {
	cros-workon_src_unpack
}

src_configure() {
	sanitizers-setup-env || die
	fuzzer-setup-binary || die
	append-ldflags "$(${CHOST}-cups-config --libs)"
	append-ldflags "$($(tc-getPKG_CONFIG) --libs libchrome-${BASE_VER})"
	append-cppflags "$($(tc-getPKG_CONFIG) --cflags libchrome-${BASE_VER})"
}

src_compile() {
	local build_dir="$(cros-workon_get_build_dir)"
	VPATH="${S}"/fuzzers emake -C "${build_dir}" cups_ppdopen_fuzzer
	VPATH="${S}"/fuzzers emake -C "${build_dir}" cups_ippreadio_fuzzer
}

src_install() {
	local build_dir="$(cros-workon_get_build_dir)"
	fuzzer_install "${S}"/fuzzers/OWNERS "${build_dir}"/cups_ppdopen_fuzzer
	fuzzer_install "${S}"/fuzzers/OWNERS "${build_dir}"/cups_ippreadio_fuzzer
}
