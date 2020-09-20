# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT="f00c5a0cee8e3f1bdedfeeaa3e0c064de10b407e"
CROS_WORKON_TREE=("825512278f3738ba8ac7c5f167aacd4677cfebf7" "4b27db8e108d404fc4df5538486808ca57c1d452" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb")
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