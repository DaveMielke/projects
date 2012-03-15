# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# Based on gentoo's modemmanager ebuild

EAPI="4"
CROS_WORKON_COMMIT="cc351b7a3e5c498d0d1aabcc4a32fb0228f57f90"
CROS_WORKON_PROJECT="chromiumos/third_party/modemmanager-next"

inherit eutils autotools cros-workon

# ModemManager likes itself with capital letters
MY_P=${P/modemmanager/ModemManager}

DESCRIPTION="Modem and mobile broadband management libraries"
HOMEPAGE="http://mail.gnome.org/archives/networkmanager-list/2008-July/msg00274.html"
#SRC_URI not defined because we get our source locally

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="doc"

RDEPEND=">=dev-libs/glib-2.30.2
        >=sys-apps/dbus-1.2
        dev-libs/dbus-glib
        net-dialup/ppp
        !net-misc/modemmanager
        "

DEPEND=">=sys-fs/udev-145[gudev]
        dev-util/pkgconfig
        dev-util/intltool
        >=dev-util/gtk-doc-1.13
        !net-misc/modemmanager-next-interfaces
        !net-misc/modemmanager
        "

DOCS="AUTHORS ChangeLog NEWS README"

src_prepare() {
	gtkdocize || die "gtkdocize failed"
	eautopoint
	eautoreconf
	intltoolize --force
}

src_configure() {
	econf \
		--with-html-dir="\${datadir}/doc/${PF}/html" \
		$(use_with doc docs)
}

src_install() {
	default
	# Remove useless .la files
	find "${D}" -name '*.la' -delete
	insinto /etc/init
	doins "${FILESDIR}/modemmanager.conf"
}
