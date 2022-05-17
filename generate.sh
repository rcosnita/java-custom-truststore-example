#!/usr/bin/env bash
set -eox pipefail

STORE_PASSWD=${1:-test1234}
STORE_NAME=${2:-MyTrustStore}
export STORE_PASSWD=${STORE_PASSWD}

function generate_cert() {
    local pem=${1}
    local trust_store=${2}
    local file_name=$(basename pem)
    local file_crt=${file_name}.crt${file_name}.crt
    rm -f ${file_name}.crt || true
    openssl x509 -outform der -in ${pem} -out ${file_crt}
    keytool -import \
        -file ${file_crt} \
        -alias "${pem}" \
        -trustcacerts \
        -storepass ${STORE_PASSWD} \
        -noprompt \
        -keystore \
        ${trust_store}

    rm -f ${file_crt}
}

IFS=$'\n'
files=($(find . -name '*.pem'))
unset IFS

for cert in "${files[@]}"
do
    generate_cert ${cert} ${STORE_NAME}
done
