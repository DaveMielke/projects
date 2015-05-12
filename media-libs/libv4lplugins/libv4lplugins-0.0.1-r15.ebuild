# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="819d3d2007134d851c132960108359147adede25"
CROS_WORKON_TREE="5cc0ca0500e0fb64f0440bcdbd66c1e0ffa9f2ae"
CROS_WORKON_PROJECT="chromiumos/third_party/libv4lplugins"
inherit autotools cros-workon eutils

MY_P=v4l-utils-1.6.0

DESCRIPTION="Separate plugin library from upstream v4l-utils package"
HOMEPAGE="http://git.linuxtv.org/v4l-utils.git"
SRC_URI="http://linuxtv.org/downloads/v4l-utils/${MY_P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"
PLUGIN_IUSE="rockchip"
IUSE="${PLUGIN_IUSE}"
REQUIRED_USE="^^ ( ${PLUGIN_IUSE} )"

RDEPEND="media-libs/libv4l"
DEPEND="${RDEPEND}"

S=${WORKDIR}/${MY_P}

src_unpack() {
	cros-workon_src_unpack
	default
}

src_prepare() {
	if use rockchip; then
		PLUGIN_DIR="libv4l-rockchip"
	fi
	mv ${PLUGIN_DIR} lib || die
	# Append "SUBDIRS += ${PLUGIN_DIR}" at the end of lib/Makefile.am
	sed -i -e "\$aSUBDIRS += ${PLUGIN_DIR}" lib/Makefile.am || die
	# Add "lib/${PLUGIN_DIR}/Makefile" after lib/libv4l2rds/Makefile
	sed -i -e "s:libv4l2rds/Makefile:&\n\tlib/${PLUGIN_DIR}/Makefile:" \
		configure.ac || die
	eautoreconf
}

src_configure() {
	econf \
		--disable-static \
		--disable-qv4l2 \
		--disable-v4l-utils \
		--without-jpeg
}

src_compile() {
	emake -C lib/${PLUGIN_DIR}
}

src_install() {
	emake -C lib/${PLUGIN_DIR} DESTDIR="${D}" install
}
