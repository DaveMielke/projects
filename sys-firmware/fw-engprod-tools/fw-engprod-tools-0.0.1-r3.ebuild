# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
CROS_WORKON_COMMIT="ded1bacce0c33a3b800f8b7a32fe7642128985dc"
CROS_WORKON_TREE="ea9b940401e193bc7aec76c5f95b85c8e1126899"
CROS_WORKON_PROJECT="chromiumos/platform/crostestutils"
CROS_WORKON_LOCALNAME="../platform/crostestutils"

CROS_GO_WORKSPACE="${S}/go"
CROS_GO_BINARIES=(
	"firmware/e2e_coverage_summarizer/:/usr/local/bin/fw_e2e_coverage_summarizer"
	"firmware/lab_triage_helper/:/usr/local/bin/fw_lab_triage_helper"
)

inherit cros-go cros-workon

DESCRIPTION="Tooling related to firmware release testing."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform/crostestutils/+/refs/heads/master/go/src/firmware/"

LICENSE="BSD-Google"
SLOT="0/0"
KEYWORDS="*"
IUSE=""

DEPEND="dev-go/crypto:="
RDEPEND=""
