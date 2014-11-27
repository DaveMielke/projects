# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# This project checks out the proto files from the read only repositories
# linked to the following directories of the Chromium project:

#   - src/components/policy/proto
#   - src/chrome/browser/chromeos/policy/proto

# This project is not cros-work-able: if changes to the protobufs are needed
# then they should be done in the Chromium repository, and the commits below
# should be updated.

EAPI="4"

inherit cros-constants git-2

# Every 3 strings in this array indicates a repository to checkout:
#   - A unique name (to avoid checkout conflits)
#   - The repository URL
#   - The commit to checkout
EGIT_REPO_URIS=(
	"cloud"
	"${CROS_GIT_HOST_URL}/chromium/src/components/policy/proto.git"
	"1c29a8465c755c4e63fe818772307ab6f49ec52a"

	"chromeos"
	"${CROS_GIT_HOST_URL}/chromium/src/chrome/browser/chromeos/policy/proto.git"
	"da5ae4f722a91e02737341d2b4f2295298d04675"
)

DESCRIPTION="Protobuf installer for the device policy proto definitions."
HOMEPAGE="http://chromium.org"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

src_unpack() {
	set -- "${EGIT_REPO_URIS[@]}"
	while [[ $# -gt 0 ]]; do
		EGIT_PROJECT=$1 \
		EGIT_SOURCEDIR="${S}/$1" \
		EGIT_REPO_URI=$2 \
		EGIT_COMMIT=$3 \
		git-2_src_unpack
		shift 3
	done
}

src_install() {
	insinto /usr/include/proto
	doins "${S}"/{chromeos,cloud}/*.proto
	insinto /usr/share/protofiles
	doins "${S}"/chromeos/chrome_device_policy.proto
	doins "${S}"/cloud/device_management_backend.proto
	doins "${S}"/cloud/chrome_extension_policy.proto
	dobin "${FILESDIR}"/policy_reader
}
