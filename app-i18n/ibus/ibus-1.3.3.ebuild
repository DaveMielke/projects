# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="2"
inherit eutils multilib python cros-workon

DESCRIPTION="Intelligent Input Bus for Linux / Unix OS"
HOMEPAGE="http://code.google.com/p/ibus/"
# SRC_URI="http://ibus.googlecode.com/files/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="doc nls python"

RDEPEND="app-text/iso-codes
	python? ( >=dev-lang/python-2.5 )
	>=dev-libs/glib-2.18
	python? ( >=dev-python/pygobject-2.14 )
	>=gnome-base/librsvg-2
	sys-apps/dbus
	nls? ( virtual/libintl )
	>=x11-libs/gtk+-2
	x11-libs/libX11"
DEPEND="${RDEPEND}
	doc? ( >=dev-util/gtk-doc-1.9 )
	dev-util/pkgconfig
	nls? ( >=sys-devel/gettext-0.16.1 )"
RDEPEND="${RDEPEND}
	python? ( >=dev-python/dbus-python-0.83 )
	python? ( dev-python/pygtk )
	python? ( dev-python/pyxdg )"

CROS_WORKON_SUBDIR="files"

pkg_setup() {
	# An arch specific config directory is used on multilib systems
	has_multilib_profile && GTK2_CONFDIR="/etc/gtk-2.0/${CHOST}"
	GTK2_CONFDIR=${GTK2_CONFDIR:=/etc/gtk-2.0/}
}

src_unpack() {
	cros-workon_src_unpack
	cd "${S}"
	ln -s "$(type -P true)" py-compile || die
}

src_prepare() {
	NOCONFIGURE=1 ./autogen.sh
}

src_configure() {
	econf \
		--disable-gconf \
		--disable-key-snooper \
		$(use_enable doc gtk-doc) \
		$(use_enable nls) \
		$(use_enable python) || die
}

src_compile() {
	emake || die
}

src_install() {
	local third_party="${CHROMEOS_ROOT}/src/third_party"

	emake DESTDIR="${D}" install || die
	if [ -f "${D}/usr/share/ibus/component/gtkpanel.xml" ] ; then
		rm "${D}/usr/share/ibus/component/gtkpanel.xml" || die
	fi
	cp "${S}/candidate_window.xml" "${D}/usr/share/ibus/component/" || die
	chmod 644 "${D}/usr/share/ibus/component/candidate_window.xml" || die
	dodoc AUTHORS ChangeLog NEWS README
}

pkg_postinst() {

	elog "To use ibus, you should:"
	elog "1. Get input engines from sunrise overlay."
	elog "   Run \"emerge -s ibus-\" in your favorite terminal"
	elog "   for a list of packages we already have."
	elog
	elog "2. Setup ibus:"
	elog
	elog "   $ ibus-setup"
	elog
	elog "3. Set the following in your user startup scripts"
	elog "   such as .xinitrc, .xsession or .xprofile:"
	elog
	elog "   export XMODIFIERS=\"@im=ibus\""
	elog "   export GTK_IM_MODULE=\"ibus\""
	elog "   export QT_IM_MODULE=\"xim\""
	elog "   ibus-daemon -d -x"

        # TODO(yusukes): Add support for a "--root=" option to gtk-query-immodules-2.0 and try to get it upstream.
	( echo '/usr/lib/gtk-2.0/2.10.0/immodules/im-ibus.so';
	  echo '"ibus" "IBus (Intelligent Input Bus)" "ibus" "" "ja:ko:zh:*"' ) > "${ROOT}/${GTK2_CONFDIR}/gtk.immodules"

	if use python; then
		python_mod_optimize /usr/share/${PN}
	fi
}

pkg_postrm() {
	[ "${ROOT}" = "/" -a -x /usr/bin/gtk-query-immodules-2.0 ] && \
		gtk-query-immodules-2.0 > "${ROOT}/${GTK2_CONFDIR}/gtk.immodules"

	if use python; then
		python_mod_cleanup /usr/share/${PN}
	fi
}
