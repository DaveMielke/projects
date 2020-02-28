# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

CROS_WORKON_COMMIT="ec76a36521debc8c8bbc94b9d1f6ddc0e0a90759"
CROS_WORKON_TREE="8d50862d97b4a50016ca18cc0d9c709d88a868c2"
CROS_WORKON_PROJECT="chromiumos/third_party/virglrenderer"

# Prevent automatic uprevs of this package since upstream is out of our control.
CROS_WORKON_BLACKLIST="1"

inherit cros-fuzzer cros-sanitizers eutils flag-o-matic meson toolchain-funcs cros-workon

DESCRIPTION="library used implement a virtual 3D GPU used by qemu"
HOMEPAGE="https://virgil3d.github.io/"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="debug fuzzer profiling test"

RDEPEND="
	>=x11-libs/libdrm-2.4.50
	media-libs/libepoxy
	media-libs/minigbm
	fuzzer? (
		virtual/opengles
	)
"
# We need autoconf-archive for @CODE_COVERAGE_RULES@. #568624
DEPEND="${RDEPEND}
	sys-devel/autoconf-archive
	fuzzer? ( >=dev-libs/check-0.9.4 )
	test? ( >=dev-libs/check-0.9.4 )"

PATCHES=(
	"${FILESDIR}"/0001-CHROMIUM-Adjust-plane-parameter.patch
	"${FILESDIR}"/0001-virgl-gbm-Also-convert-VIRGL_BIND_SAMPLER_VIEW.patch
)

src_prepare() {
	default
}

src_configure() {
	sanitizers-setup-env

	if use profiling; then
		append-flags -fprofile-instr-generate -fcoverage-mapping
		append-ldflags -fprofile-instr-generate -fcoverage-mapping
	fi

	emesonargs+=(
		-Dgbm_allocation="true"
		-Dplatforms="egl"
		$(meson_use fuzzer)
		--buildtype $(usex debug debug release)
	)

	# virgl_fuzzer is only built with tests.
	if use test || use fuzzer; then
		emesonargs+=( -Dtests="true" )
	fi

	meson_src_configure
}

src_install() {
	meson_src_install

	fuzzer_install "${FILESDIR}/fuzzer-OWNERS" \
		"${WORKDIR}/${P}-build"/tests/fuzzer/virgl_fuzzer \
		--options "${FILESDIR}/virgl_fuzzer.options"
	fuzzer_install "${FILESDIR}/fuzzer-OWNERS" \
		"${WORKDIR}/${P}-build"/vtest/vtest_fuzzer \
		--options "${FILESDIR}/vtest_fuzzer.options"

	find "${ED}"/usr -name 'lib*.la' -delete
}
