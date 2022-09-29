#!/bin/bash -xe

function cmd_check() {
    local bq_query="${1?'query file to be used'}"
    cat "$bq_query" | bq query --use_legacy_sql=false --format csv | tail -n +2 | diff - true.txt
    echo "Check $bq_query: OK"
}

function cmd_table() {
    local bq_query="${1?'query file to be used'}"
    [[ -f "$bq_query.sql" ]]
    cat "$bq_query.sql" | bq query --use_legacy_sql=false

    ls $bq_query.*.check.sql | while read k; do
        cmd_check "$k"
    done

    echo "Table created: $bq_query"
}

function cmd_query() {
    bq query --use_legacy_sql=false
}


cd "$(dirname "$0")"; _cmd="${1?"cmd is required"}"; shift; "cmd_${_cmd}" "$@"
