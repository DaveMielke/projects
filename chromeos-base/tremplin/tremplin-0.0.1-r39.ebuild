# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=6
CROS_WORKON_COMMIT="2b744c78dda18c86543d8b6ea5c9e36cde432eb0"
CROS_WORKON_TREE="b9a57a6669a78b776037361425aa6880c0d9e059"
CROS_WORKON_PROJECT="chromiumos/platform/tremplin"
CROS_WORKON_LOCALNAME="tremplin"
CROS_GO_BINARIES="chromiumos/tremplin"

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
	dev-go/grpc
	dev-go/vsock
"

RDEPEND="app-emulation/lxd"
