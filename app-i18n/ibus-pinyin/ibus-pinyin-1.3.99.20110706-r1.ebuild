# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-i18n/ibus-pinyin/ibus-pinyin-1.2.0.20090915.ebuild,v 1.1 2009/09/15 15:11:20 matsuu Exp $

EAPI="2"

inherit eutils flag-o-matic

#PYDB_TAR="pinyin-database-0.1.10.6.tar.bz2"
DESCRIPTION="Chinese PinYin IMEngine for IBus Framework"
HOMEPAGE="http://code.google.com/p/ibus/"
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="nls"

# TODO(yusukes): Ask someone if we should support Open Phrase DB or not.

RDEPEND=">=app-i18n/ibus-1.3.99
	>=dev-db/sqlite-3.6.18
	nls? ( virtual/libintl )"

DEPEND="${RDEPEND}
	dev-util/pkgconfig
	nls? ( >=sys-devel/gettext-0.16.1 )"

src_prepare() {
	# TODO(penghuang): Remove those patches when update to new tarball.
	epatch "${FILESDIR}"/0001-Exit-if-config-component-is-not-ready-instead-of-cra.patch
	epatch "${FILESDIR}"/0002-Fix-some-issues-which-may-cause-crash-likely.patch

	# disable bopomofo, enable pinyin-dv, and change the cache directory.
	epatch "${FILESDIR}"/ibus-pinyin-cros.patch
}

src_configure() {
	econf $(use_enable nls) --disable-boost || die
}

src_compile() {
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die
	# Remove all Python related files
	rm "${D}/usr/libexec/ibus-setup-pinyin" || die
	rm -rf "${D}/usr/share/ibus-pinyin/setup" || die
	rm -rf "${D}/usr/share/ibus-pinyin/icons" || die
	dodoc AUTHORS ChangeLog NEWS README
}

pkg_postinst() {
	ewarn "This package is very experimental, please report your bugs to"
	ewarn "http://ibus.googlecode.com/issues/list"
	elog
	elog "You should run ibus-setup and enable IM Engines you want to use!"
	elog
}
