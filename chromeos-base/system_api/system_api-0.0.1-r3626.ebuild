# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="e20a6dfcd3364f0753f30504463341100780463c"
CROS_WORKON_TREE=("11f584bb7dd3244e1eec145f7e377b32b68e8b3b" "a55f6515d7af96e0b69d9c67cb53ad036e8b85aa" "dc1506ef7c8cfd2c5ffd1809dac05596ec18773c")
CROS_GO_PACKAGES=(
	"chromiumos/system_api/..."
)

CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk system_api .gn"

PLATFORM_SUBDIR="system_api"

inherit cros-go cros-workon toolchain-funcs platform

DESCRIPTION="Chrome OS system API (D-Bus service names, etc.)"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
# The subslot should be manually bumped any time protobuf is upgraded
# to a newer version whose libraries are incompatible with the
# generated sources of the previous version. As a rule of thumb if the
# minor version of protobuf has changed, the subslot should be incremented.
SLOT="0/1"
KEYWORDS="*"
IUSE="cros_host"

RDEPEND=""

DEPEND="${RDEPEND}
	dev-go/protobuf
	dev-libs/protobuf:=
	cros_host? ( net-libs/grpc:= )
"

src_unpack() {
	platform_src_unpack
	CROS_GO_WORKSPACE="${OUT}/gen/go"
}

src_install() {
	insinto /usr/"$(get_libdir)"/pkgconfig
	doins system_api.pc

	insinto /usr/include/chromeos
	doins -r dbus switches constants
	find "${D}" -name OWNERS -delete || die

	# Install the dbus-constants.h files in the respective daemons' client library
	# include directory. Users will need to include the corresponding client
	# library to access these files.
	local dir dirs=(
		attestation
		biod
		cros-disks
		cros_healthd
		cryptohome
		debugd
		dlcservice
		login_manager
		lorgnette
		oobe_config
		runtime_probe
		permission_broker
		power_manager
		shill
		smbprovider
		tpm_manager
		update_engine
		wilco_dtc_supportd
	)
	for dir in "${dirs[@]}"; do
		insinto /usr/include/"${dir}"-client/"${dir}"
		doins dbus/"${dir}"/dbus-constants.h
	done

	# These are files/projects installed in the common dir.
	dirs=( system_api )

	# These are project-specific files.
	dirs+=( $(
		cd "${S}/dbus" || die
		dirname */*.proto | sort -u
	) )

	for dir in "${dirs[@]}"; do
		insinto /usr/include/"${dir}"/proto_bindings
		doins "${OUT}"/gen/include/"${dir}"/proto_bindings/*.h

		if [[ "${dir}" == "system_api" ]]; then
			dolib.a "${OUT}/libsystem_api-protos.a"
		else
			dolib.a "${OUT}/libsystem_api-${dir}-protos.a"
		fi
	done

	cros-go_src_install
}
