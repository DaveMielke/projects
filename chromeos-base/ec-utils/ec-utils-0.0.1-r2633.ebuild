# Copyright 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="47ff569b68a0219c0eb8b0fd5e9796863abc97c3"
CROS_WORKON_TREE="33917ec7490a8a342f0805cd6346c1d9a738c8a6"
CROS_WORKON_PROJECT="chromiumos/platform/ec"
CROS_WORKON_LOCALNAME="ec"

inherit cros-workon cros-ec-board

DESCRIPTION="Chrome OS EC Utility"

HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang static"
REQUIRED_USE="asan? ( clang )"

RDEPEND="dev-embedded/libftdi"
DEPEND="${RDEPEND}"

set_board() {
	# bds should be fine for everyone, but for link board, we need to fetch
	# .conf file.
	# Given we only compile the host tootls, having an EC board specified does
	# not change the generated binaries: the utils binaries are identical
	# regardless of the board chosen.
	get_ec_boards
	export BOARD="${EC_BOARDS[0]}"
}

src_configure() {
	clang-setup-env
	cros-workon_src_configure
}

src_compile() {
	tc-export AR CC RANLIB
	# In platform/ec Makefile, it uses "CC" to specify target chipset and
	# "HOSTCC" to compile the utility program because it assumes developers
	# want to run the utility from same host (build machine).
	# In this ebuild file, we only build utility
	# and we may want to build it so it can
	# be executed on target devices (i.e., arm/x86/amd64), not the build
	# host (BUILDCC, amd64). So we need to override HOSTCC by target "CC".
	export HOSTCC="${CC} $(usex static '-static' '')"
	set_board
	emake utils-host
}

src_install() {
	set_board
	dosbin "build/$BOARD/util/ectool"
	dosbin "build/$BOARD/util/ec_sb_firmware_update"
	if [[ -d "board/${BOARD}/userspace/etc/init" ]] ; then
		insinto /etc/init
		doins board/${BOARD}/userspace/etc/init/*.conf
	fi
	if [[ -d "board/${BOARD}/userspace/usr/share/ec" ]] ; then
		insinto /usr/share/ec
		doins board/${BOARD}/userspace/usr/share/ec/*
	fi
}
