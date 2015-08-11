# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="2a43d6503281712bc07ccae3d7656c66386da857"
CROS_WORKON_TREE="323be422e7c964da37e658e7792d9a412434e36a"
CROS_WORKON_PROJECT="chromiumos/third_party/chrontel"
CROS_WORKON_LOCALNAME="../third_party/chrontel"

inherit cros-workon

DESCRIPTION="Chrontel CH7036 User Space Driver"
HOMEPAGE="http://www.chrontel.com"
SRC_URI=""

# TODO: Once the licensing script stops clobbering chromeos-base/* projects
# from BSD to BSD-Google, we can use normal BSD here.  See this CL for info:
# https://chromium-review.googlesource.com/188206
LICENSE="BSD-chrontel"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -bogus_screen_resizes -clang -use_alsa_control"
REQUIRED_USE="asan? ( clang )"

RDEPEND="x11-libs/libdrm
	media-libs/alsa-lib
	media-sound/adhd"
DEPEND="${RDEPEND}"

src_configure() {
	clang-setup-env
	cros-workon_src_configure
}

src_compile() {
	tc-export CC PKG_CONFIG
	use use_alsa_control && append-flags -DUSE_ALSA_CONTROL
	export CCFLAGS="${CFLAGS}"
	emake
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
