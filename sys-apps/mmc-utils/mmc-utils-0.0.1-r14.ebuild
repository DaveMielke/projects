# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="fec7678f5d3f9784ae1b835e4a01be13524660f0"
CROS_WORKON_TREE="cff64887780048aed16f674cf9b8f4637a068b43"
CROS_WORKON_PROJECT="chromiumos/third_party/mmc-utils"

inherit cros-constants cros-workon toolchain-funcs

# original Announcement of project:
#	http://permalink.gmane.org/gmane.linux.kernel.mmc/12766
#
# Upstream GIT:
#   https://git.kernel.org/cgit/linux/kernel/git/cjb/mmc-utils.git/
#
# To grab a local copy of the mmc-utils source tree:
#   git clone git://git.kernel.org/pub/scm/linux/kernel/git/cjb/mmc-utils.git
#
# or to reference upstream in local mmc-utils tree:
#   git remote add upstream git://git.kernel.org/pub/scm/linux/kernel/git/cjb/mmc-utils.git
#   git remote update

DESCRIPTION="Userspace tools for MMC/SD devices"
HOMEPAGE="${CROS_GIT_HOST_URL}/${CROS_WORKON_PROJECT}"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="static"

src_configure() {
	use static && append-ldflags -static
	cros-workon_src_configure
	tc-export CC
	export prefix=/usr
}
