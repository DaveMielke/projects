# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CROS_WORKON_COMMIT=("db9eb2fb535c8928aa9aae50e4ded6b6f2d5f2f0" "ebcc1a86c23c8b9683fdd1ab4be337267ed89151")
CROS_WORKON_TREE=("4d75f59d5b9cba741b59b0d28a456d711d58800c" "e7dba8c91c1f3257c34d4a7ffff0ea2537aeb6bb" "1c6667714fda46bb46d673a59092849eecd8434c")
CROS_WORKON_LOCALNAME=("../platform2" "libtextclassifier")
CROS_WORKON_PROJECT=("chromiumos/platform2" "chromiumos/third_party/libtextclassifier")
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/platform2/libtextclassifier")
CROS_WORKON_SUBTREE=("common-mk .gn" "")

PLATFORM_SUBDIR="libtextclassifier"

inherit cros-workon platform

DESCRIPTION="Library for classifying text"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/third_party/libtextclassifier/"

LICENSE="Apache-2.0"
SLOT="0/${PVR}"
KEYWORDS="*"
IUSE=""

RDEPEND="
	chromeos-base/chrome-icu:=
	dev-libs/flatbuffers:=
	dev-libs/libutf:=
	sci-libs/tensorflow:=
	sys-libs/zlib:=
"

DEPEND="
	${RDEPEND}
"

src_install() {
	dolib.a "${OUT}/libtextclassifier.a"

	# Install the header files to /usr/include/libtextclassifier/.
	local header_files=(
		"annotator/annotator.h"
		"annotator/cached-features.h"
		"annotator/contact/contact-engine-dummy.h"
		"annotator/contact/contact-engine.h"
		"annotator/datetime/extractor.h"
		"annotator/datetime/parser.h"
		"annotator/duration/duration.h"
		"annotator/entity-data_generated.h"
		"annotator/experimental/experimental-dummy.h"
		"annotator/experimental/experimental.h"
		"annotator/experimental/experimental_generated.h"
		"annotator/feature-processor.h"
		"annotator/grammar/dates/annotations/annotation-options.h"
		"annotator/grammar/dates/annotations/annotation.h"
		"annotator/grammar/dates/cfg-datetime-annotator.h"
		"annotator/grammar/dates/dates_generated.h"
		"annotator/grammar/dates/parser.h"
		"annotator/grammar/dates/timezone-code_generated.h"
		"annotator/grammar/dates/utils/annotation-keys.h"
		"annotator/grammar/dates/utils/date-match.h"
		"annotator/grammar/grammar-annotator.h"
		"annotator/installed_app/installed-app-engine-dummy.h"
		"annotator/installed_app/installed-app-engine.h"
		"annotator/knowledge/knowledge-engine-dummy.h"
		"annotator/knowledge/knowledge-engine.h"
		"annotator/model-executor.h"
		"annotator/model_generated.h"
		"annotator/number/number.h"
		"annotator/person_name/person-name-engine-dummy.h"
		"annotator/person_name/person-name-engine.h"
		"annotator/person_name/person_name_model_generated.h"
		"annotator/strip-unpaired-brackets.h"
		"annotator/translate/translate.h"
		"annotator/types.h"
		"annotator/zlib-utils.h"
		"lang_id/common/embedding-network-params.h"
		"lang_id/common/fel/task-context.h"
		"lang_id/common/lite_base/attributes.h"
		"lang_id/common/lite_base/casts.h"
		"lang_id/common/lite_base/compact-logging-levels.h"
		"lang_id/common/lite_base/compact-logging.h"
		"lang_id/common/lite_base/float16.h"
		"lang_id/common/lite_base/integral-types.h"
		"lang_id/common/lite_base/logging.h"
		"lang_id/common/lite_base/macros.h"
		"lang_id/common/lite_strings/stringpiece.h"
		"lang_id/lang-id-wrapper.h"
		"lang_id/lang-id.h"
		"lang_id/model-provider.h"
		"utils/base/arena.h"
		"utils/base/config.h"
		"utils/base/integral_types.h"
		"utils/base/logging.h"
		"utils/base/logging_levels.h"
		"utils/base/macros.h"
		"utils/base/port.h"
		"utils/base/status.h"
		"utils/base/statusor.h"
		"utils/calendar/calendar-common.h"
		"utils/calendar/calendar-icu.h"
		"utils/calendar/calendar.h"
		"utils/codepoint-range.h"
		"utils/codepoint-range_generated.h"
		"utils/container/sorted-strings-table.h"
		"utils/container/string-set.h"
		"utils/flatbuffers.h"
		"utils/flatbuffers_generated.h"
		"utils/grammar/callback-delegate.h"
		"utils/grammar/lexer.h"
		"utils/grammar/match.h"
		"utils/grammar/matcher.h"
		"utils/grammar/rules-utils.h"
		"utils/grammar/rules_generated.h"
		"utils/grammar/types.h"
		"utils/hash/farmhash.h"
		"utils/i18n/language-tag_generated.h"
		"utils/i18n/locale.h"
		"utils/intents/intent-config_generated.h"
		"utils/memory/mmap.h"
		"utils/normalization_generated.h"
		"utils/optional.h"
		"utils/resources_generated.h"
		"utils/strings/stringpiece.h"
		"utils/tensor-view.h"
		"utils/tflite-model-executor.h"
		"utils/token-feature-extractor.h"
		"utils/tokenizer.h"
		"utils/tokenizer_generated.h"
		"utils/utf8/unicodetext.h"
		"utils/utf8/unilib-common.h"
		"utils/utf8/unilib-icu.h"
		"utils/utf8/unilib.h"
		"utils/variant.h"
		"utils/zlib/buffer_generated.h"
		"utils/zlib/tclib_zlib.h"
	)
	local f
	for f in "${header_files[@]}"; do
		insinto "/usr/include/libtextclassifier/${f%/*}"
		if [[ "${f}" == *_generated.h ]]; then
			doins "${OUT}/gen/libtextclassifier/${f}"
		else
			doins "${S}/${f}"
		fi
	done
}
