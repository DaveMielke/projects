# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=6

CROS_WORKON_COMMIT="aa87ba1a4b38be2ffb16f363e76f0f0fe2eb61bc"
CROS_WORKON_TREE=("c5e851c0a9f693b39a3385a86e1075e6de1ce2e9" "5f6a02f01e64e4cf149cda26697413ad7bd23ea8" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
CROS_GO_PACKAGES=(
	"chromiumos/vm_tools/..."
)

CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk vm_tools/proto .gn"

PLATFORM_SUBDIR="vm_tools/proto"

inherit cros-go cros-workon multilib platform

DESCRIPTION="Chrome OS VM protobuf API"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/vm_tools/proto"
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="fuzzer"

RDEPEND="
	dev-libs/protobuf:=
	net-libs/grpc:=
	!<chromeos-base/vm_guest_tools-0.0.2
	!<chromeos-base/vm_host_tools-0.0.2
"
DEPEND="
	${RDEPEND}
	dev-go/protobuf
	dev-go/grpc
"

src_unpack() {
	platform_src_unpack
	CROS_GO_WORKSPACE="${OUT}/gen/go"
}

src_install() {
	insinto /usr/"$(get_libdir)"/pkgconfig
	doins vm_protos.pc

	insinto /usr/include/vm_protos/proto_bindings
	doins "${OUT}"/gen/include/vm_protos/proto_bindings/*.h

	dolib.a "${OUT}"/*.a

	cros-go_src_install
}
