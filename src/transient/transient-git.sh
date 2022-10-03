#!/bin/bash -xe

function cmd_download() {
    local metriclite_gitname="${1?'metriclite_gitname'}"
    local metriclite_giturl="${2?'metriclite_giturl'}"
    mkdir -p target/git
    rm -rf "target/git/$metriclite_gitname" || true
    git clone "$metriclite_giturl" "target/git/$metriclite_gitname"
}

function cmd_convert_commits() {
    local metriclite_gitname="${1?'metriclite_gitname'}"
    cd "target/git/$metriclite_gitname"
    local gitcols='%H,%at,%P,%D,%aN,%aE,%s'
    echo "$gitcols" | tr -d '%' > "../../../target/git/commits-$metriclite_gitname.csv"
    local gitsepcols="$(echo -n "__METRICLITEINIT__${gitcols}__METRICLITEINIT__" | sed 's/,/__METRICLITESEP__/g')"
    git log --all "--pretty=format:$gitsepcols" | \
        sed 's/"/""/g' | \
        sed 's/__METRICLITESEP__/","/g' | \
        sed 's/__METRICLITEINIT__/"/g' >> "../../../target/git/commits-$metriclite_gitname.csv"
    gzip -f "../../../target/git/commits-$metriclite_gitname.csv"
    cd -
}

function cmd_convert_files() {
    local metriclite_gitname="${1?'metriclite_gitname'}"
    cd "target/git/$metriclite_gitname"
    # git log --name-status --all '--pretty=format:"%n"%H","' | tail -c +3 | hea
    echo "n,k,v" > "../../../target/git/files-$metriclite_gitname.csv"
    # local commithash=""
    # set +x
    # git log --name-status --all '--pretty=format:ID%x09%H' | grep -v '^$' | while read k; do
    #     if [[ "x$(echo "$k" | cut -f1)" == "xID" ]]; then
    #         commithash="$(echo "$k" | cut -f2)"
    #     else
    #         echo -e "$commithash\t$k" | sed 's/\t/,/g' >> "../../../target/git/files-$metriclite_gitname.csv"
    #     fi
    # done
    # set -x
    git log --name-status --all '--pretty=format:ID%x09%H' | \
        grep '.\+' | grep -n '.*' | \
        sed 's/:/,/1' | \
        sed 's/\t/,/1' >> "../../../target/git/files-$metriclite_gitname.csv"
    gzip -f "../../../target/git/files-$metriclite_gitname.csv"
    cd -
}

function cmd_upload() {
    local metriclite_gitname="${1?'metriclite_gitname'}"
    bq load --source_format CSV \
        --skip_leading_rows 1 \
        --replace \
        --allow_quoted_newlines \
        --sync \
        --autodetect \
        "metriclite.TRANSIENT_GIT_${metriclite_gitname}_COMMITS" "target/git/commits-$metriclite_gitname.csv.gz"

    bq load --source_format CSV \
        --skip_leading_rows 1 \
        --replace \
        --allow_quoted_newlines \
        --sync \
        --autodetect \
        "metriclite.TRANSIENT_GIT_${metriclite_gitname}_FILES" "target/git/files-$metriclite_gitname.csv.gz"
}

function cmd_update() {
    local metriclite_gitname="${1?'metriclite_gitname'}"
    local metriclite_giturl="${2?'metriclite_giturl'}"
    cmd_download "$metriclite_gitname" "$metriclite_giturl"
    cmd_convert_commits "$metriclite_gitname"
    cmd_convert_files "$metriclite_gitname"
    cmd_upload "$metriclite_gitname"
}

cd "$(dirname "$0")"; _cmd="${1?"cmd is required"}"; shift; "cmd_${_cmd}" "$@"
