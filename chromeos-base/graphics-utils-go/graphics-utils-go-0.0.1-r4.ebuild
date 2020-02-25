# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_COMMIT="bb551954b1b776f6eb56c21c35e57b56acbe3599"
CROS_WORKON_TREE="cb68f30ff3203f27aaf0dff941d40fe73289ae62"
CROS_WORKON_PROJECT="chromiumos/platform/graphics"
CROS_WORKON_LOCALNAME="platform/graphics"

INSTALL_DIR="/usr/local/graphics"

CROS_GO_BINARIES=(
	# Add more apps here.
	"sanity/cmd/pass:${INSTALL_DIR}/pass"
	"trace_replay/cmd/trace_replay:${INSTALL_DIR}/trace_replay"
)

CROS_GO_TEST=(
	"sanity/cmd/pass"
	"trace_replay/cmd/trace_replay"
)

CROS_GO_VET=(
	"${CROS_GO_TEST[@]}"
)

inherit cros-go cros-workon

DESCRIPTION="Portable graphics utils written in go"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/graphics/"

LICENSE="BSD-Google"
SLOT="0/0"
KEYWORDS="*"
IUSE=""

DEPEND=""

RDEPEND=""

src_prepare() {
	# Disable cgo and PIE on building Tast binaries. See:
	# https://crbug.com/976196
	# https://github.com/golang/go/issues/30986#issuecomment-475626018
	export CGO_ENABLED=0
	export GOPIE=0

	cros-workon_src_prepare
	default
}
