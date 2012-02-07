# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# Based on gentoo's modemmanager ebuild

EAPI=2
CROS_WORKON_COMMIT="54c6328e20d57a0246a87f8f787e34bdc87b81fc"
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
IUSE=""

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
        !net-misc/modemmanager
        "

src_prepare() {
	gtkdocize || die "gtkdocize failed"
	eautopoint
	eautoreconf
	intltoolize --force
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog NEWS README
	insinto /etc/init
	doins "${FILESDIR}/modemmanager.conf"
}
