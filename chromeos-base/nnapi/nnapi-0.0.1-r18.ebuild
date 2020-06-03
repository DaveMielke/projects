# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_COMMIT=("e18d4b688c96570a1dd29ef81c1bcc2e4c4a2d21" "a2753728d4f1bb7960b76d4cdd03a17afd4f5fd3" "8b529c2a6a966c93de4e89f08e746da4a4307e04" "357ba7427eb2b49467d39c09d57439fab3898467" "cce41c55319e81218ef5c6f1a322adcd249c5abb" "911852c231f779d1aee1e759c146e63f05e00d8f")
CROS_WORKON_TREE=("4c23cb26be092f90ba8160118d643548e3a14a89" "0bd23fb47998ffe5b117369bb362250ef20975d6" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb" "4256bcdd9e9435828bf8159d85af015450112aff" "b4147760c8f1da9f6749f61748d2cacf89237717" "dc37c5c3ce7989055b7a2d5a2dcc5d605ee189d7" "078088f837cd0a9b1c3123b5d93904f4ec2f2af6" "43a23f8182e90441b011501ddd6b5284200552b0")
CROS_WORKON_PROJECT=(
	"chromiumos/platform2"
	"aosp/platform/system/core/base"
	"aosp/platform/system/core/libcutils"
	"aosp/platform/system/core/liblog"
	"aosp/platform/system/core/libutils"
	"aosp/platform/system/libhidl"
)
CROS_WORKON_REPO=(
	"${CROS_GIT_HOST_URL}"
	"${CROS_GIT_HOST_URL}"
	"${CROS_GIT_HOST_URL}"
	"${CROS_GIT_HOST_URL}"
	"${CROS_GIT_HOST_URL}"
	"${CROS_GIT_HOST_URL}"
)
CROS_WORKON_LOCALNAME=(
	"platform2"
	"aosp/system/core/base"
	"aosp/system/core/libcutils"
	"aosp/system/core/liblog"
	"aosp/system/core/libutils"
	"aosp/system/libhidl"
)
CROS_WORKON_DESTDIR=(
	"${S}/platform2"
	"${S}/platform2/aosp/system/core/base"
	"${S}/platform2/aosp/system/core/libcutils"
	"${S}/platform2/aosp/system/core/liblog"
	"${S}/platform2/aosp/system/core/libutils"
	"${S}/platform2/aosp/system/libhidl"
)
CROS_WORKON_SUBTREE=(
	"common-mk nnapi .gn"
	""
	""
	""
	""
	""
)

PLATFORM_SUBDIR="nnapi"

inherit cros-workon platform epatch

DESCRIPTION="Chrome OS support utils for Android Neural Network API"
HOMEPAGE="https://developer.android.com/ndk/guides/neuralnetworks"

LICENSE="BSD-Google  Apache-2.0"
KEYWORDS="*"
IUSE=""

RDEPEND="
"

DEPEND="
	${RDEPEND}
"

PATCHES=(
	"${FILESDIR}/00001-libbase-fix-stderr-logging.patch"
)

src_prepare() {
	# The workdir is platform2/nnapi - we need to pop up one level in the stack
	# to apply our patches.
	pushd .. || exit
	eapply -p2 "${FILESDIR}/00001-libbase-fix-stderr-logging.patch"
	popd || exit

	eapply_user
}

src_install() {
	einfo "Installing Android headers."
	insinto /usr/include/aosp
	doins -r includes/*
	doins -r ../aosp/system/core/base/include/*
	doins -r ../aosp/system/core/libcutils/include/*
	doins -r ../aosp/system/core/liblog/include/*
	doins -r ../aosp/system/core/libutils/include/*
	doins -r ../aosp/system/libhidl/base/include/*
	doins -r ../aosp/system/libhidl/libhidlmemory/include/*

	einfo "Installing static library."
	dolib.a "${OUT}/libnnapi-support.a"

	insinto "/usr/$(get_libdir)/pkgconfig"
	doins "${OUT}/obj/nnapi/libnnapi-support.pc"
}

platform_pkg_test() {
	local tests=(
		base cutils hidl log utils
	)

	local test_target
	for test_target in "${tests[@]}"; do
		platform_test "run" "${OUT}/lib${test_target}_testrunner"
	done
}
