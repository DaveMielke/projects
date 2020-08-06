# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=6

CROS_WORKON_COMMIT=("f8d0f6ce00239e339c164c792481e996d3948ee1" "aea7f094510c27c54b320c26a1d31eb366e0dc45")
CROS_WORKON_TREE=("638bfde957a502ad58d182712c1ebdf335f9a3da" "1fed4a8ba5e60338aecf8c9601a25b9e590de6ed")
CROS_WORKON_PROJECT=(
	"chromiumos/platform2"
	"chromiumos/platform/mosys"
)
CROS_WORKON_LOCALNAME=(
	"../platform2"
	"../platform/mosys"
)
CROS_WORKON_DESTDIR=(
	"${S}/platform2"
	"${S}/platform/mosys"
)
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_SUBTREE=(
	"common-mk"
	""
)

MESON_AUTO_DEPEND=no

WANT_LIBCHROME="no"
WANT_LIBBRILLO="no"

inherit meson flag-o-matic toolchain-funcs cros-unibuild cros-workon platform

DESCRIPTION="Utility for obtaining various bits of low-level system info"
HOMEPAGE="http://mosys.googlecode.com/"

LICENSE="BSD-Google BSD Apache-2.0 MIT ISC Unlicense"
SLOT="0"
KEYWORDS="*"
IUSE="generated_cros_config unibuild"

RDEPEND="unibuild? (
		!generated_cros_config? ( chromeos-base/chromeos-config )
		generated_cros_config? ( chromeos-base/chromeos-config-bsp:= )
	)
	dev-util/cmocka
	>=sys-apps/flashmap-0.3-r4
	chromeos-base/minijail"
DEPEND="${RDEPEND}"

src_unpack() {
	cros-workon_src_unpack
	PLATFORM_TOOLDIR="${S}/platform2/common-mk"
	S+="/platform/mosys"
}

src_configure() {
	local platform_intf=""
	local emesonargs=(
		$(meson_use unibuild use_cros_config)
		-Darch=$(tc-arch)
	)

	if use unibuild; then
		emesonargs+=(
			"-Dcros_config_data_src=${SYSROOT}${UNIBOARD_C_CONFIG}"
		)
		platform_intf="$(cros_config_host get-mosys-platform)"
	else
		# TODO(jrosenth): hard code some board to platform_intf
		# mappings here for legacy non-unibuild boards.  For now, this
		# feature is unibuild only.
		true
	fi

	if [[ -n "${platform_intf}" ]]; then
		emesonargs+=(
			"-Dplatform_intf=${platform_intf}"
		)
	fi

	# Necessary to enable LTO.  See crbug.com/1082378.
	append-ldflags "-O2"

	meson_src_configure
}

src_compile() {
	meson_src_compile
}

platform_pkg_test() {
	local tests=(
		file_unittest
		math_unittest
		platform_unittest
	)
	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" \
			"${BUILD_DIR}/unittests/${test_bin}"
	done
}

src_install() {
	dosbin "${BUILD_DIR}/mains/mosys"

	insinto /usr/share/policy
	newins "seccomp/mosys-seccomp-${ARCH}.policy" mosys-seccomp.policy
	dodoc README
}