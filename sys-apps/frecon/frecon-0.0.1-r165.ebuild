# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

CROS_WORKON_COMMIT="bb728f37f27258ca6e25459ec0092cc8ecde0678"
CROS_WORKON_TREE="de01d9a6f273603048c7600c4bfa68b18baf1d02"
CROS_WORKON_PROJECT="chromiumos/platform/frecon"
CROS_WORKON_LOCALNAME="../platform/frecon"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_INCREMENTAL_BUILD=1

inherit cros-sanitizers cros-workon cros-common.mk toolchain-funcs

DESCRIPTION="Chrome OS KMS console"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/frecon"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan"

RDEPEND="virtual/udev
	sys-apps/dbus
	media-libs/libpng:0=
	sys-apps/libtsm
	x11-libs/libdrm"

DEPEND="${RDEPEND}
	media-sound/adhd
	virtual/pkgconfig"

src_configure() {
	sanitizers-setup-env
	cros-common.mk_src_configure
}

src_install() {
	insinto /etc/dbus-1/system.d
	doins dbus/org.chromium.frecon.conf
	default
}
