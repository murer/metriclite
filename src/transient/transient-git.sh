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
    local gitcols='%H,%at,%P,%D,%aN,%aE,%s'
    local gitsepcols="$(echo -n "$gitcols" | sed 's/,/__METRICLITESEP__/g')"
    git log --all "--pretty=format:$gitsepcols" | \
        sed 's/"/""/g' | \
        sed 's/__METRICLITESEP__/","/g' | \
        sed 's/^/"/g' | sed 's/$/"/g'
    cd -
}

function cmd_upload() {
    bq load --source_format CSV \
        --skip_leading_rows 1 \
        --replace \
        --allow_quoted_newlines \
        --sync \
        --autodetect \
        metriclite.TRANSIENT_KANBANIZE target/export.csv.gz
}

function cmd_update() {
    cmd_download
    cmd_convert_commits
    #cmd_upload
}

cd "$(dirname "$0")"; _cmd="${1?"cmd is required"}"; shift; "cmd_${_cmd}" "$@"
