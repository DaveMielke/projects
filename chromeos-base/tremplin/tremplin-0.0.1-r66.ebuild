# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=6
CROS_WORKON_COMMIT="a7c4d7adf874a2969774d249044d7ffefdf02256"
CROS_WORKON_TREE="6e79f09e8e02c6f67439d89d883b9e00ae119f92"
CROS_WORKON_PROJECT="chromiumos/platform/tremplin"
CROS_WORKON_LOCALNAME="tremplin"
CROS_GO_BINARIES="chromiumos/tremplin"

CROS_GO_TEST=(
	"chromiumos/tremplin/..."
)
CROS_GO_VET=(
	"${CROS_GO_TEST[@]}"
)

inherit cros-workon cros-go

DESCRIPTION="Tremplin LXD client with gRPC support"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/tremplin/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="
	app-emulation/lxd
	chromeos-base/vm_guest_tools
	chromeos-base/vm_protos
	dev-go/go-libaudit
	dev-go/go-sys
	dev-go/grpc
	dev-go/kobject
	dev-go/netlink
	dev-go/vsock
	dev-go/yaml
"

RDEPEND="app-emulation/lxd"
