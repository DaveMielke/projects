# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

CROS_WORKON_COMMIT="25ce3550a14c5075b1438527a8ae161bdcba1edd"
CROS_WORKON_TREE=("7df66f898dfe1a70a7d79878e16378ce37cf6996" "a9fdbeb015e0ad5740bd03e2c783dc1cd4fe84a4" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk attestation .gn"

PLATFORM_SUBDIR="attestation/client"

inherit cros-workon platform

DESCRIPTION="Attestation D-Bus client library for Chromium OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/attestation/client/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="cros_host"

# D-Bus proxies generated by this client library depend on the code generator
# itself (chromeos-dbus-bindings) and produce header files that rely on
# libbrillo library, hence both dependencies. We require the particular
# revision because libbrillo-0.0.1-r1 changed location of header files from
# chromeos/ to brillo/ and chromeos-dbus-bindings-0.0.1-r1058 generates the
# code using the new location.
DEPEND="
	cros_host? ( >=chromeos-base/chromeos-dbus-bindings-0.0.1-r1058 )
	chromeos-base/libbrillo:=
"

# Note that for RDEPEND, we conflict with attestation package older than
# 0.0.1 because this client is incompatible with daemon older than version
# 0.0.1. We didn't RDEPEND on attestation version 0.0.1 or greater because
# we don't want to create circular dependency in case the package attestation
# depends on some package foo that also depend on this package.
RDEPEND="
	!<chromeos-base/attestation-0.0.1
	chromeos-base/libbrillo:=
"

src_install() {
	# Install D-Bus client library.
	platform_install_dbus_client_lib "attestation"
}