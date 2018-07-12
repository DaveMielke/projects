# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: cargo.eclass
# @MAINTAINER:
# rust@gentoo.org
# @AUTHOR:
# Doug Goldstein <cardoe@gentoo.org>
# @BLURB: common functions and variables for cargo builds

if [[ -z ${_CARGO_ECLASS} ]]; then
_CARGO_ECLASS=1

case ${EAPI} in
	6) : ;;
	5) : ;; # addition to the upstream version because we don't have EAPI=6
	*) die "EAPI=${EAPI:-0} is not supported" ;;
esac

inherit toolchain-funcs

EXPORT_FUNCTIONS src_unpack src_compile src_install

IUSE="${IUSE} debug"

[[ ${CATEGORY}/${PN} != dev-util/cargo ]] && DEPEND=">=dev-util/cargo-0.13.0"

ECARGO_HOME="${WORKDIR}/cargo_home"
ECARGO_VENDOR="${ECARGO_HOME}/gentoo"

# @FUNCTION: cargo_crate_uris
# @DESCRIPTION:
# Generates the URIs to put in SRC_URI to help fetch dependencies.
cargo_crate_uris() {
	for crate in $*; do
		local name version url pretag
		name="${crate%-*}"
		version="${crate##*-}"
		pretag="[a-zA-Z]+"
		if [[ $version =~ $pretag ]]; then
			version="${name##*-}-${version}"
			name="${name%-*}"
		fi
		url="https://crates.io/api/v1/crates/${name}/${version}/download -> ${crate}.crate"
		echo $url
	done
}

# @FUNCTION: cargo_src_unpack
# @DESCRIPTION:
# Unpacks the package and the cargo registry
cargo_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	mkdir -p "${ECARGO_VENDOR}" || die
	mkdir -p "${S}" || die

	local archive
	for archive in ${A}; do
		case "${archive}" in
			*.crate)
				ebegin "Loading ${archive} into Cargo registry"
				tar -xf "${DISTDIR}"/${archive} -C "${ECARGO_VENDOR}/" || die
				# generate sha256sum of the crate itself as cargo needs this
				shasum=$(sha256sum "${DISTDIR}"/${archive} | cut -d ' ' -f 1)
				pkg=$(basename ${archive} .crate)
				cat <<- EOF > ${ECARGO_VENDOR}/${pkg}/.cargo-checksum.json
				{
					"package": "${shasum}",
					"files": {}
				}
				EOF
				# if this is our target package we need it in ${WORKDIR} too
				# to make ${S} (and handle any revisions too)
				if [[ ${P} == ${pkg}* ]]; then
					tar -xf "${DISTDIR}"/${archive} -C "${WORKDIR}" || die
				fi
				eend $?
				;;
			cargo-snapshot*)
				ebegin "Unpacking ${archive}"
				mkdir -p "${S}"/target/snapshot
				tar -xzf "${DISTDIR}"/${archive} -C "${S}"/target/snapshot --strip-components 2 || die
				# cargo's makefile needs this otherwise it will try to
				# download it
				touch "${S}"/target/snapshot/bin/cargo || die
				eend $?
				;;
			*)
				unpack ${archive}
				;;
		esac
	done

	cargo_gen_config
}

# @FUNCTION: cargo_gen_config
# @DESCRIPTION:
# Generate the $CARGO_HOME/config necessary to use our local registry
cargo_gen_config() {
	debug-print-function ${FUNCNAME} "$@"

	cat <<- EOF > ${ECARGO_HOME}/config
	[source.gentoo]
	directory = "${ECARGO_VENDOR}"

	[source.crates-io]
	replace-with = "gentoo"
	local-registry = "/nonexistant"

	[target.${CHOST}]
	linker = "$(tc-getCC)"
	EOF
}

# @FUNCTION: cargo_src_compile
# @DESCRIPTION:
# Build the package using cargo build
cargo_src_compile() {
	debug-print-function ${FUNCNAME} "$@"

	export CARGO_HOME="${ECARGO_HOME}"
	export TARGET_CC="$(tc-getCC)"
	export CARGO_TARGET_DIR="${WORKDIR}"

	cargo build -v $(usex debug "" --release) --target="${CHOST}" \
		|| die "cargo build failed"
}

# @FUNCTION: cargo_src_install
# @DESCRIPTION:
# Installs the binaries generated by cargo
cargo_src_install() {
	debug-print-function ${FUNCNAME} "$@"

	cargo install --root="${D}/usr" $(usex debug --debug "") \
		|| die "cargo install failed"
	rm -f "${D}/usr/.crates.toml"

	[ -d "${S}/man" ] && doman "${S}/man" || return 0
}

fi
