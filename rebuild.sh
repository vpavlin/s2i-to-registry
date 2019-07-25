#!/usr/bin/bash

[ -z "${NAMESPACE}" ] && NAMESPACE=`cat /var/run/secrets/kubernetes.io/serviceaccount/namespace`
[ -z "${TOKEN}" ] && TOKEN=`cat /var/run/secrets/kubernetes.io/serviceaccount/token`
[ -z "${BUILD_CONFIGS}" ] && echo "No Build Configs listed, will rebuild all existing build configs"

TARGET_DIR="/tmp"

OIFS=${IFS}
IFS='
'
for info in `oc get buildconfig --no-headers`; do
    echo "INFO: ${info}"
    NAME=$(echo ${info} | awk '{print $1}')

    if [ -n "${BUILD_CONFIGS}" ] && echo ${BUILD_CONFIGS} | grep -qv ${NAME}; then
        echo "Skipping ${NAME}, not listed in BUILD_CONFIGS"
        continue
    fi

    if oc get build -l buildconfig=${NAME} | grep -q Running; then
        echo "Build of ${NAME} is already running, no need to start a new one"
        continue
    fi

    oc start-build $NAME
done

sleep 10

while oc get build | grep -q Running; do
    BUILDS=$(oc get build -o jsonpath='{.items[?(@.status.phase=="Running")].metadata.name}')
    echo "Builds ${BUILDS} still running"
    sleep 5
done