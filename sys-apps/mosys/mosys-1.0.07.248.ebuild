# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="2"

inherit flag-o-matic toolchain-funcs

DESCRIPTION="Utility for obtaining various bits of low-level system info"
HOMEPAGE="http://mosys.googlecode.com/"
SRC_URI="http://mosys.googlecode.com/files/${PN}-${PV}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
RDEPEND="sys-apps/util-linux"	# for libuuid

src_compile() {
	# Generate a default .config for our target architecture. This will
	# likely become more sophisticated as we broaden board support.
	einfo "using default configuration for $(tc-arch)"
	ARCH=$(tc-arch) make defconfig || die
	if tc-is-cross-compiler ; then
		tc-export AR AS CC CXX LD NM STRIP OBJCOPY
	else
		# workaround that LDFLAGS=-Wl,-O1 would fail
		LDFLAGS=-O2
	fi
	emake || die
}

src_install() {
	dosbin mosys || die
}
