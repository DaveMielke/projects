# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="db9eb2fb535c8928aa9aae50e4ded6b6f2d5f2f0"
CROS_WORKON_TREE=("4d75f59d5b9cba741b59b0d28a456d711d58800c" "c3bbc1ba00d7b0e7aac3ebd77ace6bba081107c4" "2834854981f88e2b81fefd49c590185a31f2b1f1" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
CROS_GO_PACKAGES=(
	"chromiumos/hardware_verifier/..."
)

CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk hardware_verifier metrics .gn"

PLATFORM_SUBDIR="hardware_verifier/proto"

inherit cros-workon cros-go platform

DESCRIPTION="Hardware Verifier go proto for Chrome OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/hardware_verifier/proto"

LICENSE="BSD-Google"
KEYWORDS="*"

DEPEND="
	chromeos-base/metrics:=
	chromeos-base/system_api:=
	chromeos-base/vboot_reference:=
	dev-go/protobuf
"

src_unpack() {
	platform_src_unpack
	CROS_GO_WORKSPACE="${OUT}/gen/go"
}

src_install() {
	cros-go_src_install
}