# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="0bb824acb759ff57bf2c9e06417b29cfd262a3de"
CROS_WORKON_TREE="86b48bf1c50fe4a926eec49d4dedf8c86a01696e"
CROS_WORKON_BLACKLIST=1
CROS_WORKON_LOCALNAME="aosp/external/minijail"
CROS_WORKON_PROJECT="platform/external/minijail"
CROS_WORKON_REPO="https://android.googlesource.com"

# TODO(crbug.com/689060): Re-enable on ARM.
CROS_COMMON_MK_NATIVE_TEST="yes"

inherit cros-debug cros-sanitizers cros-workon cros-common.mk toolchain-funcs multilib

DESCRIPTION="helper binary and library for sandboxing & restricting privs of services"
HOMEPAGE="https://android.googlesource.com/platform/external/minijail"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="asan cros-debug +seccomp test"

COMMON_DEPEND="sys-libs/libcap:=
	!<chromeos-base/chromeos-minijail-1"
RDEPEND="${COMMON_DEPEND}"
DEPEND="${COMMON_DEPEND}
	test? (
		dev-cpp/gtest:=
	)"

src_configure() {
	sanitizers-setup-env
	cros-common.mk_src_configure
	export LIBDIR="/$(get_libdir)"
	export USE_seccomp=$(usex seccomp)
	export ALLOW_DEBUG_LOGGING=$(usex cros-debug)
	export USE_SYSTEM_GTEST=yes
	export DEFAULT_PIVOT_ROOT=/mnt/empty
}

src_compile() {
	# Avoid confusing people with our docs.
	sed -i "s:/var/empty:${DEFAULT_PIVOT_ROOT}:g" minijail0.[15] || die

	cros-common.mk_src_compile all $(usex cros_host parse_seccomp_policy '')
}

src_install() {
	into /
	dosbin "${OUT}"/minijail0
	dolib.so "${OUT}"/libminijail{,preload}.so
	use cros_host && dobin "${OUT}"/parse_seccomp_policy

	doman minijail0.[15]

	local include_dir="/usr/include/chromeos"

	"${S}"/platform2_preinstall.sh "${PV}" "${include_dir}"
	insinto "/usr/$(get_libdir)/pkgconfig"
	doins libminijail.pc

	insinto "${include_dir}"
	doins libminijail.h
	doins scoped_minijail.h
}
