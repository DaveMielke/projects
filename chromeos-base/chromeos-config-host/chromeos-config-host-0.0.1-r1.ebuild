# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="7c36db3c0fb7baddbe197ce3a8864d0cc0a2d104"
CROS_WORKON_TREE="b448e17ebd13a3e118929fc8946ea4d4d5726259"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"

PLATFORM_SUBDIR="chromeos-config"

PYTHON_COMPAT=( python2_7 )

inherit cros-workon platform distutils-r1

DESCRIPTION="Chrome OS configuration host tools"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/chromeos-config"

LICENSE="BSD-Google"
SLOT=0
KEYWORDS="*"

RDEPEND="
	sys-apps/dtc[python]
	!<chromeos-base/chromeos-config-tools-0.0.2
"

DEPEND="
	${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

src_prepare() {
	cros-workon_src_prepare
	distutils-r1_src_prepare
}

src_compile() {
	einfo "Validating master configuration binding"
	python validate_config.py README.md || die "Validation failed"
	# TODO(lannm): distutils-r1_src_compile after fixing setup.py
}

src_test() {
	./chromeos-config-test-setup.sh
	./run_tests.sh || die "cros_config unit tests have errors"
}

src_install() {
	# TODO(lannm): Replace with distutils-r1_src_install after fixing
	# setup.py
	for fname in cros_config_host.py validate_config.py \
		validate_schema.py \
		libcros_config_host/*.py; do
		exeinto "$(dirname /usr/lib/python2.7/site-packages/${fname})"
		einfo "install ${fname}"
		doexe "${fname}"
	done
	exeinto /usr/bin
	doexe cros_config_host_py
	doexe validate_config
}
