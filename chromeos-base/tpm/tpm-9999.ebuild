# Copyright (c) 2010 The Chromium OS Authors.  All rights reserved.
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI="4"
CROS_WORKON_PROJECT="chromiumos/platform/tpm"
CROS_WORKON_LOCALNAME="../third_party/tpm"

inherit cros-sanitizers cros-workon toolchain-funcs

DESCRIPTION="Various TPM tools"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~*"
IUSE="-asan"

RDEPEND="app-crypt/trousers"
DEPEND="${RDEPEND}"

src_configure() {
	sanitizers-setup-env
	cros-workon_src_configure
}

src_compile() {
	emake -C nvtool CC="$(tc-getCC)"
}

src_install() {
	dobin nvtool/tpm-nvtool
}
