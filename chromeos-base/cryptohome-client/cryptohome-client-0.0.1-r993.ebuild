# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="acc60fa54754e0c5158dd0f1de3f3991e7c519eb"
CROS_WORKON_TREE=("aa81756947ecfdd38b22f42eed8eeafa40431079" "006895e927c2f0b39daf370033a81faa311e64c7" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk cryptohome .gn"

PLATFORM_SUBDIR="cryptohome/client"

inherit cros-workon platform

DESCRIPTION="Cryptohome D-Bus client library for Chromium OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/cryptohome"

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="cros_host"

# D-Bus proxies generated by this client library depend on the code generator
# itself (chromeos-dbus-bindings) and produce header files that rely on
# libbrillo library, hence both dependencies.
BDEPEND="
	chromeos-base/chromeos-dbus-bindings
"

RDEPEND="
	!<chromeos-base/cryptohome-0.0.1
"

src_install() {
	# Install D-Bus client library.
	platform_install_dbus_client_lib "cryptohome"
}