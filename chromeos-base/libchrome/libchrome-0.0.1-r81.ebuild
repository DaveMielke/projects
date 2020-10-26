# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

CROS_WORKON_COMMIT=("b733c2848a803e1b9a6fd4a71cf94edf76e98be5" "1ac79c369c0b144c948130c2f9661e14cc610dc3")
CROS_WORKON_TREE=("824835433089136b9e63f6cfd441ed8c093fa54c" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb" "b1a905d1cfa0add3ba4b442ea02833a5405db88d")
CROS_WORKON_PROJECT=("chromiumos/platform2" "aosp/platform/external/libchrome")
CROS_WORKON_LOCALNAME=("platform2" "aosp/external/libchrome")
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/platform2/libchrome")
CROS_WORKON_SUBTREE=("common-mk .gn" "")

WANT_LIBCHROME="no"
IS_LIBCHROME="yes"
inherit cros-workon libchrome-version platform

DESCRIPTION="Chrome base/ and dbus/ libraries extracted for use on Chrome OS"
HOMEPAGE="http://dev.chromium.org/chromium-os/packages/libchrome"
SRC_URI=""

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="cros_host +crypto +dbus fuzzer +mojo +timers"

PLATFORM_SUBDIR="libchrome"

# TODO(avakulenko): Put dev-libs/nss behind a USE flag to make sure NSS is
# pulled only into the configurations that require it.
# TODO(fqj): remove !chromeos-base/libchrome-${BASE_VER} on next uprev to r680000.
RDEPEND="
	dev-libs/double-conversion:=
	dev-libs/glib:2=
	dev-libs/libevent:=
	dev-libs/modp_b64:=
	crypto? (
		dev-libs/nss:=
		dev-libs/openssl:=
	)
	dbus? (
		sys-apps/dbus:=
		dev-libs/protobuf:=
	)
	dev-libs/re2:=
	!~chromeos-base/libchrome-576279
	!chromeos-base/libchrome:576279
	!chromeos-base/libchrome:462023
	!chromeos-base/libchrome:456626
	!chromeos-base/libchrome:395517
"
DEPEND="${RDEPEND}
	dev-cpp/gtest:=
"

# libmojo used to be in a separate package, which now conflicts with libchrome.
# Add softblocker here, to resolve the conflict, in case building the package
# on the environment where old libmojo is installed.
# TODO(hidehiko): Clean up the blocker after certain period.
RDEPEND="${RDEPEND}
	!chromeos-base/libmojo"

# libmojo depends on libbase-crypto.
REQUIRED_USE="mojo? ( crypto )"

src_prepare() {
	# epatch "${FILESDIR}"/${PN}-Replace-std-unordered_map-with-std-map-for-dbus-Prop.patch
	# epatch "${FILESDIR}"/${PN}-dbus-Filter-signal-by-the-sender-we-are-interested-i.patch
	# epatch "${FILESDIR}"/${PN}-dbus-Make-MockObjectManager-useful.patch
	# epatch "${FILESDIR}"/${PN}-dbus-Don-t-DCHECK-unexpected-message-type-but-ignore.patch
	# epatch "${FILESDIR}"/${PN}-Mock-more-methods-of-dbus-Bus-in-dbus-MockBus.patch

	# Disable custom memory allocator when asan is used.
	# https://crbug.com/807685
	use_sanitizers && epatch "${FILESDIR}"/${PN}-Disable-memory-allocator.patch

	# Disable object lifetime tracking since it cuases memory leaks in
	# sanitizer builds, https://crbug.com/908138
	# TODO
	# epatch "${FILESDIR}"/${PN}-Disable-object-tracking.patch

	# Apply patches
	while read -r patch; do
		epatch "${S}/libchrome_tools/patches/${patch}" || die "failed to patch ${patch}"
	done < <(grep -E '^[^#]' "${S}/libchrome_tools/patches/patches")
}

src_configure() {
	cros_optimize_package_for_speed
	platform_src_configure
}

src_install() {
	export BASE_VER="$(cat BASE_VER)"
	dolib.so "${OUT}"/lib/libbase*.so
	pushd "${OUT}/lib" || die
	for sofile in libbase*.so; do
		dosym "${sofile}" "/usr/$(get_libdir)/${sofile%.so}-${BASE_VER}.so"
	done
	popd || die
	dolib.a "${OUT}"/libbase*.a
	pushd "${OUT}" || die
	for afile in libbase*.a; do
		dosym "${afile}" "/usr/$(get_libdir)/${afile%.a}-${BASE_VER}.a"
	done
	popd || die

	local mojom_dirs=()
	local header_dirs=(
		base
		base/allocator
		base/containers
		base/debug
		base/files
		base/hash
		base/i18n
		base/json
		base/memory
		base/message_loop
		base/metrics
		base/numerics
		base/posix
		base/process
		base/strings
		base/synchronization
		base/system
		base/task
		base/task/common
		base/task/sequence_manager
		base/task/thread_pool
		base/third_party/icu
		base/third_party/nspr
		base/third_party/valgrind
		base/threading
		base/time
		base/timer
		base/trace_event
		base/trace_event/common
		build
		components/policy
		components/policy/core/common
		testing/gmock/include/gmock
		testing/gtest/include/gtest
	)
	use dbus && header_dirs+=( dbus )
	use timers && header_dirs+=( components/timers )

	insinto /usr/include/base-"${BASE_VER}"/base/test
	doins \
		base/test/bind_test_util.h \
		base/test/task_environment.h \
		base/test/scoped_run_loop_timeout.h \
		base/test/simple_test_clock.h \
		base/test/simple_test_tick_clock.h \
		base/test/task_environment.h \
		base/test/test_mock_time_task_runner.h \
		base/test/test_pending_task.h \
		base/test/test_timeouts.h \

	if use crypto; then
		insinto /usr/include/base-${BASE_VER}/crypto
		doins \
			crypto/crypto_export.h \
			crypto/hmac.h \
			crypto/libcrypto-compat.h \
			crypto/nss_key_util.h \
			crypto/nss_util.h \
			crypto/nss_util_internal.h \
			crypto/openssl_util.h \
			crypto/p224.h \
			crypto/p224_spake.h \
			crypto/random.h \
			crypto/rsa_private_key.h \
			crypto/scoped_nss_types.h \
			crypto/scoped_openssl_types.h \
			crypto/scoped_test_nss_db.h \
			crypto/secure_hash.h \
			crypto/secure_util.h \
			crypto/sha2.h \
			crypto/signature_creator.h \
			crypto/signature_verifier.h
	fi

	insinto /usr/$(get_libdir)/pkgconfig
	doins "${OUT}"/obj/libchrome/libchrome*.pc
	pushd "${OUT}"/obj/libchrome/ || die
	for pcfile in libchrome*.pc; do
		newins "${pcfile}" "${pcfile%.pc}-${BASE_VER}.pc"
	done
	popd || die

	# Install libmojo.
	if use mojo; then
		# Install binary.
		dolib.a "${OUT}"/libmojo.a
		dosym libmojo.a "/usr/$(get_libdir)/libmojo-${BASE_VER}.a"

		# Install headers.
		header_dirs+=(
			ipc
			mojo/core/
			mojo/core/embedder
			mojo/core/ports
			mojo/public/c/system
			mojo/public/cpp/base
			mojo/public/cpp/bindings
			mojo/public/cpp/bindings/lib
			mojo/public/cpp/platform
			mojo/public/cpp/system
		)
		mojom_dirs+=(
			mojo/public/interfaces/bindings
			mojo/public/mojom/base
		)

		# Install libmojo.pc.
		insinto /usr/$(get_libdir)/pkgconfig
		doins "${OUT}"/obj/libchrome/libmojo.pc
		newins "${OUT}"/obj/libchrome/libmojo.pc "libmojo-${BASE_VER}.pc"

		# Install generate_mojom_bindings.
		# TODO(hidehiko): Clean up tools' install directory.
		# TODO(fqj): Use unversioned path.
		insinto /usr/src/libmojo-"${BASE_VER}"/mojo
		doins -r mojo/public/tools/bindings/*
		doins -r mojo/public/tools/mojom/*
		doins build/gn_helpers.py
		doins -r build/android/gyp/util
		doins -r build/android/pylib
		exeinto /usr/src/libmojo-"${BASE_VER}"/mojo
		doexe libchrome_tools/mojom_generate_type_mappings.py

		insinto /usr/src/libmojo-"${BASE_VER}"/third_party
		doins -r third_party/jinja2
		doins -r third_party/markupsafe
		doins -r third_party/ply

		# Mark scripts executable.
		fperms +x \
			/usr/src/libmojo-"${BASE_VER}"/mojo/generate_type_mappings.py \
			/usr/src/libmojo-"${BASE_VER}"/mojo/mojom_bindings_generator.py \
			/usr/src/libmojo-"${BASE_VER}"/mojo/mojom_parser.py
	fi

	# Install header files.
	# TODO(fqj): Use unversioned path.
	local d
	for d in "${header_dirs[@]}" ; do
		insinto /usr/include/base-"${BASE_VER}"/"${d}"
		doins "${d}"/*.h
	done
	for d in "${mojom_dirs[@]}"; do
		insinto /usr/include/base-"${BASE_VER}"/"${d}"
		doins "${OUT}"/gen/include/"${d}"/*.h
		# Not to install mojom and pickle file to prevent misuse until Chromium IPC
		# team is ready to have a stable mojo_base. see crbug.com/1055379
		# insinto /usr/src/libchrome/mojom/"${d}"
		# doins "${S}"/"${d}"/*.mojom
		# insinto /usr/share/libchrome/pickle/"${d}"
		# doins "${OUT}"/gen/include/"${d}"/*.p
	done

	# TODO(fqj): Revisit later for type mapping (see libchrome/BUILD.gn)
	# Install libchrome base type mojo mapping
	# if use mojo; then
		# insinto /usr/share/libchrome/mojom_type_mappings_typemapping
		# doins "${OUT}"/gen/libchrome/mojom_type_mappings_typemapping
	# fi

	insinto /usr/share/libchrome
	doins BASE_VER
}