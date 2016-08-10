# Copyright 1999-2009 Gentoo Foundation
# Copyright 2010 Google, Inc.
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI="4"
CROS_WORKON_COMMIT="71d4fee1dc6db9bd22f6866571895b753f222ff5"
CROS_WORKON_TREE="09e3ab70d43e6356140fd0b056d5e45e32fb7b9e"
CROS_WORKON_PROJECT="chromiumos/third_party/trousers"

inherit autotools base cros-debug cros-workon libchrome systemd user

DESCRIPTION="An open-source TCG Software Stack (TSS) v1.1 implementation"
HOMEPAGE="http://trousers.sf.net"
LICENSE="CPL-1.0"
KEYWORDS="*"
SLOT="0"
IUSE="doc systemd tss_trace"

RDEPEND=">=dev-libs/openssl-0.9.7"

DEPEND="${RDEPEND}
	chromeos-base/metrics
	dev-util/pkgconfig"

## TODO: Check if this patch is useful for us.
## PATCHES=(	"${FILESDIR}/${PN}-0.2.3-nouseradd.patch" )

pkg_setup() {
	# New user/group for the daemon
	enewgroup tss
	enewuser tss -1 -1 /var/lib/tpm tss
}

src_prepare() {
	base_src_prepare

	sed -e "s/-Werror //" -i configure.in
	if use tss_trace ; then
		# Enable tracing of TSS calls.
		export CFLAGS="$CFLAGS -DTSS_TRACE"
	fi
	eautoreconf
}

src_configure() {
	cros-workon_src_configure
}

src_install() {
	default
	dodoc NICETOHAVES
	use doc && dodoc doc/*

	# Install the empty system.data files
	dodir /etc/trousers
	insinto /etc/trousers
	doins "${S}"/dist/system.data.*

	# Install the init scripts
	if use systemd; then
		systemd_dounit init/tpm-probe.service
		systemd_enable_service boot-services.target tpm-probe.service
		systemd_dounit init/tcsd.service
	else
		insinto /etc/init
		doins init/*.conf
	fi
	insinto /usr/share/cros/init
	doins init/tcsd-pre-start.sh
}

pkg_postinst() {
	elog "If you have problems starting tcsd, please check permissions and"
	elog "ownership on /dev/tpm* and ~tss/system.data"
}
