# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="e3b189c49b040d42c9e4e3ae359d77bb90f99956"
CROS_WORKON_TREE="ea9c913c52aca6e1f575d626e5352c2830b89a34"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

inherit cros-workon autotest

DESCRIPTION="autotests for cloud services related functionality"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
# Enable autotest by default.
IUSE="+autotest"

IUSE_TESTS="
	+tests_buffet_BasicDBusAPI
	+tests_buffet_Registration
	+tests_buffet_RestartWhenRegistered
	+tests_buffet_RefreshAccessToken
	+tests_buffet_InvalidCredentials
	+tests_buffet_IntermittentConnectivity
"

IUSE="${IUSE} ${IUSE_TESTS}"
