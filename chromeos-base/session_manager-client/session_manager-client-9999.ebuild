# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk login_manager .gn"

PLATFORM_NATIVE_TEST="yes"
PLATFORM_SUBDIR="login_manager/session_manager-client"

inherit cros-workon platform

DESCRIPTION="Session manager (chromeos-login) DBus client library for Chromium OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/login_manager/"

LICENSE="BSD-Google"
KEYWORDS="~*"
IUSE="cros_host"

# D-Bus proxies generated by this client library depend on the code generator
# itself (chromeos-dbus-bindings) and produce header files that rely on
# libbrillo library, hence both dependencies.
DEPEND="
	cros_host? ( chromeos-base/chromeos-dbus-bindings:= )
"

RDEPEND="
	!<chromeos-base/chromeos-login-0.0.2
"

src_install() {
	# Install DBus client library.
	platform_install_dbus_client_lib "session_manager"
}
