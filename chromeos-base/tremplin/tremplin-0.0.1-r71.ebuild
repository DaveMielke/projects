# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=6
CROS_WORKON_COMMIT="15a97c380f613d1b9b1b70f35cf334ccc7610cd2"
CROS_WORKON_TREE="6c6b48260f6dcd656015478a3643cd7741e74d62"
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
