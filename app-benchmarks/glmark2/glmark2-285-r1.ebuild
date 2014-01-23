# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit toolchain-funcs waf-utils

DESCRIPTION="OpenGL (ES) 2.0 benchmark"
HOMEPAGE="https://launchpad.net/glmark2"
# Note: the last tarball hosted on launchpad is 2012.12.tar.gz
# More recent versions are Chromium localmirror hosted tarballs created from
# bzr releases of https://code.launchpad.net/~glmark2-dev/glmark2/trunk
#SRC_URI="http://launchpad.net/${PN}/trunk/${PV}/+download/${P}.tar.gz"
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${PN}-bzr-${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"
IUSE="drm opengles opengl"

REQUIRED_USE="
	|| ( opengl opengles )
	"

RDEPEND="media-libs/libpng
	opengles? ( virtual/opengles )
	opengl? ( virtual/opengl )
	x11-libs/libX11
	drm? ( media-libs/mesa[gbm] )
	virtual/jpeg"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

PATCHES=(
	"${FILESDIR}/0001-native-state-x11-Don-t-terminate-fullscreen-if-EWMH-.patch"
)

src_configure() {
	local myconf=""
	local flavors=()

	if use opengl; then
		flavors+=(x11-gl)
	fi

	if use opengles; then
		flavors+=(x11-glesv2)
	fi

	if use drm; then
		if use opengl; then
			flavors+=(drm-gl)
		fi

		if use opengles; then
			flavors+=(drm-glesv2)
		fi
	fi

	if [ ${#flavors[@]} -gt 0 ]; then
		SAVED_IFS=${IFS}
		IFS=","
		myconf+="--with-flavors=${flavors[*]}"
		IFS=${SAVED_IFS}
	fi

	export PKGCONFIG=$(tc-getPKG_CONFIG)
	waf-utils_src_configure ${myconf}
}
