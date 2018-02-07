# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="3994c3964e117da41bfe263d6e0be0babc861572"
CROS_WORKON_TREE="b71a2cbdd9a03a1bb15a6b6b93cb42b07697b4e0"
CROS_WORKON_PROJECT="chromiumos/platform/crosvm"
CROS_WORKON_LOCALNAME="../platform/crosvm"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_OUTOFTREE_BUILD=1

CRATES="
bitflags-1.0.1
byteorder-1.1.0
cfg-if-0.1.2
fuchsia-zircon-0.3.3
fuchsia-zircon-sys-0.3.3
gcc-0.3.54
libc-0.2.34
log-0.4.1
protobuf-1.4.3
protoc-1.4.3
protoc-rust-1.4.3
rand-0.3.20
rand-0.4.2
tempdir-0.3.5
winapi-0.3.4
winapi-i686-pc-windows-gnu-0.4.0
winapi-x86_64-pc-windows-gnu-0.4.0
"

inherit cargo cros-workon toolchain-funcs user

DESCRIPTION="Utility for running Linux VMs on Chrome OS"

SRC_URI="$(cargo_crate_uris ${CRATES})"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="debug"

RDEPEND="chromeos-base/minijail
	!chromeos-base/crosvm-bin"
DEPEND="${RDEPEND}"

src_unpack() {
	# Unpack both the project and dependency source code
	cargo_src_unpack
	cros-workon_src_unpack
}

src_test() {
	export CARGO_HOME="${ECARGO_HOME}"
	export TARGET_CC="$(tc-getCC)"
	export CARGO_TARGET_DIR="${WORKDIR}"

	if ! use x86 && ! use amd64 ; then
		elog "Skipping unit tests on non-x86 platform"
	else
		# Exluding tests that need memfd_create or need /dev/kvm access
		# because the bots don't support either.
		cargo test --all \
			--exclude kvm \
			--exclude kvm_sys \
			--exclude net_util -v \
			--exclude qcow \
			--target="${CHOST}" -- --test-threads=1 \
			|| die "cargo test failed"
	fi
}

src_install() {
	local seccomp_arch="unknown"
	case ${ARCH} in
		amd64) seccomp_arch=x86_64;;
	esac

	# cargo doesn't know how to install cross-compiled binaries.  It will
	# always install native binaries for the host system.  Manually install
	# crosvm instead.
	dobin "${WORKDIR}/${CHOST}/$(usex debug debug release)/crosvm"

	# Install seccomp policy files.
	local seccomp_path="${S}/seccomp/${seccomp_arch}"
	if [[ -d "${seccomp_path}" ]] ; then
		insinto /usr/share/policy/crosvm
		doins "${seccomp_path}"/*.policy
	fi

	# Install qcow utils library, header, and pkgconfig files.
	dolib.so "${WORKDIR}/${CHOST}/$(usex debug debug release)/libqcow_utils.so"

	local include_dir="/usr/include/crosvm"

	"${S}"/qcow_utils/platform2_preinstall.sh "${PV}" "${include_dir}" \
		"${WORKDIR}"
	insinto "/usr/$(get_libdir)/pkgconfig"
	doins "${WORKDIR}/libqcow_utils.pc"

	insinto "${include_dir}"
	doins "${S}"/qcow_utils/src/qcow_utils.h
}

pkg_preinst() {
	enewuser "crosvm"
	enewgroup "crosvm"
}
