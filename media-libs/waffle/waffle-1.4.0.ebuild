# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/waffle/waffle-1.3.0.ebuild,v 1.2 2013/12/28 11:29:05 vapier Exp $

EAPI=5

inherit cmake-utils

DESCRIPTION="Library that allows selection of GL API and of window system at runtime"
HOMEPAGE="http://www.waffle-gl.org"
SRC_URI="http://www.waffle-gl.org/files/release/${P}/${P}.tar.xz"
LICENSE="BSD-2"
SLOT="0"
KEYWORDS="*"
IUSE="doc examples gbm opengl opengles test wayland"

# Note: Chrome OS currently uses the following USE flags:
#   opengl   => GLX and OpenGL
#   opengles => EGL and OpenGL ES
# TODO: sync USE flags with upstream gentoo: crbug.com/375298

REQUIRED_USE="
	|| ( gbm opengl opengles wayland )
	"

RDEPEND="
	opengl? ( virtual/opengl )
	wayland? ( >=dev-libs/wayland-1.0 )
	opengles? ( virtual/opengles )
	gbm? ( media-libs/mesa[gbm] )
	gbm? ( virtual/udev )
	x11-libs/libX11
	x11-libs/libxcb"

DEPEND="${RDEPEND}
	x11-proto/xcb-proto
	opengl? ( x11-proto/glproto )
	doc? (
		dev-libs/libxslt
		app-text/docbook-xml-dtd:4.2
	)"

src_prepare() {
	epatch "${FILESDIR}"/${P}-Do-not-use-the-PRIVATE-annotation.patch
}

src_configure() {
	local mycmakeargs=(
		$(cmake-utils_use opengles waffle_has_x11_egl)
		$(cmake-utils_use gbm waffle_has_gbm)
		$(cmake-utils_use wayland waffle_has_wayland)
		$(cmake-utils_use opengl waffle_has_glx)

		$(cmake-utils_use doc waffle_build_manpages)
		$(cmake-utils_use examples waffle_build_examples)
		$(cmake-utils_use test waffle_build_tests)
	)

	cmake-utils_src_configure
}

src_test() {
	emake -C "${CMAKE_BUILD_DIR}" check
}
