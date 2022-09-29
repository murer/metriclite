#!/bin/bash -xe

# function cmd_mk() {
#     bq show metriclite.TRANSIENT_KANBANIZE || \
#         bq mk --table metriclite.TRANSIENT_KANBANIZE schema.json
# }

function cmd_download() {
    #rm -rf target || true
    mkdir -p target

    wget -O target/export.xlsx --progress=dot -e dotbytes=32K "$KANBANIZE_KEY"
}

function cmd_convert() {
    libreoffice --convert-to csv --outdir target --headless target/export.xlsx
    cat target/export.csv | gzip > target/export.csv.gz
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
    cmd_convert
    cmd_upload
}

cd "$(dirname "$0")"; _cmd="${1?"cmd is required"}"; shift; "cmd_${_cmd}" "$@"
