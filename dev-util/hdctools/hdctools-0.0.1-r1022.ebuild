# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
CROS_WORKON_COMMIT="4a72a8b3d95caef2b235a4d02ea5fda2bc95cea0"
CROS_WORKON_TREE="ea8ee6b0440a831331eb0a58151dfbc6c0d1bd99"
CROS_WORKON_PROJECT="chromiumos/third_party/hdctools"
PYTHON_COMPAT=( python2_{6,7} )

inherit cros-workon distutils-r1 toolchain-funcs multilib udev

DESCRIPTION="Software to communicate with servo/miniservo debug boards"
HOMEPAGE="https://www.chromium.org/chromium-os/servo"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="cros_host test"

RDEPEND=">=dev-embedded/libftdi-0.18
	dev-python/numpy
	>=dev-python/pexpect-3.0
	dev-python/pyserial
	test? ( dev-python/pytest )
	>=dev-python/pyusb-1.0.2
	virtual/libusb:1
	app-misc/screen
	chromeos-base/ec-devutils"
DEPEND="${RDEPEND}
	app-text/htmltidy"

src_configure() {
	cros-workon_src_configure
}

src_test() {
	py.test -v build/ || die
}

src_compile() {
	tc-export CC PKG_CONFIG
	local makeargs=( $(usex cros_host '' EXTRA_DIRS=chromeos) )
	emake "${makeargs[@]}"
	distutils-r1_src_compile
}

src_install() {
	local makeargs=(
		$(usex cros_host '' EXTRA_DIRS=chromeos)
		DESTDIR="${D}"
		LIBDIR=/usr/$(get_libdir)
		UDEV_DEST="${D}$(get_udevdir)/rules.d"
		install
	)
	emake "${makeargs[@]}"
	distutils-r1_src_install
}
