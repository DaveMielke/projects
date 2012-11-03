# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# TODO(msb): move this ebuild to net-dns/minifakedns
EAPI=2
CROS_WORKON_COMMIT="6184bea119dea53da539727fe8c2a116f98cef24"
CROS_WORKON_TREE="efb76b27f1af4db93b7c8d48910de14400fbbd37"
CROS_WORKON_PROJECT="chromiumos/third_party/minifakedns"

inherit python cros-workon

DESCRIPTION="Minimal python dns server"
HOMEPAGE="http://code.activestate.com/recipes/491264-mini-fake-dns-server/"
LICENSE="PSF"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

RDEPEND="dev-lang/python"

DEPEND="${RDEPEND}"

CROS_WORKON_LOCALNAME="../third_party/miniFakeDns"

src_install() {
	insinto "$(python_get_sitedir)"
	doins "src/miniFakeDns.py" || die
}
