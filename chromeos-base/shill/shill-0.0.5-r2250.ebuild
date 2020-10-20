# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="d25de4ac6bf1e04041ee8b53277b9ce71e028b46"
CROS_WORKON_TREE=("a4ac7e852c3c0913e89f5edb694fd3ec3c9a3cc7" "377caa22e8416ce2388b9c099e85be393001947f" "9aaa4eb6d654cc8a8c3032148045b634ec3f01ff" "f8e383f8fd558b8b901e32960ff8488b4a9b042b" "963e076a0b7311a4a5e1c14646f9a5d50c209ef7" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
# TODO(crbug.com/809389): Avoid directly including headers from other packages.
CROS_WORKON_SUBTREE="common-mk libpasswordprovider metrics shill vpn-manager .gn"

PLATFORM_SUBDIR="shill"

inherit cros-workon platform systemd udev user

DESCRIPTION="Shill Connection Manager for Chromium OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/shill/"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="cellular dhcpv6 fast_transition fuzzer kernel-3_8 kernel-3_10 pppoe +seccomp systemd +tpm +vpn wake_on_wifi +wifi +wired_8021x"

# Sorted by the package we depend on. (Not by use flag!)
COMMON_DEPEND="
	chromeos-base/bootstat:=
	tpm? ( chromeos-base/chaps:= )
	chromeos-base/minijail:=
	chromeos-base/libpasswordprovider:=
	>=chromeos-base/metrics-0.0.1-r3152:=
	chromeos-base/nsswitch:=
	chromeos-base/patchpanel-client:=
	chromeos-base/shill-net:=
	dev-libs/re2:=
	cellular? ( net-dialup/ppp:= )
	pppoe? ( net-dialup/ppp:= )
	vpn? ( net-dialup/ppp:= )
	net-dns/c-ares:=
	net-libs/libtirpc:=
	net-firewall/iptables:=
	net-libs/libnetfilter_queue:=
	net-libs/libnfnetlink:=
	wifi? ( virtual/wpa_supplicant )
	wired_8021x? ( virtual/wpa_supplicant )
	sys-apps/rootdev:=
	cellular? ( net-misc/modemmanager-next:= )
	!kernel-3_10? ( !kernel-3_8? ( net-firewall/conntrack-tools:= ) )
"

RDEPEND="${COMMON_DEPEND}
	chromeos-base/patchpanel
	net-misc/dhcpcd
	dhcpv6? ( net-misc/dhcpcd[ipv6] )
	vpn? ( net-vpn/openvpn )
"
DEPEND="${COMMON_DEPEND}
	chromeos-base/shill-client:=
	chromeos-base/power_manager-client:=
	chromeos-base/system_api:=[fuzzer?]
	vpn? ( chromeos-base/vpn-manager:= )"

pkg_setup() {
	enewgroup "shill"
	enewuser "shill"
	cros-workon_pkg_setup
}

pkg_preinst() {
	enewgroup "shill-crypto"
	enewuser "shill-crypto"
	enewgroup "shill-scripts"
	enewuser "shill-scripts"
	enewgroup "nfqueue"
	enewuser "nfqueue"
}

get_dependent_services() {
	local dependent_services=()
	if use wifi || use wired_8021x; then
		dependent_services+=(wpasupplicant)
	fi
	if use systemd; then
		echo "network-services.service ${dependent_services[*]/%/.service }"
	else
		echo "started network-services " \
			"${dependent_services[*]/#/and started }"
	fi
}

src_configure() {
	cros_optimize_package_for_speed
	platform_src_configure
}

src_install() {
	dobin bin/ff_debug

	if use cellular; then
		dobin bin/set_apn
		dobin bin/set_cellular_ppp
	fi

	dosbin bin/set_wifi_regulatory
	dobin bin/set_arpgw
	dobin bin/set_wake_on_lan
	dobin bin/shill_login_user
	dobin bin/shill_logout_user
	if use wifi || use wired_8021x; then
		dobin bin/wpa_debug
	fi
	dobin "${OUT}"/shill

	# Deprecated.  On Linux 3.12+ conntrackd is used instead.
	local netfilter_queue_helper=no
	if use kernel-3_8 || use kernel-3_10; then
		netfilter_queue_helper=yes
	fi

	if [[ "${netfilter_queue_helper}" == "yes" ]]; then
		# Netfilter queue helper is run directly from init, so install
		# in sbin.
		dosbin "${OUT}"/netfilter-queue-helper
		dosbin init/netfilter-common
	fi

	# Install Netfilter queue helper syscall filter policy file.
	insinto /usr/share/policy
	use seccomp && newins shims/nfqueue-seccomp-${ARCH}.policy nfqueue-seccomp.policy

	local shims_dir=/usr/$(get_libdir)/shill/shims
	exeinto "${shims_dir}"

	use vpn && doexe "${OUT}"/openvpn-script
	if use cellular || use pppoe || use vpn; then
		newexe "${OUT}"/lib/libshill-pppd-plugin.so shill-pppd-plugin.so
	fi

	use cellular && doexe "${OUT}"/set-apn-helper

	if use wifi || use wired_8021x; then
		sed \
			"s,@libdir@,/usr/$(get_libdir)", \
			shims/wpa_supplicant.conf.in \
			> "${D}/${shims_dir}/wpa_supplicant.conf"
	fi

	dosym /run/shill/resolv.conf /etc/resolv.conf
	insinto /etc/dbus-1/system.d
	doins shims/org.chromium.flimflam.conf

	if use cellular; then
		insinto /usr/share/shill
		doins "${OUT}"/serviceproviders.pbf
		insinto /usr/share/protofiles
		doins "${S}/mobile_operator_db/mobile_operator_db.proto"
	fi

	# Install introspection XML
	insinto /usr/share/dbus-1/interfaces
	doins dbus_bindings/org.chromium.flimflam.*.dbus-xml
	doins dbus_bindings/dbus-service-config.json

	# Replace template parameters inside init scripts
	local shill_name="shill.$(usex systemd service conf)"
	sed \
		"s,@expected_started_services@,$(get_dependent_services)," \
		"init/${shill_name}.in" \
		> "${T}/${shill_name}"

	# Install init scripts
	if use systemd; then
		if [[ "${netfilter_queue_helper}" == "yes" ]]; then
			systemd_dounit init/netfilter-queue.service
			systemd_enable_service network.target \
				netfilter-queue.service
		fi
		systemd_dounit init/shill-start-user-session.service
		systemd_dounit init/shill-stop-user-session.service

		local dependent_services=$(get_dependent_services)
		systemd_dounit "${T}/shill.service"
		for dependent_service in ${dependent_services}; do
			systemd_enable_service "${dependent_service}" shill.service
		done
		systemd_enable_service shill.service network.target

		systemd_dounit init/network-services.service
		systemd_enable_service boot-services.target network-services.service
	else
		insinto /etc/init

		doins "${T}"/*.conf
		doins \
			init/network-services.conf \
			init/shill-event.conf \
			init/shill-start-user-session.conf \
			init/shill-stop-user-session.conf \
			init/shill_respawn.conf
		if [[ "${netfilter_queue_helper}" == "yes" ]]; then
			doins init/netfilter-queue.conf
		fi
	fi
	exeinto /usr/share/cros/init
	doexe init/*.sh

	insinto /usr/share/cros/startup/process_management_policies
	doins setuid_restrictions/shill_allowed.txt

	udev_dorules udev/*.rules

	# Shill keeps profiles inside the user's cryptohome.
	local daemon_store="/etc/daemon-store/shill"
	dodir "${daemon_store}"
	fperms 0700 "${daemon_store}"
	fowners shill:shill "${daemon_store}"

	local fuzzer
	for fuzzer in "${OUT}"/*_fuzzer; do
		platform_fuzzer_install "${S}"/OWNERS "${fuzzer}"
	done
}

platform_pkg_test() {
	platform_test "run" "${OUT}/shill_unittest"
}