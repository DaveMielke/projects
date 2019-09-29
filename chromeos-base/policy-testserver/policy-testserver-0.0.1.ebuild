# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 )
inherit cros-constants git-r3 python-any-r1

# Every 3 strings in this array indicates a repository to checkout:
#   - A unique name (to avoid checkout conflits)
#   - The repository URL
#   - The commit to checkout
EGIT_REPO_URIS=(
	"third_party/tlslite"
	"${CROS_GIT_HOST_URL}/chromium/src/third_party/tlslite.git"
	"0e00634c2052d16038e3905fd544d0f6cc3ec566"

	"net/tools/testserver"
	"${CROS_GIT_HOST_URL}/chromium/src/net/tools/testserver.git"
	"81f46b9acb3ed3d82fecd6a233935d7f30f63ff5"

	"components/policy"
	"${CROS_GIT_HOST_URL}/chromium/src/components/policy.git"
	"b9db1257486074c59d57ec8d064e38cdac0fc103"
)

DESCRIPTION="Dependencies needed by the policy_testserver"
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

POLICY_DIR="${S}/components/policy"

# Destination on DUT is /usr/local/share/policy_testserver.
TESTSERVER_DIR="/usr/share/policy_testserver"

DEPEND="
	dev-libs/protobuf
"

RDEPEND="
	dev-python/protobuf-python
"


src_unpack() {
	# Unpack all chromium mirrored code.
	set -- "${EGIT_REPO_URIS[@]}"
	while [[ $# -gt 0 ]]; do
		EGIT_CHECKOUT_DIR="${S}/$1" \
			EGIT_REPO_URI=$2 \
			EGIT_COMMIT=$3 \
			git-r3_src_unpack
		shift 3
	done
}

src_compile() {
	# Generate cloud_policy.proto with --all-chrome-versions option.
	"${POLICY_DIR}/tools/generate_policy_source.py" \
		--cloud-policy-protobuf="${WORKDIR}/cloud_policy.proto" \
		--all-chrome-versions \
		--target-platform="chrome_os" \
		--policy-templates-file="${POLICY_DIR}/resources/policy_templates.json" \
		|| die

	# Create Python bindings needed for policy_testserver.py.
	protoc --proto_path="${POLICY_DIR}/proto" --python_out="${WORKDIR}" \
		"${POLICY_DIR}/proto/chrome_device_policy.proto" \
		"${POLICY_DIR}/proto/device_management_backend.proto" \
		"${POLICY_DIR}/proto/chrome_extension_policy.proto" \
		|| die
	protoc --proto_path="${WORKDIR}" --python_out="${WORKDIR}" "${WORKDIR}/cloud_policy.proto" || die
}

src_install() {
	insinto "${TESTSERVER_DIR}"
	doins -r "${S}"/third_party/tlslite
	doins -r "${S}"/net/tools/testserver
	doins -r "${S}"/components/policy/test_support/asn1der.py
	doins -r "${S}"/components/policy/test_support/policy_testserver.py

	insinto "${TESTSERVER_DIR}/proto_bindings"
	doins "${WORKDIR}/chrome_device_policy_pb2.py"
	doins "${WORKDIR}/device_management_backend_pb2.py"
	doins "${WORKDIR}/chrome_extension_policy_pb2.py"
	doins "${WORKDIR}/cloud_policy_pb2.py"
}
