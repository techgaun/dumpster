#!/bin/bash

APP_DIR="/opt/hub_gateway"
BUNDLE="/tmp/hub_gateway.tar.gz"
bin_file="${APP_DIR}/bin/hub_gateway"

log() {
    echo "$1"
}

fatal() {
  echo "$1"
  exit 1
}

if [ ! -f ${BUNDLE} ]; then
  fatal "Can't find bundle file: ${BUNDLE}"
fi

APP_TMP_DIR=/opt/build/${APP_NAME}
rm -rf ${APP_TMP_DIR}
mkdir -p ${APP_TMP_DIR}

tar xzf ${BUNDLE} -C ${APP_TMP_DIR} || fatal "Can't unpack bundle"

ENV_FILE="/opt/secret/.env"

if [ ! -f "${ENV_FILE}" ]; then
  fatal "No .env file found. Can't continue..."
fi
while read line; do
  export "$line"
done < "${ENV_FILE}"

if [[ -f "${bin_file}" ]]; then
  ${bin_file} stop
else
  pkill beam.smp
fi

rm -rf "${APP_DIR}"
mv "${APP_TMP_DIR}" "${APP_DIR}"
cd ${APP_DIR}

./bin/hub_gateway start

log "Started the hub gateway app"
