# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="543691dc19366a4e965487e6782da7dfc48a9a19"
CROS_WORKON_TREE="19b3c53c56381bc38419291e9b2bd694dcc5c6ea"
CROS_WORKON_PROJECT="chromium/deps/libmtp"
CROS_WORKON_LOCALNAME="../../chromium/src/third_party/libmtp"

inherit autotools cros-workon

DESCRIPTION="An implementation of Microsoft's Media Transfer Protocol (MTP)."
HOMEPAGE="http://libmtp.sourceforge.net/"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="+crypt doc examples static-libs"

RDEPEND="virtual/libusb:1
	crypt? ( dev-libs/libgcrypt )"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	doc? ( app-doc/doxygen )"

DOCS="AUTHORS ChangeLog README TODO"

src_prepare() {
	if [[ ${PV} == *9999* ]]; then
		touch config.rpath # This is from upstream autogen.sh
		eautoreconf
	fi
}

src_configure() {
	econf \
		$(use_enable static-libs static) \
		$(use_enable doc doxygen) \
		$(use_enable crypt mtpz)
}

src_install() {
	default
	find "${ED}" -name '*.la' -exec rm -f {} +

	if use examples; then
		docinto examples
		dodoc examples/*.{c,h,sh}
	fi
}
