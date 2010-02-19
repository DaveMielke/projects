# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs

DESCRIPTION="Chrome OS base library."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

DEPEND="dev-libs/dbus-glib"

# TODO: Ideally this is only a build depend, but there is an ordering
# issue where we need to make sure that libchrome is built first.
RDEPEND="chromeos-base/libchrome
	dev-libs/dbus-glib
	dev-libs/libpcre"

src_unpack() {
	local common="${CHROMEOS_ROOT}/src/common/"
	elog "Using common: $common"
	mkdir -p "${S}"
	cp -a "${common}"/* "${S}" || die
}

src_compile() {
	if tc-is-cross-compiler ; then
		tc-getCC
		tc-getCXX
		tc-getAR
		tc-getRANLIB
		tc-getLD
		tc-getNM
		export PKG_CONFIG_PATH="${ROOT}/usr/lib/pkgconfig/"
		export CCFLAGS="$CFLAGS"
	fi

	scons || die "third_party/chrome compile failed."
}

src_install() {
	dodir "/usr/lib"
	dodir "/usr/include/chromeos"
	dodir "/usr/include/chromeos/dbus"
	dodir "/usr/include/chromeos/glib"

	insopts -m0644
	insinto "/usr/lib"
	doins "${S}/libchromeos.a"

	insinto "/usr/include/chromeos"
	doins "${S}/chromeos/callback.h"
	doins "${S}/chromeos/exception.h"
	doins "${S}/chromeos/obsolete_logging.h"
	doins "${S}/chromeos/string.h"
	doins "${S}/chromeos/utility.h"

	insinto "/usr/include/chromeos/dbus"
	doins "${S}/chromeos/dbus/abstract_dbus_service.h"
	doins "${S}/chromeos/dbus/dbus.h"
	doins "${S}/chromeos/dbus/service_constants.h"

	insinto "/usr/include/chromeos/glib"
	doins "${S}/chromeos/glib/object.h"
}
