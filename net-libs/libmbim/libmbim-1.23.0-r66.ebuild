# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
CROS_WORKON_COMMIT="d2b6a27fedc42e668b37edb4a2d613b7ce3c6f88"
CROS_WORKON_TREE="fe93d9f752d8756304679f7da27aeea49c9a1137"
CROS_WORKON_PROJECT="chromiumos/third_party/libmbim"

inherit autotools cros-sanitizers cros-workon multilib

DESCRIPTION="MBIM modem protocol helper library"
HOMEPAGE="http://cgit.freedesktop.org/libmbim/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="-asan doc static-libs"

RDEPEND=">=dev-libs/glib-2.36
	virtual/libgudev"

DEPEND="${RDEPEND}
	doc? ( dev-util/gtk-doc )
	virtual/pkgconfig"

src_prepare() {
	default
	gtkdocize
	eautoreconf
}

src_configure() {
	sanitizers-setup-env

	econf \
		--enable-mbim-username='modem' \
		--enable-compile-warnings=yes \
		$(use_enable static{-libs,}) \
		$(use_enable {,gtk-}doc)
}

src_test() {
	# TODO(benchan): Run unit tests for non-x86 platforms via qemu.
	[[ "${ARCH}" == "x86" || "${ARCH}" == "amd64" ]] && emake check
}

src_install() {
	default
	use static-libs || rm -f "${ED}"/usr/$(get_libdir)/libmbim-glib.la
}
