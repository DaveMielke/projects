# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT=("5deacc703881caaaaa5fbaf8cb81cba5c1df21b8" "a7a34d80adcc67b51f337c8d58034cf43bd882a9")
CROS_WORKON_TREE=("1440996879b9973e604a30d2d1df602722784f76" "c12755d5029137f1f730978cdb8217ff7d345d47")
CROS_WORKON_BLACKLIST=1
CROS_WORKON_LOCALNAME=("platform2" "aosp/system/update_engine")
CROS_WORKON_PROJECT=("chromiumos/platform2" "platform/system/update_engine")
CROS_WORKON_REPO=("https://chromium.googlesource.com" "https://android.googlesource.com")
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/aosp/system/update_engine")
CROS_WORKON_USE_VCSID=1
CROS_WORKON_INCREMENTAL_BUILD=1

PLATFORM_SUBDIR="update_engine"

inherit toolchain-funcs cros-debug cros-workon platform

DESCRIPTION="Chrome OS Update Engine"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="cros_p2p -delta_generator -hwid_override mtd +power_management"

COMMON_DEPEND="app-arch/bzip2
	chromeos-base/chromeos-ca-certificates
	chromeos-base/libchromeos
	chromeos-base/metrics
	chromeos-base/vboot_reference
	cros_p2p? ( chromeos-base/p2p )
	dev-libs/expat
	dev-libs/openssl
	dev-libs/protobuf
	dev-util/bsdiff
	net-misc/curl
	sys-apps/rootdev"

DEPEND="chromeos-base/system_api
	dev-cpp/gmock
	dev-cpp/gtest
	mtd? ( dev-embedded/android_mtdutils )
	sys-fs/e2fsprogs
	${COMMON_DEPEND}"

RDEPEND="
	chromeos-base/chromeos-installer
	${COMMON_DEPEND}
	power_management? ( chromeos-base/power_manager )
	delta_generator? ( sys-fs/e2fsprogs )
	virtual/update-policy
"

src_unpack() {
	local s="${S}"
	platform_src_unpack
	S="${s}/aosp/system/update_engine"
}

platform_pkg_test() {
	local unittests_binary="${OUT}"/update_engine_unittests

	# The unittests will try to exec `./helpers`, so make sure we're in
	# the right dir to execute things.
	cd "${OUT}"
	# The tests also want keys to be in the current dir.
	# .pub.pem files are generated on the "gen" directory.
	for f in unittest_key.pub.pem unittest_key2.pub.pem; do
		cp "${S}"/${f/.pub} ./ || die
		ln -fs gen/include/update_engine/$f $f  \
			|| die "Error creating the symlink for $f."
	done

	# The unit tests check to make sure the minor version value in
	# update_engine.conf match the constants in update engine, so we need to be
	# able to access this file.
	cp "${S}/update_engine.conf" ./

	if ! use x86 && ! use amd64 ; then
		einfo "Skipping tests on non-x86 platform..."
	else
		# If GTEST_FILTER isn't provided, we run two subsets of tests
		# separately: the set of non-privileged  tests (run normally)
		# followed by the set of privileged tests (run as root).
		# Otherwise, we pass the GTEST_FILTER environment variable as
		# an argument and run all the tests as root; while this might
		# lead to tests running with excess privileges, it is necessary
		# in order to be able to run every test, including those that
		# need to be run with root privileges.
		if [[ -z "${GTEST_FILTER}" ]]; then
			platform_test "run" "${unittests_binary}" 0 '-*.RunAsRoot*' \
			|| die "${unittests_binary} (unprivileged) failed, retval=$?"
			platform_test "run" "${unittests_binary}" 1 '*.RunAsRoot*' \
			|| die "${unittests_binary} (root) failed, retval=$?"
		else
			platform_test "run" "${unittests_binary}" 1 "${GTEST_FILTER}" \
			|| die "${unittests_binary} (root) failed, retval=$?"
		fi
	fi
}

src_install() {
	dosbin "${OUT}"/update_engine
	dobin "${OUT}"/update_engine_client

	use delta_generator && dobin "${OUT}"/delta_generator

	insinto /etc
	doins update_engine.conf

	# Install upstart script
	insinto /etc/init
	doins init/update-engine.conf

	# Install DBus configuration
	insinto /etc/dbus-1/system.d
	doins UpdateEngine.conf

	local client_includes=/usr/include/update_engine-client
	local client_test_includes=/usr/include/update_engine-client-test

	# Install DBus proxy headers
	insinto "${client_includes}/update_engine"
	doins "${OUT}/gen/include/update_engine/dbus-proxies.h"
	doins "${S}/dbus_constants.h"
	insinto "${client_test_includes}/update_engine"
	doins "${OUT}/gen/include/update_engine/dbus-proxy-mocks.h"

	# Install pkg-config for client libraries.
	./generate_pc_file.sh "${OUT}" libupdate_engine-client "${client_includes}" ||
		die "Error generating libupdate_engine-client.pc file"
	./generate_pc_file.sh "${OUT}" libupdate_engine-client-test "${client_test_includes}" ||
		die "Error generating libupdate_engine-client-test.pc file"
	insinto "/usr/$(get_libdir)/pkgconfig"
	doins "${OUT}/libupdate_engine-client.pc"
	doins "${OUT}/libupdate_engine-client-test.pc"
}
