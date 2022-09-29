#!/bin/bash -xe

function cmd_deploy() {
    gcloud builds submit . --region us-east1
}

function cmd_poc2() {
    bq mk \
        --use_legacy_sql=false \
        --view 'select Card_ID from metriclite.POC limit 2' \
        metriclite.POCVIEW1    
}

function cmd_poc3() {
    bq query --use_legacy_sql=false '
        CREATE MATERIALIZED VIEW metriclite.POCMVIEW1
        AS SELECT Card_ID FROM metriclite.POC
    '
}

function cmd_poc4() {
    bq query --use_legacy_sql=false '
        CREATE OR REPLACE TABLE metriclite.POCTABLE1
        AS SELECT Card_ID FROM metriclite.POC limit 2
    '
}

function cmd_secret_load() {
    KANBANIZE_KEY="$(gcloud secrets versions access 1 --secret kanbanize-key)"
}

function cmd_execute() {
    gcloud builds submit --no-source --region us-east1 --config ./execute.yaml "$@"
}

function cmd_build() {
    docker build --cache-from metriclite/metriclite:dev -t metriclite/metriclite:dev .
    
}

function cmd_docker() {
    [[ "x$METRICLITE_PROJECT_NAME" != "x" ]] || METRICLITE_PROJECT_NAME="$(gcloud config list --format 'value(core.project)')"
    docker pull "gcr.io/$METRICLITE_PROJECT_NAME/metriclite:latest" || true
    docker tag "gcr.io/$METRICLITE_PROJECT_NAME/metriclite:latest" metriclite/metriclite:dev || true
    cmd_build
    docker tag metriclite/metriclite:dev "gcr.io/$METRICLITE_PROJECT_NAME/metriclite:latest"
    docker push "gcr.io/$METRICLITE_PROJECT_NAME/metriclite:latest"
}

function cmd_mktable() {
    bq mk \
        --table \
        metriclite.poc2 \
        ./src/transient/schema.json
}

function cmd_trigger_ci_delete() {
    gcloud beta builds triggers delete --region us-east1 metriclite-ci || true
}

function cmd_trigger_ci_create() {
    cmd_trigger_ci_delete
    gcloud beta builds triggers create cloud-source-repositories --region us-east1 \
        --name metriclite-ci --build-config=cloudbuild.yaml \
        --repo metriclite --branch-pattern '^master$'
}

function cmd_trigger_execute_delete() {
    gcloud scheduler jobs delete metriclite-execute-schedule --location us-east1 -q || true
    gcloud beta builds triggers delete --region us-east1 metriclite-execute || true
}

function cmd_trigger_execute_update() {
    cmd_trigger_execute_delete
    gcloud beta builds triggers create manual --region us-east1 \
        --name metriclite-execute --inline-config=execute.yaml
    gcloud scheduler jobs create http metriclite-execute-schedule \
        --location us-east1 \
        --schedule "*/30 * * * *" \
        --uri 'https://cloudbuild.googleapis.com/v1/projects/$METRICLITE_PROJECT_NAME/locations/us-east1/triggers/metriclite-execute:run' \
        --http-method POST \
        --time-zone America/Sao_Paulo \
        --oauth-service-account-email "$METRICLITE_PROJECT_NAME@appspot.gserviceaccount.com" \
        --oauth-token-scope "https://www.googleapis.com/auth/cloud-platform"
}

cd "$(dirname "$0")"; _cmd="${1?"cmd is required"}"; shift; "cmd_${_cmd}" "$@"
