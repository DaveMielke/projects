# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
CROS_WORKON_COMMIT="5e6fcc4a29681ec2bbf17bbe9aeda10314d9ae3f"
CROS_WORKON_TREE="76dc0c7fd25b7f5f6a9e429a2cfe2510bca22928"
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
	dev-python/pyusb
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
