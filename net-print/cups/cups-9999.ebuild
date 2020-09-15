# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

CROS_WORKON_PROJECT="chromiumos/third_party/cups"
CROS_WORKON_EGIT_BRANCH="cups-2-2-8"

PYTHON_COMPAT=( python2_7 )

inherit cros-workon autotools fdo-mime gnome2-utils flag-o-matic linux-info \
	multilib multilib-minimal pam python-single-r1 user versionator \
	java-pkg-opt-2 systemd toolchain-funcs cros-fuzzer cros-sanitizers

MY_P=${P/_rc/rc}
MY_P=${MY_P/_beta/b}
MY_PV=${PV/_rc/rc}
MY_PV=${MY_PV/_beta/b}

KEYWORDS="~*"

DESCRIPTION="The Common Unix Printing System"
HOMEPAGE="http://www.cups.org/"

LICENSE="GPL-2"
SLOT="0"
IUSE="acl dbus debug java kerberos pam
	python +seccomp selinux +ssl static-libs systemd +threads upstart usb X xinetd zeroconf
	asan fuzzer"

LANGS="ca cs de es fr it ja ru"
for X in ${LANGS} ; do
	IUSE="${IUSE} +linguas_${X}"
done

CDEPEND="
	app-text/libpaper
	acl? (
		kernel_linux? (
			sys-apps/acl
			sys-apps/attr
		)
	)
	dbus? ( >=sys-apps/dbus-1.6.18-r1[${MULTILIB_USEDEP}] )
	java? ( >=virtual/jre-1.6:* )
	kerberos? ( >=virtual/krb5-0-r1[${MULTILIB_USEDEP}] )
	!net-print/lprng
	pam? ( virtual/pam )
	python? ( ${PYTHON_DEPS} )
	ssl? (
		>=dev-libs/libgcrypt-1.5.3:0[${MULTILIB_USEDEP}]
		>=net-libs/gnutls-2.12.23-r6[${MULTILIB_USEDEP}]
	)
	systemd? ( sys-apps/systemd )
	usb? ( virtual/libusb:1 )
	X? ( x11-misc/xdg-utils )
	xinetd? ( sys-apps/xinetd )
	zeroconf? ( >=net-dns/avahi-0.6.31-r2[${MULTILIB_USEDEP}] )
	abi_x86_32? (
		!<=app-emulation/emul-linux-x86-baselibs-20140508
		!app-emulation/emul-linux-x86-baselibs[-abi_x86_32(-)]
	)
"

DEPEND="${CDEPEND}
	>=virtual/pkgconfig-0-r1[${MULTILIB_USEDEP}]
"

RDEPEND="${CDEPEND}
	selinux? ( sec-policy/selinux-cups )
"

REQUIRED_USE="
	python? ( ${PYTHON_REQUIRED_USE} )
	usb? ( threads )
	?? ( systemd upstart )
"

# upstream includes an interactive test which is a nono for gentoo
RESTRICT="test"

S="${WORKDIR}/${PN}-release-${MY_PV}"

MULTILIB_CHOST_TOOLS=(
	/usr/bin/cups-config
)

pkg_setup() {
	enewgroup lp
	enewuser lp -1 -1 -1 "lp,ippusb"
	enewgroup lpadmin
	enewuser lpadmin -1 -1 -1 "lpadmin,ippusb"
	enewgroup cups
	enewuser cups -1 -1 -1 cups

	use python && python-single-r1_pkg_setup

	if use kernel_linux; then
		linux-info_pkg_setup
		if  ! linux_config_exists; then
			ewarn "Can't check the linux kernel configuration."
			ewarn "You might have some incompatible options enabled."
		else
			# recheck that we don't have usblp to collide with libusb
			if use usb; then
				if linux_chkconfig_present USB_PRINTER; then
					eerror "Your usb printers will be managed via libusb. In this case, "
					eerror "${P} requires the USB_PRINTER support disabled."
					eerror "Please disable it:"
					eerror "    CONFIG_USB_PRINTER=n"
					eerror "in /usr/src/linux/.config or"
					eerror "    Device Drivers --->"
					eerror "        USB support  --->"
					eerror "            [ ] USB Printer support"
					eerror "Alternatively, just disable the usb useflag for cups (your printer will still work)."
				fi
			else
				#here we should warn user that he should enable it so he can print
				if ! linux_chkconfig_present USB_PRINTER; then
					ewarn "If you plan to use USB printers you should enable the USB_PRINTER"
					ewarn "support in your kernel."
					ewarn "Please enable it:"
					ewarn "    CONFIG_USB_PRINTER=y"
					ewarn "in /usr/src/linux/.config or"
					ewarn "    Device Drivers --->"
					ewarn "        USB support  --->"
					ewarn "            [*] USB Printer support"
					ewarn "Alternatively, enable the usb useflag for cups and use the libusb code."
				fi
			fi
		fi
	fi
}

src_prepare() {
	epatch_user

	# Remove ".SILENT" rule for verbose output (bug 524338).
	sed 's#^.SILENT:##g' -i "${S}"/Makedefs.in || die "sed failed"

	# Fix install-sh, posix sh does not have 'function'.
	sed 's#function gzipcp#gzipcp()#g' -i "${S}/install-sh"

	AT_M4DIR=config-scripts eaclocal
	eautoconf

	# custom Makefiles
	multilib_copy_sources
}

multilib_src_configure() {
	sanitizers-setup-env

	export DSOFLAGS="${LDFLAGS}"

	einfo LANGS=\"${LANGS}\"
	einfo LINGUAS=\"${LINGUAS}\"

	local myconf=()

	if tc-is-static-only; then
		myconf+=(
			--disable-shared
		)
	fi

	# engages the Chrome-OS-specific "minimal" build.
	# We perform further cleanup in multilib_src_install_all().
	myconf+=( "--with-components=cros-minimal" )

	# explicitly specify compiler wrt bug 524340
	#
	# need to override KRB5CONFIG for proper flags
	# https://www.cups.org/str.php?L4423
	econf \
		CC="$(tc-getCC)" \
		CXX="$(tc-getCXX)" \
		KRB5CONFIG="${EPREFIX}"/usr/bin/${CHOST}-krb5-config \
		--libdir="${EPREFIX}"/usr/$(get_libdir) \
		--localstatedir="${EPREFIX}"/var \
		--with-rundir="${EPREFIX}"/run/cups \
		--with-printerroot="${EPREFIX}"/var/cache/cups/printers \
		--with-cups-user=nobody \
		--with-cups-group=cups \
		--with-docdir="${EPREFIX}"/usr/share/cups/html \
		--with-languages="${LINGUAS}" \
		--with-system-groups=lpadmin \
		--with-xinetd=/etc/xinetd.d \
		$(multilib_native_use_enable acl) \
		$(use_enable dbus) \
		$(use_enable debug) \
		$(use_enable debug debug-guards) \
		$(use_enable debug debug-printfs) \
		$(multilib_native_use_with java) \
		$(use_enable kerberos gssapi) \
		$(multilib_native_use_enable pam) \
		$(multilib_native_use_with python python "${PYTHON}") \
		$(use_enable static-libs static) \
		$(use_enable threads) \
		$(use_enable ssl gnutls) \
		$(use_enable systemd) \
		$(use_enable upstart) \
		$(multilib_native_use_enable usb libusb) \
		$(use_enable zeroconf avahi) \
		--disable-dnssd \
		--without-perl \
		--without-php \
		$(multilib_is_native_abi && echo --enable-libpaper || echo --disable-libpaper) \
		"${myconf[@]}"

	# install in /usr/libexec always, instead of using /usr/lib/cups, as that
	# makes more sense when facing multilib support.
	sed -i -e "s:SERVERBIN.*:SERVERBIN = \"\$\(BUILDROOT\)${EPREFIX}/usr/libexec/cups\":" Makedefs || die
	sed -i -e "s:#define CUPS_SERVERBIN.*:#define CUPS_SERVERBIN \"${EPREFIX}/usr/libexec/cups\":" config.h || die
	sed -i -e "s:cups_serverbin=.*:cups_serverbin=\"${EPREFIX}/usr/libexec/cups\":" cups-config || die
}

multilib_src_compile() {
	if multilib_is_native_abi; then
		default
	else
		emake libs
	fi
}

multilib_src_test() {
	multilib_is_native_abi && default
}

multilib_src_install() {
	if multilib_is_native_abi; then
		emake BUILDROOT="${D}" install
	else
		emake BUILDROOT="${D}" install-libs install-headers
		dobin cups-config
	fi
}

multilib_src_install_all() {
	# move the default config file to docs
	dodoc "${ED}"/etc/cups/cupsd.conf.default
	rm -f "${ED}"/etc/cups/cupsd.conf.default

	# clean out cups init scripts
	rm -rf "${ED}"/etc/{init.d/cups,rc*,pam.d/cups}

	# install our init script
	local neededservices
	use zeroconf && neededservices+=" avahi-daemon"
	use dbus && neededservices+=" dbus"
	[[ -n ${neededservices} ]] && neededservices="need${neededservices}"
	cp "${FILESDIR}"/cupsd.init.d-r1 "${T}"/cupsd || die
	sed -i \
		-e "s/@neededservices@/$neededservices/" \
		"${T}"/cupsd || die
	doinitd "${T}"/cupsd

	# install our pam script
	pamd_mimic_system cups auth account

	if use xinetd ; then
		# correct path
		sed -i \
			-e "s:server = .*:server = /usr/libexec/cups/daemon/cups-lpd:" \
			"${ED}"/etc/xinetd.d/cups-lpd || die
		# it is safer to disable this by default, bug #137130
		grep -w 'disable' "${ED}"/etc/xinetd.d/cups-lpd || \
			{ sed -i -e "s:}:\tdisable = yes\n}:" "${ED}"/etc/xinetd.d/cups-lpd || die ; }
		# write permission for file owner (root), bug #296221
		fperms u+w /etc/xinetd.d/cups-lpd || die "fperms failed"
	else
		# always configure with --with-xinetd= and clean up later,
		# bug #525604
		rm -rf "${ED}"/etc/xinetd.d
	fi

	keepdir /usr/libexec/cups/driver /usr/share/cups/{model,profiles} \
		/var/spool/cups/tmp

	keepdir /etc/cups/{interfaces,ppd,ssl}

	# create /etc/cups/client.conf, bug #196967 and #266678
	echo "ServerName ${EPREFIX}/run/cups/cups.sock" >> "${ED}"/etc/cups/client.conf
	# Cap TLS per https://crbug.com/1088032
	echo "MaxTLS1.2" >> "${ED}/etc/cups/client.conf"

	# the following file is now provided by cups-filters:
	rm -r "${ED}"/usr/share/cups/banners || die

	# the following are created by the init script
	rm -r "${ED}"/var/cache/cups || die
	rm -r "${ED}"/run || die

	# we're sending logs to syslog, not /var/log/cups/*
	rmdir "${ED}"/var/log/cups || die

	# CUPS tries to install these as root-only executables, for
	# IPP/Kerberos support, and for "privileged port" listening. We don't
	# need the former, and the latter is handled by Linux capabilities.
	# Discussion here:
	# http://www.cups.org/pipermail/cups/2016-February/027499.html
	chmod 0755 "${ED}"/usr/libexec/cups/backend/{dnssd,ipp,lpd}

	# Create a symbolic link from "ippusb' to the ipp backend.
	dosym ipp /usr/libexec/cups/backend/ippusb

	# Install our own conf files
	insinto /etc/cups
	doins "${FILESDIR}"/{cupsd,cups-files}.conf
	if use upstart; then
		insinto /etc/init
		doins "${FILESDIR}"/init/cups-pre-upstart-socket-bridge.conf
		doins "${FILESDIR}"/init/cups-post-upstart-socket-bridge.conf
		doins "${FILESDIR}"/init/cupsd.conf
		doins "${FILESDIR}"/init/cups-clear-state.conf
		exeinto /usr/share/cros/init
		doexe "${FILESDIR}"/init/cups-clear-state.sh
	fi

	# CUPS wants the daemon user to own these
	chown cups:cups "${ED}"/etc/cups/{cupsd.conf,cups-files.conf,ssl}
	# CUPS also wants some specific permissions
	chmod 640 "${ED}"/etc/cups/{cupsd,cups-files}.conf
	chmod 700 "${ED}"/etc/cups/ssl

	if use seccomp; then
		# Install seccomp policy files.
		insinto /usr/share/policy
		newins "${FILESDIR}/cupsd-seccomp-${ARCH}.policy" cupsd-seccomp.policy
		newins "${FILESDIR}/cupstestppd-seccomp-${ARCH}.policy" cupstestppd-seccomp.policy
		newins "${FILESDIR}/lpadmin-seccomp-${ARCH}.policy" lpadmin-seccomp.policy
	else
		sed -i '/^env seccomp_flags=/s:=.*:="":' "${ED}"/etc/init/cupsd.conf
	fi

	# Removes files and directories not used by Chrome OS.
	rm -rv \
		"${ED}"usr/share/cups/ppdc/ \
			|| die "failed to remove some directories"
	rm -v \
		"${ED}"etc/cups/*.default \
		"${ED}"etc/cups/snmp.conf \
		"${ED}"usr/bin/cancel \
		"${ED}"usr/libexec/cups/backend/snmp \
		"${ED}"usr/sbin/cupsctl \
		"${ED}"usr/sbin/cupsreject \
		"${ED}"usr/sbin/lpmove \
			|| die "failed to remove some files"
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	# Update desktop file database and gtk icon cache (bug 370059)
	gnome2_icon_cache_update
	fdo-mime_desktop_database_update

	# not slotted - at most one value
	if ! [[ "${REPLACING_VERSIONS}" ]]; then
		echo
		elog "For information about installing a printer and general cups setup"
		elog "take a look at: https://wiki.gentoo.org/wiki/Printing"
		echo
	fi

	if [[ "${REPLACING_VERSIONS}" ]] && [[ "${REPLACING_VERSIONS}" < "1.6" ]]; then
		echo
		elog "CUPS-1.6 no longer supports automatic remote printers or implicit classes"
		elog "via the CUPS, LDAP, or SLP protocols, i.e. \"network browsing\"."
		elog "You will have to find printers using zeroconf/avahi instead, enter"
		elog "the location manually, or run cups-browsed from net-print/cups-filters"
		elog "which re-adds that functionality as a separate daemon."
		echo
	fi

	if [[ "${REPLACING_VERSIONS}" == "1.6.2-r4" ]]; then
		ewarn
		ewarn "You are upgrading from the broken version net-print/cups-1.6.2-r4."
		ewarn "Please rebuild net-print/cups-filters now to make sure everything is OK."
		ewarn
	fi
}

pkg_postrm() {
	# Update desktop file database and gtk icon cache (bug 370059)
	gnome2_icon_cache_update
	fdo-mime_desktop_database_update
}