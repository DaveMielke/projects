# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="05dc5658ce5a1787d7b9122bc40c9ece7c044c35"
CROS_WORKON_TREE="ab99454bf7745ba58b651e745e452435ec8e370c"
CROS_WORKON_PROJECT="chromiumos/third_party/dbus-cplusplus"

inherit cros-workon autotools

DESCRIPTION="C++ D-Bus bindings"
HOMEPAGE="http://www.freedesktop.org/wiki/Software/dbus-c%2B%2B"
SRC_URI=""

LICENSE="LGPL-2"
SLOT="1"
KEYWORDS="amd64 arm x86"
IUSE="debug doc +glib"

RDEPEND="
	glib? ( >=dev-libs/dbus-glib-0.76 )
	glib? ( >=dev-libs/glib-2.19:2 )
	>=sys-apps/dbus-1.0
	>=dev-cpp/ctemplate-1.0"
DEPEND="${DEPEND}
	doc? ( dev-libs/libxslt )
	doc? ( app-doc/doxygen )
	virtual/pkgconfig"

src_prepare() {
	eautoreconf
}

src_configure() {
	econf \
		$(use_enable debug) \
		$(use_enable doc doxygen-docs) \
		$(use_enable glib glib)
}
