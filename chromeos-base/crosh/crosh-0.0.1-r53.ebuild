# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="90d5bf5b1e3066933e9a52911d5b177a189e014d"
CROS_WORKON_TREE="e697cf9b1c73c0c29a60687121c1fdf3811366eb"

EAPI=2
CROS_WORKON_PROJECT="chromiumos/platform/crosh"

# Files from chromeos-wm are being moved to this package; ensure that we don't
# get conflicts by installing this and an old version of chromeos-wm at the
# same time.
CONFLICT_LIST="chromeos-base/chromeos-wm-0.0.1-r230"
inherit cros-workon toolchain-funcs conflict

DESCRIPTION="Chrome OS command-line shell"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"

RDEPEND="chromeos-base/vboot_reference
	net-misc/iputils
	net-wireless/iw
	sys-apps/net-tools
	x11-terms/rxvt-unicode"
DEPEND=""

src_install() {
	dobin cros-term
	dobin crosh
	dobin crosh-dev
	dobin crosh-usb
	dobin inputrc.crosh
	dobin network_diagnostics
}
