# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="d08caf99441bc4fa88662a82eb7238c21277dca0"
CROS_WORKON_TREE="0cce83b200bb1844079302c0e5dfa1d551d6562e"

EAPI=3
CROS_WORKON_PROJECT="chromiumos/third_party/multitouch"

XORG_EAUTORECONF="yes"
BASE_INDIVIDUAL_URI=""
inherit linux-info xorg-2 cros-workon

DESCRIPTION="Multitouch Xorg Xinput driver."
HOMEPAGE="http://bitmath.org/code/multitouch/"
CROS_WORKON_LOCALNAME="multitouch"

KEYWORDS="arm x86"
LICENSE="GPL"
SLOT="0"
IUSE=""

RDEPEND="x11-base/xorg-server
	 x11-libs/mtdev
	 x11-libs/pixman"
DEPEND="${RDEPEND}
	x11-proto/inputproto"

src_prepare() {
	xorg-2_src_prepare
}

src_install() {
	DOCS="README" xorg-2_src_install
}

pkg_postinst() {
	xorg-2_pkg_postinst
}
