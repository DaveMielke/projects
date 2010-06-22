# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/connman/connman-0.43.ebuild,v 1.1 2009/10/05 12:22:24 dagger Exp $

EAPI="2"

inherit autotools toolchain-funcs

DESCRIPTION="Provides a daemon for managing internet connections"
HOMEPAGE="http://connman.net"
# SRC_URI="mirror://kernel/linux/network/${PN}/${PN}-0.43.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="arm amd64 x86"
IUSE="bluetooth +crosmetrics +debug +dhcpcd +dhclient dnsproxy doc +ethernet +modemmanager ofono policykit +ppp resolvconf resolvfiles threads tools +udev +wifi"
# ospm wimax

RDEPEND="chromeos-base/crash-dumper
	>=dev-libs/glib-2.16
	>=sys-apps/dbus-1.2
	dev-libs/dbus-glib
	bluetooth? ( net-wireless/bluez )
	crosmetrics? ( chromeos-base/metrics )
	dhclient? ( net-misc/dhcp )
	dhcpcd? ( net-misc/dhcpcd )
	modemmanager? ( net-misc/mobile-broadband-provider-info )
	modemmanager? ( net-misc/modemmanager )
	ofono? ( net-misc/ofono )
	policykit? ( >=sys-auth/policykit-0.7 )
	ppp? ( net-dialup/ppp )
	resolvconf? ( net-dns/openresolv )
	udev? ( >=sys-fs/udev-141 )
	wifi? ( net-wireless/wpa_supplicant[dbus] )"

DEPEND="${RDEPEND}
	doc? ( dev-util/gtk-doc )"

src_unpack() {
	if [ -n "$CHROMEOS_ROOT" ] ; then
		local third_party="${CHROMEOS_ROOT}/src/third_party"
		local flimflam="${third_party}/flimflam/files"
		elog "Using flimflam dir: $flimflam"
		mkdir -p "${S}"
		cp -a "${flimflam}"/* "${S}" || die
	else
		unpack ${A}
	fi
}

src_prepare() {
	eautoreconf
}

src_configure() {
	if tc-is-cross-compiler ; then
		if use wifi ; then
			export ac_cv_path_WPASUPPLICANT=/sbin/wpa_supplicant
		fi
		if use dhclient ; then
			export ac_cv_path_DHCLIENT=/sbin/dhclient
		fi
	fi

	tc-export CC
	export CFLAGS="${CFLAGS} -gstabs"

	econf \
		--localstatedir=/var \
		--enable-loopback=builtin \
		$(use_enable bluetooth) \
		$(use_enable crosmetrics) \
		$(use_enable debug) \
		$(use_enable dhclient dhclient) \
		$(use_enable dhcpcd dhcpcd) \
		$(use_enable dnsproxy dnsproxy builtin) \
		$(use_enable doc gtk-doc) \
		$(use_enable ethernet ethernet builtin) \
		$(use_enable modemmanager modemmgr) \
		$(use_enable ofono) \
		$(use_enable policykit polkit) \
		$(use_enable ppp) \
		$(use_enable resolvconf) \
		$(use_enable resolvfiles resolvfiles builtin) \
		$(use_enable threads) \
		$(use_enable tools) \
		$(use_enable udev) \
		$(use_enable wifi wifi builtin) \
		--disable-udhcp \
		--disable-iwmx \
		--disable-iospm
}

src_compile() {
	emake clean-generic || die "emake clean failed"
	emake || die "emake failed"
	dump_syms.i386 src/flimflamd > \
	        flimflamd.sym 2>/dev/null || die "symbol extraction failed"
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
	       cp "${D}"/usr/lib/flimflam/scripts/60-flimflam.sh ${ppp_dir}
	fi

	insinto /usr/lib/debug
	doins flimflamd.sym
}
