#!/usr/bin/bash

[ -z "${NAMESPACE}" ] && NAMESPACE=`cat /var/run/secrets/kubernetes.io/serviceaccount/namespace`
[ -z "${REGISTRY}" ] && REGISTRY="quay.io"
[ -z "${REPOSITORY}" ] && REPOSITORY="vpavlin"
[ -z "${TOKEN}" ] && TOKEN=`cat /var/run/secrets/kubernetes.io/serviceaccount/token`
[ -z "${QUAY_API_TOKEN}" ] && [ "${REGISTRY}" == "quay.io" ] && echo "Quay.io API token was not provided, all created repositories will be private!"
[ -z "${IMAGE_STREAMS}" ] && echo "No Image Streams listed, will push all existing image streams"

TARGET_DIR="/tmp"

if [ -z "${REGISTRY_AUTH}" ]; then
    echo "You need to provide 'auth' value from \$HOME/.docker/config.json to be able to push to registry ${REGISTRY}"
    exit 1
fi

cat ~/.docker/config.json
cat config.json.template | sed "s/@REGISTRY@/${REGISTRY}/"  | sed "s/@AUTH@/${REGISTRY_AUTH}/" > ~/.docker/config.json

OIFS=${IFS}
IFS='
'
for info in `oc get imagestream --no-headers`; do
    echo "INFO: ${info}"
    LOCAL_IMAGE_URL=$(echo ${info} | awk '{print $2}')
    TAGS=$(echo ${info} | awk '{print $3}')
    NAME=$(echo ${info} | awk '{print $1}')

    if [ -n "${IMAGE_STREAMS}" ] && echo ${IMAGE_STREAMS} | grep -qv ${NAME}; then
        echo "Skipping ${NAME}, not listed in IMAGE_STREAMS"
        continue
    fi

    for tag in `echo ${TAGS} | tr "," "\n"`; do
        TARGET=${TARGET_DIR}/${NAME}-${tag}
        echo "Pushing ${NAME}:${tag}"
        if [ -n "${QUAY_API_TOKEN}" ]; then
            QUAY_HOSTNAME=${REGISTRY} QUAY_API_TOKEN=${QUAY_API_TOKEN} ./qucli get ${REPOSITORY}/${NAME} &> /dev/null
            if [ $? != 0 ]; then
                QUAY_HOSTNAME=${REGISTRY} QUAY_API_TOKEN=${QUAY_API_TOKEN} ./qucli create ${REPOSITORY}/${NAME} --visibility public
            fi
        fi
        skopeo copy \
            --src-creds s2t-to-registry:${TOKEN} \
            --src-cert-dir /var/run/secrets/kubernetes.io/serviceaccount/ docker://${LOCAL_IMAGE_URL}:${tag} docker://${REGISTRY}/${REPOSITORY}/${NAME}:${tag} &&\
                echo ${REGISTRY}/${REPOSITORY}/${NAME}:${tag} || exit 1
    done
done
IFS=${OFS}

