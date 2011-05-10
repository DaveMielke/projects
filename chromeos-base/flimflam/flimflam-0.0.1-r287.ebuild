
# Copyright 2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/connman/connman-0.43.ebuild,v 1.1 2009/10/05 12:22:24 dagger Exp $

EAPI="2"
CROS_WORKON_COMMIT="63e4f9c0b6d75878ff29a1cbf99ebd7d4e8e2d1b"
CROS_WORKON_PROJECT="chromiumos/platform/flimflam"

inherit autotools cros-workon toolchain-funcs

DESCRIPTION="Provides a daemon for managing internet connections"
HOMEPAGE="http://connman.net"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="bluetooth +bootstat +crosmetrics +debug +dhcpcd +diagnostics dnsproxy doc +ethernet +l2tpipsec +modemmanager +newwifi +nss +openvpn policykit +portalcheck +ppp resolvconf resolvfiles threads tools +udev"

RDEPEND=">=dev-libs/glib-2.16
	>=sys-apps/dbus-1.2
	dev-libs/dbus-glib
	bluetooth? ( net-wireless/bluez )
	bootstat? ( chromeos-base/bootstat )
	crosmetrics? ( chromeos-base/metrics )
	dhcpcd? ( net-misc/dhcpcd )
	diagnostics? ( sys-apps/net-tools )
	modemmanager? ( chromeos-base/modem-utilities
		        net-misc/mobile-broadband-provider-info )
	nss? ( dev-libs/nss )
	openvpn? ( net-misc/openvpn )
	policykit? ( >=sys-auth/policykit-0.7 )
	portalcheck? ( net-misc/curl )
	ppp? ( net-dialup/ppp )
	resolvconf? ( net-dns/openresolv )
	udev? ( >=sys-fs/udev-141 )
	l2tpipsec? ( chromeos-base/vpn-manager )
	newwifi? ( net-wireless/wpa_supplicant[dbus] )"

DEPEND="${RDEPEND}
	modemmanager? ( net-misc/modemmanager )
	doc? ( dev-util/gtk-doc )"

CROS_WORKON_LOCALNAME="../third_party/flimflam"

src_prepare() {
	eautoreconf
}

src_configure() {
	if tc-is-cross-compiler ; then
		if use dhcpcd ; then
			export ac_cv_path_DHCPCD=/sbin/dhcpcd
		fi
		if use l2tpipsec ; then
			export ac_cv_path_L2TPIPSEC=/usr/sbin/l2tpipsec_vpn
		fi
		if use newwifi ; then
			export ac_cv_path_WPASUPPLICANT=/sbin/wpa_supplicant
		fi
		if use openvpn ; then
			export ac_cv_path_OPENVPN=/usr/sbin/openvpn
		fi
	fi

	econf \
		--localstatedir=/var \
		--enable-loopback=builtin \
		--with-sslroots=/etc/ssl/certs \
		$(use_enable bluetooth) \
		$(use_enable bootstat) \
		$(use_enable crosmetrics) \
		$(use_enable debug) \
		$(use_enable dhcpcd dhcpcd builtin) \
		$(use_enable dnsproxy dnsproxy builtin) \
		$(use_enable doc gtk-doc) \
		$(use_enable ethernet ethernet builtin) \
		$(use_enable l2tpipsec l2tpipsec builtin) \
		$(use_enable modemmanager modemmgr) \
        	$(use_enable nss nss builtin) \
		$(use_enable openvpn openvpn builtin) \
		$(use_enable policykit polkit) \
		$(use_enable portalcheck portal_check builtin) \
		$(use_enable ppp) \
		$(use_enable resolvconf) \
		$(use_enable resolvfiles resolvfiles builtin) \
		$(use_enable threads) \
		$(use_enable tools) \
		$(use_enable udev) \
		$(use_enable newwifi newwifi builtin) \
		--disable-iwmx
}

src_compile() {
	emake clean-generic || die "emake clean failed"
	emake || die "emake failed"
}

src_test() {
	if use modemmanager; then
		emake tools/providerdb_test
		if ! use x86; then
			echo "Skipping tests on non-x86 platform..."
		else
			gtester --verbose tools/providerdb_test
		fi
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	keepdir /var/lib/${PN} || die

	if use resolvfiles ; then
		mkdir -p "${D}"/etc/
		ln -s /var/run/flimflam/resolv.conf "${D}"/etc/resolv.conf
	elif use resolvconf; then
		:
	elif use dnsproxy ; then
		mkdir -p "${D}"/etc/
		echo "nameserver 127.0.0.1" > "${D}"/etc/resolv.conf
		chmod 0644 "${D}"/etc/resolv.conf
	fi

	if use ppp; then
		local ppp_dir="${D}"/etc/ppp/ip-up.d/
		mkdir -p ${ppp_dir}
		# pppd-script assumes pppd plugin is being used and crashes
		# trying to create a method call on its bus (which does not
		# exist).
		#cp "${D}"/usr/lib/flimflam/scripts/60-flimflam.sh ${ppp_dir}
	fi

	exeinto /usr/share/userfeedback/scripts
	doexe test/mm.sh test/mm-status || die "Can't copy user feedback scripts"
	dobin bin/ff_debug
	dobin bin/set_apn
	dobin bin/wpa_debug
}
