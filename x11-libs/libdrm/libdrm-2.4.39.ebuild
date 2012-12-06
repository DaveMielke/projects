# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libdrm/libdrm-2.4.34.ebuild,v 1.1 2012/05/11 00:25:45 chithanh Exp $

EAPI=4
inherit xorg-2

EGIT_REPO_URI="git://anongit.freedesktop.org/git/mesa/drm"

DESCRIPTION="X.Org libdrm library"
HOMEPAGE="http://dri.freedesktop.org/"
if [[ ${PV} = 9999* ]]; then
	SRC_URI=""
else
	SRC_URI="http://dri.freedesktop.org/${PN}/${P}.tar.bz2"
fi

KEYWORDS="~alpha amd64 arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc x86 ~amd64-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~amd64-linux ~x86-linux ~sparc-solaris ~x64-solaris ~x86-solaris"
VIDEO_CARDS="intel nouveau radeon vmware armsoc"
for card in ${VIDEO_CARDS}; do
	IUSE_VIDEO_CARDS+=" video_cards_${card}"
done

IUSE="${IUSE_VIDEO_CARDS} libkms tests"
RESTRICT="test" # see bug #236845

RDEPEND="dev-libs/libpthread-stubs
	video_cards_intel? ( >=x11-libs/libpciaccess-0.10 )"
DEPEND="${RDEPEND}"

pkg_setup() {
	XORG_CONFIGURE_OPTIONS=(
		--enable-udev
		$(use_enable video_cards_intel intel)
		$(use_enable video_cards_nouveau nouveau)
		$(use_enable video_cards_radeon radeon)
		$(use_enable video_cards_vmware vmwgfx-experimental-api)
		# Up until (and including) libdrm 2.4.34, the armsoc X11 driver is still
		# using the omap DRM component, as the generic armsoc component does not
		# yet exist.
		# https://code.google.com/p/chrome-os-partner/issues/detail?id=10055
		$(use_enable video_cards_armsoc omap-experimental-api)
		$(use_enable libkms)
	)

	xorg-2_pkg_setup
}

src_prepare() {
	if [[ ${PV} = 9999* ]] && ! use tests; then
		# tests are restricted, no point in building them
		sed -ie 's/tests //' "${S}"/Makefile.am
	fi
	xorg-2_src_prepare
}

src_install() {
	xorg-2_src_install

	if use tests; then
		into /usr/local/
		dobin "${AUTOTOOLS_BUILD_DIR}"/tests/*/.libs/*
	fi
}