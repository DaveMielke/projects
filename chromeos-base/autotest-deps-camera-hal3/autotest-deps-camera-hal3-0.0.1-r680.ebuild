# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="2426ff503c573d888ca497dc146fccd1c6493f5f"
CROS_WORKON_TREE="1fb6e093c6806bc699020ca081d376b077bf5233"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

inherit cros-workon autotest-deponly

DESCRIPTION="Dependencies for camera_HAL3 autotest"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

# Autotest enabled by default.
IUSE="+autotest"

AUTOTEST_DEPS_LIST="camera_hal3"

RDEPEND="
	media-libs/arc-camera3-test
"

DEPEND="${RDEPEND}"
