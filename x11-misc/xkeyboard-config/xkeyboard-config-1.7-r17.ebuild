# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/xkeyboard-config/xkeyboard-config-1.7.ebuild,v 1.11 2010/01/19 20:28:30 armin76 Exp $

EAPI="2"
SRC_URI="http://xlibs.freedesktop.org/xkbdesc/${P}.tar.bz2"

inherit autotools eutils

DESCRIPTION="X keyboard configuration database"
HOMEPAGE="http://www.freedesktop.org/wiki/Software/XKeyboardConfig"

KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE=""

LICENSE="MIT"
SLOT="0"

RDEPEND="x11-apps/xkbcomp"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.30
	dev-libs/glib
	dev-perl/XML-Parser"

src_prepare() {
	# We should not assign modifier keys (Alt_L, Meta_L, and <LWIN>) in
	# symbols/{pc,altwin} since they are assigned in symbols/chromeos.
	epatch "${FILESDIR}/${P}-modifier-keys.patch"

	epatch "${FILESDIR}/${P}-XFER-jp-keyboard.patch"
	epatch "${FILESDIR}/${P}-be-keyboard.patch"
	epatch "${FILESDIR}/${P}-no-keyboard.patch"
	epatch "${FILESDIR}/${P}-symbols-makefile.patch"
	epatch "${FILESDIR}/${P}-backspace-and-arrow-keys.patch"

	# Generate symbols/chromeos.
	python "${FILESDIR}"/gen_symbols_chromeos.py > symbols/chromeos || die

	# Regenerate symbols/symbols.dir.
	pushd symbols/
	xkbcomp -lfhlpR '*' > symbols.dir || die
	popd
	# Regenerate symbols/Makefile.in from the patched symbols/Makefile.am.
	autoreconf -v --install || die
}

src_configure() {
	econf \
		--with-xkb-base=/usr/share/X11/xkb \
		--enable-compat-rules \
		--disable-xkbcomp-symlink \
		--with-xkb-rules-symlink=xorg \
		|| die "configure failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "install failed"
	echo "CONFIG_PROTECT=\"/usr/share/X11/xkb\"" > "${T}"/10xkeyboard-config
	doenvd "${T}"/10xkeyboard-config
}
