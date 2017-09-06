# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

# Disable cros-workon auto-uprev since this is an external package.
# Must manage commit hash manually.
CROS_WORKON_BLACKLIST="1"
CROS_WORKON_COMMIT="66aacef3dd8a676686c7ae3716979581e8b03c47"
CROS_WORKON_REPO="https://go.googlesource.com"
CROS_WORKON_PROJECT="net"
CROS_WORKON_DESTDIR="${S}/src/golang.org/x/net"

CROS_GO_PACKAGES=(
	"golang.org/x/net/bpf"
	"golang.org/x/net/context"
	"golang.org/x/net/internal/iana"
	"golang.org/x/net/internal/socket"
	"golang.org/x/net/ipv4"
)

CROS_GO_TEST=(
	"${CROS_GO_PACKAGES[@]}"
)

inherit cros-workon cros-go

DESCRIPTION="Go supplementary network libraries"
HOMEPAGE="https://golang.org/x/net"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND=""
RDEPEND=""
