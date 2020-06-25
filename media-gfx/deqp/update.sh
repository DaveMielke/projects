#!/bin/sh

deqp_repo=$1

if [ -z "$deqp_repo" ]; then
    echo usage: $0 DEQP_REPO
    exit 1
fi

declare -A revisions
declare -A git_repos=(
    [SPIRV-Headers]=https://github.com/KhronosGroup/SPIRV-Headers/archive
    [SPIRV-Tools]=https://github.com/KhronosGroup/SPIRV-Tools/archive
    [glslang]=https://github.com/KhronosGroup/glslang/archive
    [amber]=https://github.com/google/amber/archive
)

for module in "${!git_repos[@]}"; do
    # Pull the git sha1 out of fetch_sources.py
    revision=$(PYTHONPATH=$deqp_repo/external python2 -c "import fetch_sources; \
	print [p for p in fetch_sources.PACKAGES if p.baseDir == '$module'.lower()][0].revision")

    var=${module/-/_}
    var="MY_${var^^}_COMMIT"
    sed_cmd="${sed_cmd}s/${var}='.*'/${var}='$revision'/; "
    revisions[$module]=$revision
done

# Add the deqp repo and revision manually here, then do the transfers
# and ebuild update.
git_repos[deqp]=https://android.googlesource.com/platform/external/deqp/+archive
revisions[deqp]=$(git -C $deqp_repo show-ref -s --head ^HEAD)

sed_cmd="${sed_cmd}s/MY_DEQP_COMMIT='.*'/MY_DEQP_COMMIT='${revisions[deqp]}'/;"

for module in "${!git_repos[@]}"; do
    wget --no-clobber ${git_repos[$module]}/${revisions[$module]}.tar.gz -O $module-${revisions[$module]}.tar.gz
    gsutil.py cp -a public-read $module-${revisions[$module]}.tar.gz gs://chromeos-localmirror/distfiles/
done

# Edit ebuild and bump name or revision

now=$(date "+%Y.%m.%d")
old_ebuild=$(git ls-files *.ebuild)

echo old_ebuild: $old_ebuild

if [ "${old_ebuild%-r*.ebuild}" = "deqp-${now}" ]; then
    r=$(echo $old_ebuild | sed "s/deqp-.*-r\([0-9]*\).ebuild/\1/")
    ebuild="deqp-$now-r$((r + 1)).ebuild"
    echo bump ebuild revision to: $ebuild
else
    ebuild="deqp-$now-r1.ebuild"
    echo bump ebuild date to: $ebuild
fi

git mv "$old_ebuild" "$ebuild"

sed -i -e "$sed_cmd" $ebuild

ebuild $ebuild manifest

git add -u
