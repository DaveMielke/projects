# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="5fe744ca3cb9616f006f06675cf434ac36c4fec7"
CROS_WORKON_TREE="846f597411845048446c80038fe5022dfb8442ee"

EAPI=2
CROS_WORKON_PROJECT="chromiumos/third_party/chrontel"

inherit cros-workon

DESCRIPTION="Chrontel CH7036 User Space Driver"
HOMEPAGE="http://www.chrontel.com"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE="-aura -bogus_screen_resizes -use_alsa_control"

CROS_WORKON_LOCALNAME="../third_party/chrontel"

RDEPEND="x11-libs/libX11
	x11-libs/libXdmcp
	x11-libs/libXrandr
	media-libs/alsa-lib"

DEPEND="${RDEPEND}"

src_compile() {
	tc-export CC PKG_CONFIG
        use bogus_screen_resizes && append-flags -DBOGUS_SCREEN_RESIZES
        use aura && append-flags -DUSE_AURA
        use use_alsa_control && append-flags -DUSE_ALSA_CONTROL
        export CCFLAGS="$CFLAGS"
	emake || die "end compile failed."
}

src_install() {
	dobin ch7036_monitor
	dobin ch7036_debug

	dodir /lib/firmware/chrontel
	insinto /lib/firmware/chrontel
	doins fw7036.bin

	insinto /etc/init
	doins chrontel.conf

	dodir /usr/share/userfeedback/etc
	insinto /usr/share/userfeedback/etc
	doins sys_mon_hdmi.sysinfo.lst
}
