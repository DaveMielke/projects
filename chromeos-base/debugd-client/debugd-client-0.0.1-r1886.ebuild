# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="bfc5c4267048c9f1e9b288901302bab945a10734"
CROS_WORKON_TREE=("85e4e098023fcccb8851b45c351a7045fa23f06f" "bb396b871d2742030adc65411b819bdea2fd0893" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk debugd .gn"

PLATFORM_NATIVE_TEST="yes"
PLATFORM_SUBDIR="debugd/client"

inherit cros-workon platform

DESCRIPTION="Chrome OS debugd client library"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/debugd/"
SRC_URI=""

LICENSE="BSD-Google"
KEYWORDS="*"
IUSE="cros_host"

# D-Bus proxies generated by this client library depend on the code generator
# itself (chromeos-dbus-bindings) and produce header files that rely on
# libbrillo library, hence both dependencies. We require the particular
# revision because libbrillo-0.0.1-r1 changed location of header files from
# chromeos/ to brillo/ and chromeos-dbus-bindings-0.0.1-r1058 generates the
# code using the new location.
BDEPEND="
	chromeos-base/chromeos-dbus-bindings
"

src_install() {
  # Install DBus client library.
  platform_install_dbus_client_lib "debugd"
}