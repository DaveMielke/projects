# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

CROS_WORKON_BLACKLIST=1
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform/core"
CROS_WORKON_PROJECT="platform/system/core"
CROS_WORKON_REPO="https://android.googlesource.com"

inherit cros-workon multilib

DESCRIPTION="Library and cli tools for Android sparse files"
HOMEPAGE="https://android.googlesource.com/platform/system/core"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~*"

RDEPEND="
	sys-libs/zlib
"
DEPEND="
	sys-libs/zlib
"

src_unpack() {
	cros-workon_src_unpack
	S+="/${PN}"
}

src_prepare() {
	cp "${FILESDIR}/Makefile" "${S}" || die "Copying Makefile"
}

src_configure() {
	export GENTOO_LIBDIR=$(get_libdir)
	tc-export CC
	default
}
