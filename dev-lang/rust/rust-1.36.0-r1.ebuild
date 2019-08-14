# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

PYTHON_COMPAT=( python2_7 )
inherit python-any-r1 versionator toolchain-funcs

if [[ ${PV} = *beta* ]]; then
	betaver=${PV//*beta}
	BETA_SNAPSHOT="${betaver:0:4}-${betaver:4:2}-${betaver:6:2}"
	MY_P="rustc-beta"
	SLOT="beta/${PV}"
	SRC="${BETA_SNAPSHOT}/rustc-beta-src.tar.gz"
	KEYWORDS=""
else
	ABI_VER="$(get_version_component_range 1-2)"
	SLOT="stable/${ABI_VER}"
	MY_P="rustc-${PV}"
	SRC="${MY_P}-src.tar.gz"
	KEYWORDS="*"
fi


STAGE0_VERSION="1.$(($(get_version_component_range 2) - 1)).0"
STAGE0_VERSION_CARGO="0.$(($(get_version_component_range 2))).0"
STAGE0_DATE="2019-05-23"
RUST_STAGE0_amd64="rustc-${STAGE0_VERSION}-x86_64-unknown-linux-gnu"

DESCRIPTION="Systems programming language from Mozilla"
HOMEPAGE="http://www.rust-lang.org/"

SRC_URI="https://static.rust-lang.org/dist/${SRC} -> rustc-${PV}-src.tar.gz
	https://static.rust-lang.org/dist/${STAGE0_DATE}/rust-std-${STAGE0_VERSION}-x86_64-unknown-linux-gnu.tar.gz
	https://static.rust-lang.org/dist/${RUST_STAGE0_amd64}.tar.gz
	https://static.rust-lang.org/dist/cargo-${STAGE0_VERSION_CARGO}-x86_64-unknown-linux-gnu.tar.gz
	https://github.com/rust-lang/llvm-project/archive/2c5656ae593851d0b2336a727cc14b77a06b8ac0.zip -> rustc-llvm-project-${PV}.zip
"

LICENSE="|| ( MIT Apache-2.0 ) BSD-1 BSD-2 BSD-4 UoI-NCSA"

RESTRICT="binchecks strip"
REQUIRED_USE="amd64"

DEPEND="${PYTHON_DEPS}
	>=dev-libs/libxml2-2.9.6
	>=dev-lang/perl-5.0
"

PATCHES=(
	"${FILESDIR}/${P}-add-cros-targets.patch"
	"${FILESDIR}/${P}-fix-rpath.patch"
	"${FILESDIR}/${P}-enable-sanitizers.patch"
	"${FILESDIR}/${P}-Revert-CMake-Unconditionally-add-.h-and-.td-files-to.patch"
	"${FILESDIR}/${P}-libstd-sanitizer-paths.patch"
	"${FILESDIR}/${P}-sanitizer-lib-boilerplate.patch"
	"${FILESDIR}/${P}-rustbuild-detect-cxx-for-all-targets.patch"
)

S="${WORKDIR}/${MY_P}-src"

# This is the list of target triples as they appear in the cros_sdk. If this list gets changed,
# ensure that each of these values has a corresponding librustc_target/spec file created below
# and a line referring to it in 0001-add-cros-targets.patch.
RUSTC_TARGET_TRIPLES=(
	x86_64-pc-linux-gnu
	x86_64-cros-linux-gnu
	armv7a-cros-linux-gnueabihf
	aarch64-cros-linux-gnu
)

pkg_setup() {
	python-any-r1_pkg_setup
	# Skips the toolchain check if we are installing a binpkg.
	if [[ "${MERGE_TYPE}" != "binary" ]]; then
		local tt
		for tt in "${RUSTC_TARGET_TRIPLES[@]}" ; do
			which "${tt}-clang" >/dev/null || die "missing toolchain ${tt}"
		done
	fi
}

src_prepare() {
	local stagename="RUST_STAGE0_${ARCH}"
	local stage0="${!stagename}"

	cp -r "${WORKDIR}"/rust-std-${STAGE0_VERSION}-x86_64-unknown-linux-gnu/rust-std-x86_64-unknown-linux-gnu/lib/rustlib/x86_64-unknown-linux-gnu \
		"${WORKDIR}"/${stage0}/rustc/lib/rustlib || die

	# Copy "unknown" vendor targets to create cros_sdk target triple
	# variants as referred to in 0001-add-cros-targets.patch and RUSTC_TARGET_TRIPLES.
	# armv7a is treated specially because the cros toolchain differs in
	# more than just the vendor part of the target triple. The arch is
	# armv7a in cros versus armv7.
	pushd src/librustc_target/spec || die
	sed -e 's:"unknown":"pc":g' x86_64_unknown_linux_gnu.rs >x86_64_pc_linux_gnu.rs || die
	sed -e 's:"unknown":"cros":g' x86_64_unknown_linux_gnu.rs >x86_64_cros_linux_gnu.rs || die
	sed -e 's:"unknown":"cros":g' armv7_unknown_linux_gnueabihf.rs >armv7a_cros_linux_gnueabihf.rs || die
	sed -e 's:"unknown":"cros":g' aarch64_unknown_linux_gnu.rs >aarch64_cros_linux_gnu.rs || die
	popd

	# One of the patches changes a vendored library, thereby changing the
	# checksum.
	pushd vendor/compiler_builtins || die
	sed -i 's:66e76e0e8016a6a4e5d5b0a4a08a83051b24699047bda3a54dc18593cfef7801:183ce3f632aaceea80d6544eb631128b98f0d562d7c730061c7e49c1d8cd0f0d:g' \
		.cargo-checksum.json
	popd

	# The miri tool is built because of 'extended = true' in cros-config.toml,
	# but the build is busted. See the upstream issue: [https://github.com/rust-
	# lang/rust/issues/56576]. Because miri isn't installed or needed, this sed
	# script eradicates the command that builds it during the bootstrap script.
	pushd src/bootstrap || die
	sed -i 's@tool::Miri,@@g' builder.rs
	popd

	# Tsk. Tsk. The rust makefile for LLVM's compiler-rt uses -ffreestanding
	# but one of the files includes <stdlib.h> causing occasional problems
	# with MB_LEN_MAX. See crbug.com/730845 for the thrilling details. This
	# line patches over the problematic include. This must go here because
	# src/compiler-rt is a submodule that only gets filled in after
	# ./configure.
	sed -e 's:#include <stdlib.h>:void abort(void);:g' \
		-i "${ECONF_SOURCE:-.}"/vendor/compiler_builtins/compiler-rt/lib/builtins/int_util.c || die

	epatch "${PATCHES[@]}"

	# For the librustc_llvm module, the build will link with -nodefaultlibs and manually choose the
	# std C++ library. For x86_64 Linux, the build script always chooses libstdc++ which will not
	# work if LLVM was built with USE="default-libcxx". This snippet changes that choice to libc++
	# in the case that clang++ defaults to libc++.
	if "${CXX}" -### -x c++ - < /dev/null 2>&1 | grep -q -e '-lc++'; then
		sed -i 's:"stdc++":"c++":g' src/librustc_llvm/build.rs || die
	fi

	# The libunwind code is missing from from the llvm fork shipped with the rustc source tarball
	# for unknown reasons. The ebuild sources the llvm fork directly from github and now we place
	# the libunwind source in the correct spot.
	mv "${WORKDIR}"/llvm-project-*/libunwind \
		src/llvm-project/ || die

	default
}

src_configure() {
	local stagename="RUST_STAGE0_${ARCH}"
	local stage0="${!stagename}"

	local targets=""
	local tt
	for tt in "${RUSTC_TARGET_TRIPLES[@]}" ; do
		targets+="\"${tt}\", "
	done

	local config=cros-config.toml
	cat > "${config}" <<EOF
[build]
target = [${targets}]
cargo = "${WORKDIR}/cargo-${STAGE0_VERSION_CARGO}-x86_64-unknown-linux-gnu/cargo/bin/cargo"
rustc = "${WORKDIR}/${stage0}/rustc/bin/rustc"
docs = false
submodules = false
python = "${EPYTHON}"
vendor = true
extended = true
tools = ["rustfmt", "clippy", "cargofmt"]
sanitizers = true

[llvm]
ninja = true

[install]
prefix = "${ED}usr"
libdir = "$(get_libdir)"
mandir = "share/man"

[rust]
default-linker = "${CBUILD}-clang"
channel = "${SLOT%%/*}"
codegen-units = 0
llvm-libunwind = true

EOF
	for tt in "${RUSTC_TARGET_TRIPLES[@]}" ; do
		cat >> cros-config.toml <<EOF
[target."${tt}"]
cc = "${tt}-clang"
cxx = "${tt}-clang++"
linker = "${tt}-clang++"

EOF
	done
}

src_compile() {
	${EPYTHON} x.py build --config cros-config.toml || die
}

src_install() {
	local obj="build/x86_64-unknown-linux-gnu/stage2"
	local tools="${obj}-tools/x86_64-unknown-linux-gnu/release/"
	dobin "${obj}/bin/rustc" "${obj}/bin/rustdoc"
	dobin "${tools}/rustfmt" "${tools}/cargo-fmt"
	dobin "${tools}/clippy-driver" "${tools}/cargo-clippy"
	dobin src/etc/rust-gdb src/etc/rust-lldb
	insinto "/usr/$(get_libdir)"
	doins -r "${obj}/lib/"*
	doins -r "${obj}/lib64/"*
}
