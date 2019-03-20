# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

CROS_WORKON_COMMIT="b43b55d4619489e603780adf3c92a36dadcc362b"
CROS_WORKON_TREE="b09304eab38348e2a157c4adc75542a460746ce9"
CROS_WORKON_PROJECT="chromiumos/third_party/mesa"
CROS_WORKON_BLACKLIST="1"

DESCRIPTION="VA-API library for amdgpu driver"
HOMEPAGE="http://mesa3d.sourceforge.net/"


inherit autotools cros-workon

LICENSE="MIT LGPL-3 SGI-B-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""

LIBDRM_DEPSTRING=">=x11-libs/libdrm-2.4.60"

# keep correct libdrm and libva
RDEPEND="${LIBDRM_DEPSTRING}
	>=x11-libs/libva-2.4.0"

DEPEND="${RDEPEND}
	sys-devel/llvm
"

VA_INSTALL="src/gallium/targets/va/"

src_prepare() {
	epatch "${FILESDIR}"/17.2.3-config-make-error-as-warning-for-drm.patch
	eautoreconf
}

src_configure() {
	export LLVM_CONFIG=${SYSROOT}/usr/lib/llvm/bin/llvm-config-host

	econf \
		--enable-autotools \
		--disable-option-checking \
		--disable-glu \
		--disable-glut \
		--disable-omx-bellagio \
		--enable-va \
		--disable-vdpau \
		--disable-xvmc \
		--without-demos \
		--disable-texture-float \
		--disable-egl \
		--disable-opengl \
		--disable-gles1 \
		--disable-gles2 \
		--disable-gbm \
		--disable-dri \
		--disable-dri3 \
		--disable-glx \
		--disable-shared-glapi\
		--disable-llvm-shared-libs \
		--with-gallium-drivers=radeonsi \
		--with-platforms=drm
}
src_install() {
	cd "${VA_INSTALL}"
	default
	# install radeonsi_drv_video.so in LIBVA standard path
	insinto "/usr/$(get_libdir)/va/drivers/"
	insopts -m0755
	doins "${D}/usr/$(get_libdir)/dri/radeonsi_drv_video.so"
}
