# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=6

CROS_WORKON_COMMIT="757675c0110ee2de0b787f8408417a201ea7d641"
CROS_WORKON_TREE=("13277321c94a2f8ea0ff6bf7d8c246ffd349380a" "043a97bc52491a845a5ec6237ab833bb46832c4d" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"
CROS_WORKON_SUBTREE="common-mk metrics .gn"

PLATFORM_SUBDIR="metrics"

inherit cros-constants cros-workon platform systemd user

DESCRIPTION="Metrics aggregation service for Chromium OS"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="fuzzer metrics_uploader +passive_metrics systemd"

RDEPEND="
	chromeos-base/libbrillo
	dev-libs/dbus-glib
	dev-libs/libpcre
	dev-libs/protobuf:=
	sys-apps/rootdev
	"

DEPEND="
	${RDEPEND}
	chromeos-base/session_manager-client
	chromeos-base/system_api:=[fuzzer?]
	chromeos-base/vboot_reference
	"

src_install() {
	dobin "${OUT}"/metrics_client
	dobin "${OUT}"/chromeos-pgmem

	if use passive_metrics; then
		dobin "${OUT}"/metrics_daemon
		if use systemd; then
			systemd_dounit init/metrics-daemon.service
			systemd_enable_service multi-user.target metrics-daemon.service
			systemd_dotmpfilesd init/metrics.conf
		else
			insinto /etc/init
			doins init/metrics_library.conf init/metrics_daemon.conf
		fi

		if use metrics_uploader; then
			if use systemd; then
				sed -i '/ExecStart=/s:metrics_daemon:metrics_daemon -uploader:' \
					"${D}"/usr/lib/systemd/system/metrics-daemon.service || die
			else
				sed -i '/DAEMON_FLAGS=/s:=.*:="-uploader":' \
					"${D}"/etc/init/metrics_daemon.conf || die
			fi
		fi
	fi

	insinto /usr/$(get_libdir)/pkgconfig
	for v in "${LIBCHROME_VERS[@]}"; do
		./platform2_preinstall.sh "${OUT}" "${v}"
		dolib.so "${OUT}/lib/libmetrics-${v}.so"
		doins "${OUT}/lib/libmetrics-${v}.pc"
	done

	insinto /usr/include/metrics
	doins c_metrics_library.h \
		cumulative_metrics.h \
		metrics_library{,_mock}.h \
		persistent_integer.h \
		timer{,_mock}.h

	# Install the protobuf so that autotests can have access to it.
	insinto /usr/include/metrics/proto
	doins uploader/proto/*.proto

	platform_fuzzer_install "${S}"/OWNERS "${OUT}"/metrics_library_consent_id_fuzzer
	platform_fuzzer_install "${S}"/OWNERS \
		"${OUT}"/metrics_serialization_utils_fuzzer
}

platform_pkg_test() {
	local tests=(
		cumulative_metrics_test
		metrics_library_test
		$(usex passive_metrics 'metrics_daemon_test' '')
		persistent_integer_test
		process_meter_test
		timer_test
		upload_service_test
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}

pkg_preinst() {
	enewuser metrics
	enewgroup metrics
}
