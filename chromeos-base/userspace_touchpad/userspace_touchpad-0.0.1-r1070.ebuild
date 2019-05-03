# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
CROS_WORKON_COMMIT="824a54b8fee4c536600a76e7729fbb086fb625f4"
CROS_WORKON_TREE=("6a8fe02405fcf0d44f17e743ef41280961e8b8c8" "079ca71c260a3eff20671fbaf52c7fd472f24097" "dc1506ef7c8cfd2c5ffd1809dac05596ec18773c")
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_DESTDIR="${S}"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk userspace_touchpad .gn"

PLATFORM_SUBDIR="userspace_touchpad"

inherit cros-workon platform

DESCRIPTION="Userspace Touchpad"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
IUSE=""
KEYWORDS="*"

src_install() {
	dobin "${OUT}/userspace_touchpad"

	insinto "/etc/init"
	doins "userspace_touchpad.conf"
}
