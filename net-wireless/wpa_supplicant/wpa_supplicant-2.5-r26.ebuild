# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=4
CROS_WORKON_COMMIT="d1c0161b93fa729d0d70c7db07bda457fdce38a8"
CROS_WORKON_TREE="6151876351f3b319edc01ba5123bf914304dd0e9"
CROS_WORKON_PROJECT="chromiumos/third_party/hostap"

inherit cros-workon eutils toolchain-funcs qt4-r2 qmake-utils multilib systemd user

DESCRIPTION="IEEE 802.1X/WPA supplicant for secure wireless transfers"
# HOMEPAGE="http://hostap.epitest.fi/wpa_supplicant/"
# SRC_URI="http://hostap.epitest.fi/releases/${P}.tar.gz"
HOMEPAGE="${CROS_GIT_HOST_URL}/${CROS_WORKON_PROJECT}"
SRC_URI=""
LICENSE="|| ( GPL-2 BSD )"

SLOT="0"
KEYWORDS="*"
IUSE="ap dbus debug gnutls eap-sim fasteap +hs2-0 libressl madwifi p2p ps3 qt4 qt5 readline selinux smartcard ssl systemd +tdls uncommon-eap-types wps kernel_linux kernel_FreeBSD wimax"
REQUIRED_USE="fasteap? ( !gnutls !ssl ) smartcard? ( ssl )"

CDEPEND="
	chromeos-base/chromeos-minijail
	dbus? ( sys-apps/dbus )
	kernel_linux? (
		eap-sim? ( sys-apps/pcsc-lite )
		madwifi? ( ||
			( >net-wireless/madwifi-ng-tools-0.9.3
			net-wireless/madwifi-old )
		)
		dev-libs/libnl:3
		net-wireless/crda
	)
	!kernel_linux? ( net-libs/libpcap )
	qt4? (
		dev-qt/qtcore:4
		dev-qt/qtgui:4
		dev-qt/qtsvg:4
	)
	qt5? (
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtwidgets:5
		dev-qt/qtsvg:5
	)
	readline? (
		sys-libs/ncurses:0
		sys-libs/readline:0
	)
	ssl? (
		!libressl? ( dev-libs/openssl:0 )
		libressl? ( dev-libs/libressl )
	)
	smartcard? ( dev-libs/engine_pkcs11 )
	!ssl? (
		gnutls? (
			net-libs/gnutls
			dev-libs/libgcrypt
		)
		!gnutls? ( dev-libs/libtommath )
	)
"
DEPEND="${CDEPEND}
	virtual/pkgconfig
"
RDEPEND="${CDEPEND}
	selinux? ( sec-policy/selinux-networkmanager )
"

# S="${WORKDIR}/${P}/${PN}"
src_unpack() {
	cros-workon_src_unpack
	S+="/wpa_supplicant"
}

Kconfig_style_config() {
		#param 1 is CONFIG_* item
		#param 2 is what to set it = to, defaulting in y
		CONFIG_PARAM="${CONFIG_HEADER:-CONFIG_}$1"
		setting="${2:-y}"

		if [ ! $setting = n ]; then
			#first remove any leading "# " if $2 is not n
			sed -i "/^# *$CONFIG_PARAM=/s/^# *//" .config || echo "Kconfig_style_config error uncommenting $CONFIG_PARAM"
			#set item = $setting (defaulting to y)
			sed -i "/^$CONFIG_PARAM/s/=.*/=$setting/" .config || echo "Kconfig_style_config error setting $CONFIG_PARAM=$setting"
		else
			#ensure item commented out
			sed -i "/^$CONFIG_PARAM/s/$CONFIG_PARAM/# $CONFIG_PARAM/" .config || echo "Kconfig_style_config error commenting $CONFIG_PARAM"
		fi
}

pkg_setup() {
	if use gnutls && use ssl ; then
		elog "You have both 'gnutls' and 'ssl' USE flags enabled: defaulting to USE=\"ssl\""
	fi
}

src_prepare() {
	cros-workon_src_prepare

	# net/bpf.h needed for net-libs/libpcap on Gentoo/FreeBSD
	sed -i \
		-e "s:\(#include <pcap\.h>\):#include <net/bpf.h>\n\1:" \
		../src/l2_packet/l2_packet_freebsd.c || die

	# People seem to take the example configuration file too literally (bug #102361)
	sed -i \
		-e "s:^\(opensc_engine_path\):#\1:" \
		-e "s:^\(pkcs11_engine_path\):#\1:" \
		-e "s:^\(pkcs11_module_path\):#\1:" \
		wpa_supplicant.conf || die

	# Change configuration to match Gentoo locations (bug #143750)
	sed -i \
		-e "s:/usr/lib/opensc:/usr/$(get_libdir):" \
		-e "s:/usr/lib/pkcs11:/usr/$(get_libdir):" \
		wpa_supplicant.conf || die

	#if use dbus; then
	#	epatch "${FILESDIR}/${P}-dbus-path-fix.patch"
	#fi

	# systemd entries to D-Bus service files (bug #372877)
	# echo 'SystemdService=wpa_supplicant.service' \
	# 	| tee -a dbus/*.service >/dev/null || die

	cd "${WORKDIR}/${P}"

	if use wimax; then
		# generate-libeap-peer.patch comes before
		# fix-undefined-reference-to-random_get_bytes.patch
		# epatch "${FILESDIR}/${P}-generate-libeap-peer.patch"

		# multilib-strict fix (bug #373685)
		sed -e "s/\/usr\/lib/\/usr\/$(get_libdir)/" -i src/eap_peer/Makefile
	fi

	# bug (320097)
	# epatch "${FILESDIR}/${P}-do-not-call-dbus-functions-with-NULL-path.patch"

	# TODO - NEED TESTING TO SEE IF STILL NEEDED, NOT COMPATIBLE WITH 1.0 OUT OF THE BOX,
	# SO WOULD BE NICE TO JUST DROP IT, IF IT IS NOT NEEDED.
	# bug (374089)
	#epatch "${FILESDIR}/${P}-dbus-WPAIE-fix.patch"

	# bug (565270)
	# epatch "${FILESDIR}/${P}-libressl.patch"
}

src_configure() {
	cros-workon_src_configure
	# Toolchain setup
	tc-export CC

	cp defconfig .config

	# Basic setup
	Kconfig_style_config CTRL_IFACE
	Kconfig_style_config BACKEND file
	Kconfig_style_config IBSS_RSN
	Kconfig_style_config IEEE80211W
	Kconfig_style_config IEEE80211R
	Kconfig_style_config IEEE80211N
	Kconfig_style_config IEEE80211AC

	# Basic authentication methods
	# NOTE: we don't set GPSK or SAKE as they conflict
	# with the below options
	Kconfig_style_config EAP_GTC
	Kconfig_style_config EAP_MD5
	Kconfig_style_config EAP_OTP
	Kconfig_style_config EAP_PAX
	Kconfig_style_config EAP_PSK
	Kconfig_style_config EAP_TLV
	Kconfig_style_config EAP_EXE
	Kconfig_style_config IEEE8021X_EAPOL
	Kconfig_style_config PKCS12
	Kconfig_style_config PEERKEY
	Kconfig_style_config EAP_LEAP
	Kconfig_style_config EAP_MSCHAPV2
	Kconfig_style_config EAP_PEAP
	Kconfig_style_config EAP_TLS
	Kconfig_style_config EAP_TTLS

	# Enabling background scanning.
	Kconfig_style_config BGSCAN_SIMPLE
	Kconfig_style_config BGSCAN_LEARN

	# Allow VHT/HT parameters to be overriden; required by ChromiumOS
	Kconfig_style_config VHT_OVERRIDES
	Kconfig_style_config HT_OVERRIDES

	if use dbus ; then
		Kconfig_style_config CTRL_IFACE_DBUS
		Kconfig_style_config CTRL_IFACE_DBUS_NEW
		Kconfig_style_config CTRL_IFACE_DBUS_INTRO
	fi

	# Enable support for writing debug info to a log file and syslog.
	Kconfig_style_config DEBUG_FILE
	Kconfig_style_config DEBUG_SYSLOG
	Kconfig_style_config DEBUG_SYSLOG_FACILITY LOG_LOCAL6

	if use hs2-0 ; then
		Kconfig_style_config INTERWORKING
		Kconfig_style_config HS20
	fi

	if use uncommon-eap-types; then
		Kconfig_style_config EAP_GPSK
		Kconfig_style_config EAP_SAKE
		Kconfig_style_config EAP_GPSK_SHA256
		Kconfig_style_config EAP_IKEV2
		Kconfig_style_config EAP_EKE
	fi

	if use eap-sim ; then
		# Smart card authentication
		Kconfig_style_config EAP_SIM
		Kconfig_style_config EAP_AKA
		Kconfig_style_config EAP_AKA_PRIME
		Kconfig_style_config PCSC
	fi

	if use fasteap ; then
		Kconfig_style_config EAP_FAST
	fi

	if use readline ; then
		# readline/history support for wpa_cli
		Kconfig_style_config READLINE
	else
		#internal line edit mode for wpa_cli
		Kconfig_style_config WPA_CLI_EDIT
	fi

	# SSL authentication methods
	if use ssl ; then
		Kconfig_style_config TLS openssl
	elif use gnutls ; then
		Kconfig_style_config TLS gnutls
		Kconfig_style_config GNUTLS_EXTRA
	else
		Kconfig_style_config TLS internal
	fi

	if use smartcard ; then
		Kconfig_style_config SMARTCARD
	fi

	if use tdls ; then
		Kconfig_style_config TDLS
	fi

	if use kernel_linux ; then
		# Linux specific drivers
		# Kconfig_style_config DRIVER_ATMEL
		# Kconfig_style_config DRIVER_HOSTAP
		# Kconfig_style_config DRIVER_IPW
		Kconfig_style_config DRIVER_NL80211
		# Kconfig_style_config DRIVER_RALINK
		Kconfig_style_config DRIVER_WEXT
		Kconfig_style_config DRIVER_WIRED

		if use ps3 ; then
			Kconfig_style_config DRIVER_PS3
		fi

	elif use kernel_FreeBSD ; then
		# FreeBSD specific driver
		Kconfig_style_config DRIVER_BSD
	fi

	# Wi-Fi Protected Setup (WPS)
	if use wps ; then
		Kconfig_style_config WPS
		Kconfig_style_config WPS2
		# USB Flash Drive
		Kconfig_style_config WPS_UFD
		# External Registrar
		Kconfig_style_config WPS_ER
		# Universal Plug'n'Play
		Kconfig_style_config WPS_UPNP
		# Near Field Communication
		Kconfig_style_config WPS_NFC
	fi

	# Wi-Fi Direct (WiDi)
	if use p2p ; then
		Kconfig_style_config P2P
		Kconfig_style_config WIFI_DISPLAY
	fi

	# Access Point Mode
	if use ap ; then
		Kconfig_style_config AP
		# only AP currently support mesh networks.
	    Kconfig_style_config MESH
	fi

	# Enable mitigation against certain attacks against TKIP
	Kconfig_style_config DELAYED_MIC_ERROR_REPORT

	if use qt4 ; then
		pushd "${S}"/wpa_gui-qt4 > /dev/null
		eqmake4 wpa_gui.pro
		popd > /dev/null
	fi
	if use qt5 ; then
		pushd "${S}"/wpa_gui-qt4 > /dev/null
		eqmake5 wpa_gui.pro
		popd > /dev/null
	fi
}

src_compile() {
	einfo "Building wpa_supplicant"
	emake V=1 BINDIR=/usr/sbin

	if use wimax; then
		emake -C ../src/eap_peer clean
		emake -C ../src/eap_peer
	fi

	if use qt4 || use qt5; then
		pushd "${S}"/wpa_gui-qt4 > /dev/null
		einfo "Building wpa_gui"
		emake
		popd > /dev/null
	fi
}

src_install() {
	dosbin wpa_supplicant
	dobin wpa_cli wpa_passphrase

	# baselayout-1 compat
	if has_version "<sys-apps/baselayout-2.0.0"; then
		dodir /sbin
		dosym /usr/sbin/wpa_supplicant /sbin/wpa_supplicant
		dodir /bin
		dosym /usr/bin/wpa_cli /bin/wpa_cli
	fi

	if has_version ">=sys-apps/openrc-0.5.0"; then
		newinitd "${FILESDIR}/${PN}-init.d" wpa_supplicant
		newconfd "${FILESDIR}/${PN}-conf.d" wpa_supplicant
	fi

	# Missing patch?
	#  !!! newexe: /mnt/host/source/src/private-overlays/project-jetstream-private/net-wireless/wpa_supplicant/files/wpa_cli.sh does not exist
	# exeinto /etc/wpa_supplicant/
	# newexe "${FILESDIR}/wpa_cli.sh" wpa_cli.sh

	dodoc ChangeLog {eap_testing,todo}.txt README{,-WPS} \
		wpa_supplicant.conf

	newdoc .config build-config

	# CHROMIUM: sorry, don't want docs installed
	# doman doc/docbook/*.{5,8}

	if use qt4 || use qt5 ; then
		into /usr
		dobin wpa_gui-qt4/wpa_gui
		doicon wpa_gui-qt4/icons/wpa_gui.svg
		make_desktop_entry wpa_gui "WPA Supplicant Administration GUI" "wpa_gui" "Qt;Network;"
	fi

	use wimax && emake DESTDIR="${D}" -C ../src/eap_peer install

	if use dbus ; then
		# DBus introspection XML file.
		insinto /usr/share/dbus-1/interfaces
		doins ${FILESDIR}/dbus_bindings/fi.w1.wpa_supplicant1.xml || die
		insinto /etc/dbus-1/system.d
		doins ${FILESDIR}/dbus_permissions/fi.w1.wpa_supplicant1.conf || die
		keepdir /var/run/wpa_supplicant

		popd > /dev/null
	fi
	# Install the init scripts
	if use systemd; then
		insinto /usr/share
		systemd_dounit ${FILESDIR}/init/wpa_supplicant.service
		systemd_enable_service boot-services.target wpa_supplicant.service
		systemd_dotmpfilesd ${FILESDIR}/init/wpa_supplicant.conf
	else
		insinto /etc/init
		doins ${FILESDIR}/init/wpasupplicant.conf
	fi
}

pkg_preinst() {
	enewuser "wpa"
	enewgroup "wpa"
}

pkg_postinst() {
	elog "If this is a clean installation of wpa_supplicant, you"
	elog "have to create a configuration file named"
	elog "/etc/wpa_supplicant/wpa_supplicant.conf"
	elog
	elog "An example configuration file is available for reference in"
	elog "/usr/share/doc/${PF}/"

	if [[ -e ${ROOT}etc/wpa_supplicant.conf ]] ; then
		echo
		ewarn "WARNING: your old configuration file ${ROOT}etc/wpa_supplicant.conf"
		ewarn "needs to be moved to ${ROOT}etc/wpa_supplicant/wpa_supplicant.conf"
	fi

	# Mea culpa, feel free to remove that after some time --mgorny.
	# local fn
	# for fn in wpa_supplicant{,@wlan0}.service; do
	# 	if [[ -e "${ROOT}"/etc/systemd/system/network.target.wants/${fn} ]]
	# 	then
	# 		ebegin "Moving ${fn} to multi-user.target"
	# 		mv "${ROOT}"/etc/systemd/system/network.target.wants/${fn} \
	# 			"${ROOT}"/etc/systemd/system/multi-user.target.wants/
	# 		eend ${?} \
	# 			"Please try to re-enable ${fn}"
	# 	fi
	# done
}
