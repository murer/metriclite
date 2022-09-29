FROM gcr.io/cloud-builders/gcloud

RUN apt-get -y update
RUN apt-get -y install libreoffice
RUN apt-get -y install wget

COPY src /opt/metriclite

WORKDIR /opt/metriclite

ENTRYPOINT []