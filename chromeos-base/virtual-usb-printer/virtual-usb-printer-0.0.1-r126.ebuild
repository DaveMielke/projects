# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT=("7da6c3a1b49aacdfd29b62fb168a943265a0aafd" "7b3c74ebf60df88365dd6b5f53b2413e2809fa2c")
CROS_WORKON_TREE=("2b7b46ab1083cdcc8b17bd7f5b05ddff336b0559" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb" "17d59816c570e28ad4be27c823a3fd27c9bbbef9")
CROS_WORKON_LOCALNAME=("platform2" "third_party/virtual-usb-printer")
CROS_WORKON_PROJECT=("chromiumos/platform2" "chromiumos/third_party/virtual-usb-printer")
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/platform2/virtual-usb-printer")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_SUBTREE=("common-mk .gn" "")

PLATFORM_SUBDIR="virtual-usb-printer"

inherit cros-workon platform

DESCRIPTION="Used with USBIP to provide a virtual USB printer for testing."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/third_party/virtual-usb-printer/"

LICENSE="GPL-2"
KEYWORDS="*"

IUSE=""

RDEPEND="
	net-misc/usbip:=
"

DEPEND="${RDEPEND}"

platform_pkg_test() {
	platform_test "run" "${OUT}/ipp-util-testrunner"
	platform_test "run" "${OUT}/load-config-testrunner"
	platform_test "run" "${OUT}/smart-buffer-testrunner"
}

src_install() {
	dobin "${OUT}"/virtual-usb-printer
	insinto /etc/virtual-usb-printer
	doins config/ipp_attributes.json
	doins config/ippusb_printer.json
	doins config/usb_printer.json
}
