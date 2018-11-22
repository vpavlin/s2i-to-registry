#!/usr/bin/bash

[ -z "${NAMESPACE}" ] && NAMESPACE=`cat /var/run/secrets/kubernetes.io/serviceaccount/namespace`
[ -z "${REGISTRY}" ] && REGISTRY="quay.io"
[ -z "${REPOSITORY}" ] && REPOSITORY="vpavlin"

TARGET_DIR="/tmp"

if [ -z "${REGISTRY_AUTH}" ]; then
    echo "You need to provide 'auth' value from \$HOME/.docker/config.json to be able to push to registry ${REGISTRY}"
    exit 1
fi

cat config.json.template | sed "s/@REGISTRY@/${REGISTRY}/"  | sed "s/@AUTH@/${REGISTRY_AUTH}/" > ~/.docker/config.json

OIFS=${IFS}
IFS='
'
for info in `oc get imagestream --no-headers`; do
    echo "INFO: ${info}"
    LOCAL_IMAGE_URL=$(echo ${info} | awk '{print $2}')
    TAGS=$(echo ${info} | awk '{print $3}' | tr "," "\n")
    NAME=$(echo ${info} | awk '{print $1}')
    for tag in `echo ${TAGS}`; do
        TARGET=${TARGET_DIR}/${NAME}-${tag}
        echo "Pushing ${NAME}:${tag}"
        skopeo copy docker://${LOCAL_IMAGE_URL} docker://${REGISTRY}/${REPOSITORY}/${NAME}:${tag} &&\
                echo ${REGISTRY}/${REPOSITORY}/${NAME}:${tag} || exit 1
    done
done
IFS=${OFS}

