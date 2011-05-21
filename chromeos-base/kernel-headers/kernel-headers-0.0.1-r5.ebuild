# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

EGIT_REPO_URI="http://git.chromium.org/chromiumos/third_party/kernel.git"
EGIT_COMMIT="d4e4d17a56d83874d66b4ca3efeaaa4c0d97c338"

inherit git

DESCRIPTION="Chrome OS Kernel Headers"
HOMEPAGE="http://src.chromium.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

src_unpack() {
	path="${CROS_WORKON_SRCROOT}/src/third_party/kernel/files"
	if [ -d "${path}/.git" ]; then
		git clone -sn "${path}" "${S}" || die "Can't clone ${path}."
		if ! ( cd "${S}" && git checkout ${EGIT_COMMIT} ) ; then
			ewarn "Cannot run git checkout ${EGIT_COMMIT} in ${S}."
			ewarn "Is ${path} up to date? Try running repo sync."
			die "Cannot run git checkout ${EGIT_COMMIT} in ${S}."
		fi
	else
		git_src_unpack
	fi
}

src_compile() {
	elog " Nothing to compile"
}

src_install() {
	emake \
	  ARCH=$(tc-arch-kernel) \
	  CROSS_COMPILE="${CHOST}-" \
	  INSTALL_HDR_PATH="${D}"/usr \
	  headers_install || die

	#
	# These subdirectories are installed by various ebuilds and we don't
	# want to conflict with them.
	#
	rm -rf "${D}"/usr/include/sound
	rm -rf "${D}"/usr/include/scsi
	rm -rf "${D}"/usr/include/drm

}
