# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="f0656b661c97281f56d91e24224334b7e4d6ebc4"
CROS_WORKON_TREE="70c263579013d9411ebe71bfe10176617473a0e6"
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

LICENSE="BSD-Google BSD-2 Apache-2.0 MIT"
SLOT="0"
KEYWORDS="*"
IUSE="debug -crosvm-plugin +crosvm-wl-dmabuf"

RDEPEND="chromeos-base/minijail
	!chromeos-base/crosvm-bin
	arm? ( sys-apps/dtc )"
DEPEND="${RDEPEND}"

src_unpack() {
	# Unpack both the project and dependency source code
	cargo_src_unpack
	cros-workon_src_unpack
}

src_compile() {
	export CARGO_HOME="${ECARGO_HOME}"
	export TARGET_CC="$(tc-getCC)"
	export CARGO_TARGET_DIR="${WORKDIR}"

	local features=(
		$(usex crosvm-plugin plugin "")
		$(usex crosvm-wl-dmabuf wl-dmabuf "")
	)

	cargo build -v --target="${CHOST}" \
				$(usex debug "" --release) \
				--features="${features[*]}" \
		|| die "cargo build failed"
}

src_test() {
	export CARGO_HOME="${ECARGO_HOME}"
	export TARGET_CC="$(tc-getCC)"
	export CARGO_TARGET_DIR="${WORKDIR}"

	if ! use x86 && ! use amd64 ; then
		elog "Skipping unit tests on non-x86 platform"
	else
		# Exluding tests that need memfd_create, /dev/kvm, or /dev/dri access
		# because the bots don't support these.
		cargo test --all \
			--exclude kvm \
			--exclude kvm_sys \
			--exclude net_util -v \
			--exclude qcow \
			--exclude aarch64 \
			--exclude gpu_buffer \
			--target="${CHOST}" -- --test-threads=1 \
			|| die "cargo test failed"
		# Plugin tests all require /dev/kvm, but we want to make sure they build
		# at least.
		cargo test --no-run --features plugin --target="${CHOST}" \
			|| die "cargo build with plugin feature failed"
	fi
}

src_install() {
	local seccomp_arch="unknown"
	case ${ARCH} in
		amd64) seccomp_arch=x86_64;;
		arm) seccomp_arch=aarch64;;
	esac

	# cargo doesn't know how to install cross-compiled binaries.  It will
	# always install native binaries for the host system.  Manually install
	# crosvm instead.
	local build_dir="${WORKDIR}/${CHOST}/$(usex debug debug release)"
	dobin "${build_dir}/crosvm"

	# Install seccomp policy files.
	local seccomp_path="${S}/seccomp/${seccomp_arch}"
	if [[ -d "${seccomp_path}" ]] ; then
		insinto /usr/share/policy/crosvm
		doins "${seccomp_path}"/*.policy
	fi

	# Install qcow utils library, header, and pkgconfig files.
	dolib.so "${build_dir}/libqcow_utils.so"

	local include_dir="/usr/include/crosvm"

	"${S}"/qcow_utils/platform2_preinstall.sh "${PV}" "${include_dir}" \
		"${WORKDIR}"
	insinto "/usr/$(get_libdir)/pkgconfig"
	doins "${WORKDIR}/libqcow_utils.pc"

	insinto "${include_dir}"
	doins "${S}"/qcow_utils/src/qcow_utils.h

	# Install plugin library, when requested.
	if use crosvm-plugin ; then
		insinto "${include_dir}"
		doins "${S}/crosvm_plugin/crosvm.h"
		dolib.so "${build_dir}/libcrosvm_plugin.so"
	fi
}

pkg_preinst() {
	enewuser "crosvm"
	enewgroup "crosvm"
}
