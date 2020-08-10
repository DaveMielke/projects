# Copyright 1999-2009 Gentoo Foundation
# Copyright 2010 Google, Inc.
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI="5"
CROS_WORKON_COMMIT="420824078ff146bd1931ecfb7b01343664fb8292"
CROS_WORKON_TREE="bb63d3cbc6f2501646b57d6c7c28c4ff1bd8e3ac"
CROS_WORKON_PROJECT="chromiumos/third_party/trousers"
CROS_WORKON_EGIT_BRANCH="master-0.3.13"

inherit autotools base cros-debug cros-sanitizers cros-workon flag-o-matic libchrome systemd user

DESCRIPTION="An open-source TCG Software Stack (TSS) v1.1 implementation"
HOMEPAGE="http://trousers.sf.net"
LICENSE="CPL-1.0"
KEYWORDS="*"
SLOT="0"
IUSE="asan doc mocktpm systemd tss_trace"

COMMON_DEPEND="
	chromeos-base/metrics
	>=dev-libs/openssl-0.9.7:0="

RDEPEND="${COMMON_DEPEND}"

DEPEND="${COMMON_DEPEND}
	dev-util/pkgconfig"

## TODO: Check if this patch is useful for us.
## PATCHES=(	"${FILESDIR}/${PN}-0.2.3-nouseradd.patch" )

pkg_setup() {
	# New user/group for the daemon
	enewgroup tss
	enewuser tss
}

src_prepare() {
	base_src_prepare

	sed -e "s/-Werror //" -i configure.in
	eautoreconf
}

src_configure() {
	sanitizers-setup-env
	use tss_trace && append-cppflags -DTSS_TRACE
	use mocktpm && append-cppflags -DMOCK_TPM

	cros-debug-add-NDEBUG
	export BASE_VER="$(libchrome_ver)"
	econf
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
		systemd_dounit init/*.service
		systemd_enable_service boot-services.target tcsd.service
		systemd_enable_service boot-services.target tpm-probe.service
	else
		insinto /etc/init
		doins init/*.conf
	fi
	exeinto /usr/share/cros/init
	doexe init/tcsd-pre-start.sh
}

pkg_postinst() {
	elog "If you have problems starting tcsd, please check permissions and"
	elog "ownership on /dev/tpm* and ~tss/system.data"
}