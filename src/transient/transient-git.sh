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
    # git log --all --pretty=format:'commit: %H %nsubject: %s %nauthor: %aN %nemail: %aE %ndate: %at%nparents: %P%nRefs: %D'
    local gitcols='%H,%at,%P,%D,%aN,%aE,%N'
    echo "$gitcols" | tr -d '%' > "../../../target/git/$metriclite_gitname.csv"
    local gitsepcols="$(echo -n "__METRICLITEINIT__${gitcols}__METRICLITEINIT__" | sed 's/,/__METRICLITESEP__/g')"
    git log --name-only --all "--pretty=format:$gitsepcols" | \
        sed 's/"/""/g' | \
        sed 's/__METRICLITESEP__/","/g' | \
        sed 's/__METRICLITEINIT__/"/g' >> "../../../target/git/$metriclite_gitname.csv"
    gzip -f "../../../target/git/$metriclite_gitname.csv"
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
        "metriclite.TRANSIENT_GIT_$metriclite_gitname" "target/git/$metriclite_gitname.csv.gz"
}

function cmd_update() {
    local metriclite_gitname="${1?'metriclite_gitname'}"
    local metriclite_giturl="${2?'metriclite_giturl'}"
    cmd_download "$metriclite_gitname" "$metriclite_giturl"
    cmd_convert_commits "$metriclite_gitname"
    cmd_upload "$metriclite_gitname"
}

cd "$(dirname "$0")"; _cmd="${1?"cmd is required"}"; shift; "cmd_${_cmd}" "$@"
