# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

CROS_WORKON_COMMIT="42758b9cdd722aad418d5207a8b2ee348e29696b"
CROS_WORKON_TREE="3c41079a536362b8b67adbba28158da575e33276"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel"
CROS_WORKON_LOCALNAME="kernel/v4.19"
CROS_WORKON_SUBTREE="tools/usb/usbip"

inherit autotools cros-workon eutils

DESCRIPTION="Userspace utilities for a general USB device sharing system over IP networks"
HOMEPAGE="https://www.kernel.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="static-libs tcpd"
RESTRICT=""

RDEPEND=">=dev-libs/glib-2.6
	sys-apps/hwids
	>=sys-kernel/linux-headers-3.17
	virtual/libudev
	tcpd? ( sys-apps/tcp-wrappers )"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

DOCS="AUTHORS README"

S=${WORKDIR}/linux-${PV}/tools/usb/${PN}

src_unpack() {
	cros-workon_src_unpack
	S+="/tools/usb/usbip"
}

src_prepare() {
	# remove -Werror from build, bug #545398
	sed -i 's/-Werror[^ ]* //g' configure.ac || die

	default

	eautoreconf
}

src_configure() {
	econf \
		$(use_enable static-libs static) \
		$(use tcpd || echo --without-tcp-wrappers) \
		--with-usbids-dir=/usr/share/misc
}

src_install() {
	default
	prune_libtool_files
}

pkg_postinst() {
	elog "For using USB/IP you need to enable USBIP_VHCI_HCD in the client"
	elog "machine's kernel config and USBIP_HOST on the server."
}
