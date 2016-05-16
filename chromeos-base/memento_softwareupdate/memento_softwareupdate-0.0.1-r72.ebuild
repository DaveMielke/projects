# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="3c7204287bbc8f4341f546857216389bdff58e51"
CROS_WORKON_TREE="b3216111ee71ade005eba128079979f4dc3301d3"
CROS_WORKON_PROJECT="chromiumos/platform/memento_softwareupdate"

inherit cros-workon toolchain-funcs

DESCRIPTION="Chrome OS Memento Updater"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang"
REQUIRED_USE="asan? ( clang )"

DEPEND="dev-cpp/gtest"
RDEPEND="app-arch/gzip
	app-shells/bash
	dev-libs/openssl
	dev-util/shflags
	dev-util/xxd
	net-misc/wget
	sys-apps/coreutils
	sys-apps/util-linux"

src_configure() {
	clang-setup-env
	cros-workon_src_configure
}

src_compile() {
	tc-export AR CC CXX RANLIB AS
	emake WARNERROR=no || die
}

src_install() {
	exeinto /opt/google/memento_updater
	# Install shell scripts.
	doexe \
		find_omaha.sh \
		memento_updater.sh \
		memento_updater_logging.sh \
		ping_omaha.sh \
		software_update.sh
	# Install binary programs from src folder.
	doexe \
		src/split_write \
		src/memento_updater

	# Install factory cutoff scripts

	exeinto /usr/local/factory/sh
	doexe battery_cutoff/*.sh
}
