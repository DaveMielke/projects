# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

CROS_GO_SOURCE="github.com/opencontainers/selinux b6fa367ed7f534f9ba25391cc2d467085dbb445a"

CROS_GO_PACKAGES=(
	"github.com/opencontainers/selinux/go-selinux"
)

CROS_GO_TEST=(
	"${CROS_GO_PACKAGES[@]}"
)

inherit cros-go

DESCRIPTION="common selinux implementation"
HOMEPAGE="https://github.com/opencontainers/selinux"
SRC_URI="$(cros-go_src_uri)"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND="
	dev-go/errors
"
RDEPEND=""
