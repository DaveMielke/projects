# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="4a356c345ed897adfe2936ae2e6119a46bcd43b8"
CROS_WORKON_TREE="e9f61c485eaea8f4658b885e17c2117cc56831e2"
CROS_WORKON_PROJECT="chromiumos/third_party/khronos"
CROS_WORKON_LOCALNAME="khronos"

inherit scons-utils toolchain-funcs cros-workon

DESCRIPTION="OpenGL|ES mock library"
HOMEPAGE="http://www.khronos.org/opengles/2_X/"
SRC_URI=""

LICENSE="SGI-B-2.0"
SLOT="0"
KEYWORDS="arm x86"
IUSE=""

RDEPEND="x11-libs/libX11
	x11-drivers/opengles-headers"
DEPEND="${RDEPEND}"

src_compile() {
	tc-export AR CC CXX LD NM RANLIB
	escons
}

src_install() {
	dolib libEGL.so libGLESv2.so
}
