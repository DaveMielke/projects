# Copyright (c) 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

DESCRIPTION="Install packages that must live in the rootfs in dev images."
HOMEPAGE="http://www.chromium.org/"
KEYWORDS="*"
LICENSE="BSD-Google"
SLOT="0"
IUSE="brillo-debug"

RDEPEND="
	brillo-debug? ( brillo-base/brdebug-init )
	chromeos-base/openssh-server-init
	virtual/chromeos-bsp-dev-root
"
