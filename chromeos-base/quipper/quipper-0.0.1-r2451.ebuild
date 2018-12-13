# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# Don't use Makefile.external here as it fetches from the network.
EAPI="5"

CROS_WORKON_COMMIT="25a5cbf24eda611a7c4a09d69733ef8758f02f28"
CROS_WORKON_TREE="6f3635a6f5b0951a7ffdebd896518c01b04cc21b"
CROS_WORKON_INCREMENTAL_BUILD=1

CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"
# chromiumos-wide-profiling directory is in $SRC_URI, not in platform2.
CROS_WORKON_SUBTREE="common-mk"

PLATFORM_SUBDIR="chromiumos-wide-profiling"

inherit cros-workon platform

DESCRIPTION="quipper: chromiumos wide profiling"
HOMEPAGE="http://www.chromium.org/chromium-os/profiling-in-chromeos"
GIT_SHA1="b3a6fe448ca5f4b84a33bbe36bafe281679c3c3f"
SRC="quipper-${GIT_SHA1}.tar.gz"
SRC_URI="gs://chromeos-localmirror/distfiles/${SRC}"
SRC_DIR="src/${PN}"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	>=dev-cpp/gflags-2.0
	>=dev-libs/glib-2.30
	dev-libs/re2
	dev-util/perf
"

DEPEND="${RDEPEND}
	chromeos-base/protofiles
	test? ( app-shells/dash )
"

src_unpack() {
	platform_src_unpack
	mkdir "${S}"

	pushd "${S}" >/dev/null
	unpack ${SRC}
	mv "${SRC_DIR}"/{.[!.],}* ./ || die
	epatch "${FILESDIR}"/quipper-disable-flaky-tests.patch
	epatch "${FILESDIR}"/quipper-gyp.patch
	epatch "${FILESDIR}"/quipper-build.patch
	epatch "${FILESDIR}"/quipper-fuzzer.patch
	epatch "${FILESDIR}"/quipper-owners.patch
	popd >/dev/null
}

src_compile() {
	# ARM tests run on qemu which is much slower. Exclude some large test
	# data files for non-x86 boards.
	if use x86 || use amd64 ; then
		append-cppflags -DTEST_LARGE_PERF_DATA
	fi

	platform_src_compile
}

src_install() {
	dobin "${OUT}"/quipper
	platform_fuzzer_install "${S}"/OWNERS "${OUT}"/quipper_perf_reader_read_fuzzer
}

platform_pkg_test() {
	local tests=(
		integration_tests
		perf_recorder_test
		unit_tests
	)
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}" "1"
	done
}
