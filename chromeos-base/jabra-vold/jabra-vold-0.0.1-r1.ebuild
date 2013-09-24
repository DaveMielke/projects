# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
CROS_WORKON_COMMIT="0540b3bddfb7390f3703c385118526921a025986"
CROS_WORKON_TREE="c11070f3f0becb144c8b7f6bdced9f2787b23fba"
CROS_WORKON_PROJECT="chromiumos/platform/jabra_vold"
CROS_WORKON_LOCALNAME="jabra_vold"

inherit cros-workon toolchain-funcs

DESCRIPTION="A simple daemon to handle Jabra speakerphone volume change"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"

RDEPEND=">=media-libs/alsa-lib-1.0"
DEPEND="${RDEPEND}"

src_compile() {
	tc-export CC PKG_CONFIG

	emake
}

src_install() {
	dosbin jabra_vold

	insinto /etc/udev/rules.d
	doins 99-jabra.rules

	insinto /etc/init
	doins jabra-vold.conf
}
