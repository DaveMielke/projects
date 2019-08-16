# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="8b8663ab62ba12e477d6008fe7be827df3940d70"
CROS_WORKON_TREE=("be9deee33ea6aedd9dfe69b33c12accd5733a331" "1a72e179f47fd65d4185a31f050e1244119a7a71" "dc1506ef7c8cfd2c5ffd1809dac05596ec18773c")
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
# TODO(amoylan): Set CROS_WORKON_OUTOFTREE_BUILD=1 after crbug.com/833675.
CROS_WORKON_DESTDIR="${S}/platform2"
CROS_WORKON_SUBTREE="common-mk ml .gn"

PLATFORM_SUBDIR="ml"

inherit cros-workon platform user

DESCRIPTION="Machine learning service for Chromium OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/ml"

# Clients of the ML service should place the URIs of their model files into
# this variable.
models="gs://chromeos-localmirror/distfiles/mlservice-model-test_add-20180914.tflite
	gs://chromeos-localmirror/distfiles/mlservice-model-smart_dim-20181115.tflite
	gs://chromeos-localmirror/distfiles/mlservice-model-smart_dim-20190221.tflite
	gs://chromeos-localmirror/distfiles/mlservice-model-smart_dim-20190521.tflite
	gs://chromeos-localmirror/distfiles/mlservice-model-top_cat-20190722.tflite"

SRC_URI="${models}"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	chromeos-base/libbrillo
	chromeos-base/metrics
	sci-libs/tensorflow
"

DEPEND="
	${RDEPEND}
	chromeos-base/system_api
"

src_install() {
	dobin "${OUT}"/ml_service

	# Install upstart configuration.
	insinto /etc/init
	doins init/*.conf

	# Install seccomp policy file.
	insinto /usr/share/policy
	newins "seccomp/ml_service-seccomp-${ARCH}.policy" ml_service-seccomp.policy

	# Install D-Bus configuration file.
	insinto /etc/dbus-1/system.d
	doins dbus/org.chromium.MachineLearning.conf

	# Install D-Bus service activation configuration.
	insinto /usr/share/dbus-1/system-services
	doins dbus/org.chromium.MachineLearning.service

	# Install system ML models (but not test models).
	insinto /opt/google/chrome/ml_models
	local distfile_uri
	for distfile_uri in ${models}; do
		doins "${DISTDIR}/${distfile_uri##*/}"
	done
}

pkg_preinst() {
	enewuser "ml-service"
	enewgroup "ml-service"
}

platform_pkg_test() {
	# Recreate model dir in the temp directory (for use in unit tests).
	mkdir "${T}/ml_models" || die
	local distfile_uri
	for distfile_uri in ${models}; do
		cp "${DISTDIR}/${distfile_uri##*/}" "${T}/ml_models" || die
	done

	platform_test "run" "${OUT}/ml_service_test"
}
