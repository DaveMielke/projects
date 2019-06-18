# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=6

CROS_WORKON_COMMIT="98f083add19231e12dc07164905979737e645cc5"
CROS_WORKON_TREE=("bf86ccd52a8994e8c841d7b0a530173caaa5818f" "33f5b269087b449427d1bec8176f6b521e65ce14" "dc1506ef7c8cfd2c5ffd1809dac05596ec18773c")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_SUBTREE="common-mk diagnostics .gn"

PLATFORM_SUBDIR="diagnostics"

inherit cros-workon platform udev user

DESCRIPTION="Device telemetry and diagnostics for Chrome OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/diagnostics"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="+seccomp wilco"

COMMON_DEPEND="
	chromeos-base/libbrillo:=
	dev-libs/protobuf:=
	dev-libs/re2:=
	net-libs/grpc:=
	virtual/libudev:=
"
DEPEND="
	${COMMON_DEPEND}
	chromeos-base/system_api
"
RDEPEND="
	${COMMON_DEPEND}
	chromeos-base/minijail
	wilco? ( chromeos-base/chromeos-dtc-vm-sarien-private )
	wilco? ( chromeos-base/vpd )
"

pkg_preinst() {
	enewuser cros_healthd
	enewgroup cros_healthd

	if use wilco; then
		enewuser wilco_dtc
		enewgroup wilco_dtc
	fi
}

src_install() {
	dobin "${OUT}/cros_healthd"
	dobin "${OUT}/diag"
	dobin "${OUT}/telem"

	if use wilco; then
		dobin "${OUT}/wilco_dtc_supportd"

		# Install seccomp policy files.
		insinto /usr/share/policy
		use seccomp && newins "init/wilco_dtc_supportd-seccomp-${ARCH}.policy" \
			wilco_dtc_supportd-seccomp.policy

		# Install D-Bus configuration file.
		insinto /etc/dbus-1/system.d
		doins dbus/org.chromium.WilcoDtcSupportd.conf
		doins dbus/WilcoDtcUpstart.conf

		# Install the init scripts.
		insinto /etc/init
		doins init/wilco_dtc_dispatcher.conf
		doins init/wilco_dtc_supportd.conf
		doins init/wilco_dtc.conf
	fi

	# Install the diagnostic routine executables.
	exeinto /usr/libexec/diagnostics
	doexe "${OUT}/urandom"
	doexe "${OUT}/smartctl-check"

	# Install udev rules.
	udev_dorules udev/*.rules
}

platform_pkg_test() {
	local tests=(
		cros_healthd_test
		libdiag_test
		libgrpc_async_adapter_test
		libtelem_test
		routine_test
	)
	if use wilco; then
		tests+=( wilco_dtc_supportd_test )
	fi

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}
