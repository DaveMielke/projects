# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU Gener Public License v2

EAPI=5

inherit cmake-utils cros-sanitizers

DESCRIPTION="a userland driver for IPP-over-USB class USB devices."
HOMEPAGE="https://github.com/OpenPrinting/ippusbxd"
SRC_URI="https://github.com/OpenPrinting/ippusbxd/${P}.tar.gz"

KEYWORDS="*"
LICENSE="Apache-2.0"
SLOT="0"

DEPEND="
	virtual/libusb:1=
	>=net-dns/avahi-0.6.32
"

S="${WORKDIR}/${P}/src"

PATCHES=(
	"${FILESDIR}/unix-socket.patch"
	"${FILESDIR}/read-transfer-backoff.patch"
)

src_configure() {
	sanitizers-setup-env
	cmake-utils_src_configure
}

src_install() {
	dobin "${BUILD_DIR}/ippusbxd"

	# Install seccomp policy files.
	insinto /usr/share/policy
	newins "${FILESDIR}/ippusbxd-seccomp-${ARCH}.policy" ippusbxd-seccomp.policy
}
