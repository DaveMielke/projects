# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/perf/perf-2.6.32.ebuild,v 1.1 2009/12/04 16:33:24 flameeyes Exp $

EAPI=4
CROS_WORKON_COMMIT="8754d59563b30ad1a21fbeda4d09595fae5ae660"
CROS_WORKON_TREE="db71eac3e4447d05dab810ccbddac065470cd172"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel-next"
CROS_WORKON_LOCALNAME="kernel-next"
CROS_WORKON_BLACKLIST=1

inherit cros-workon cros-perf

KEYWORDS="*"
RDEPEND="!dev-util/perf"
DEPEND="${RDEPEND}
	${DEPEND}"


