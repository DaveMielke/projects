# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE.makefile file.

EAPI=7

CROS_WORKON_COMMIT=("1053611f0a319dae5aea5ac8452d04ca57376987" "51c319ff23b6e5d6b3d8deb539a063edffb24483")
CROS_WORKON_TREE=("864ce77016e71f06fb0e326bf5b0f4c117b2838a" "5b25e42c84714218b06757c9d47399820bb64da5")
CROS_WORKON_PROJECT=(
	"chromiumos/platform/ec"
	"chromiumos/third_party/cryptoc"
)
CROS_WORKON_LOCALNAME=(
	"ec"
	"../third_party/cryptoc"
)
CROS_WORKON_DESTDIR=(
	"${S}/platform/ec"
	"${S}/third_party/cryptoc"
)

inherit toolchain-funcs cros-workon cros-unibuild coreboot-sdk

DESCRIPTION="ECOS ISH image"
HOMEPAGE="https://www.chromium.org/chromium-os/ec-development"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="quiet verbose coreboot-sdk unibuild test"
REQUIRED_USE="unibuild"

COMMON_DEPEND="
	test? (
		dev-libs/openssl:=
		dev-libs/protobuf:=
	)
"

RDEPEND="${COMMON_DEPEND}"

# EC build requires libftdi, but not used for runtime (b:129129436)
DEPEND="
	dev-embedded/libftdi:1=
	chromeos-base/chromeos-config
	test? ( dev-libs/libprotobuf-mutator:= )
	${COMMON_DEPEND}
"

src_unpack() {
	cros-workon_src_unpack
	S+="/platform/ec"
}

src_prepare() {
	default

	cros_use_gcc
}

src_configure() {
	cros-workon_src_configure
}

set_build_env() {
	# always use coreboot-sdk to build ISH
	export CROSS_COMPILE_i386=${COREBOOT_SDK_PREFIX_x86_32}
	export CROSS_COMPILE_coreboot_sdk_i386=${COREBOOT_SDK_PREFIX_x86_32}

	tc-export CC BUILD_CC
	export BUILDCC="${BUILD_CC}"

	ish_targets=($(cros_config_host get-firmware-build-targets ish))

	EC_OPTS=()
	use quiet && EC_OPTS+=( -s V=0 )
	use verbose && EC_OPTS+=( V=1 )
}


src_compile() {
	set_build_env

	local target
	einfo "Building targets: ${ish_targets[@]}"
	for target in "${ish_targets[@]}"; do
		BOARD="${target}" emake "${EC_OPTS[@]}" clean
		BOARD="${target}" emake "${EC_OPTS[@]}" all
	done
}

src_test() {
	set_build_env

	emake "${EC_OPTS[@]}" runhosttests
}

src_install() {
	set_build_env

	local target
	insinto "/lib/firmware/intel/"

	einfo "Installing targets: ${ish_targets[@]}"
	for target in "${ish_targets[@]}"; do
		newins "build/${target}/ec.bin" "${target}.bin" \
			|| die "Couldn't install ${target}"
	done
}
