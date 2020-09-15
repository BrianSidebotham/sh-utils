#!/bin/sh

# (c)2019 Brian Sidebotham <brian.sidebotham@gmail.com>

logv() {
  if ${verbose}; then
    echo "VERBOSE: ${@}"
  fi
}

if [ $# -lt 1 ]; then
    echo "usage: $0 --domain server.domain.name [--alt dns names] [--ou Organisational Unit]" >&2
    exit 1
fi

domain=
altnames=
verbose=false
C=GB
ST=Bracknell
O=BJS
OU=
CN=${domain}

while [ $# -gt 0 ]; do
    case "${1}" in
        --domain)
            shift
            domain="${1}"
            ;;

        --ou)
            shift
            OU="${1}"
            ;;

        --o)
            shift
            O="${1}"
            ;;

        --st)
            shift
            ST="${1}"
            ;;

        --cn)
            shift
            CN="${1}"
            ;;

        --c)
            shift
            C="${1}"
            ;;

        --alt)
            shift
            altnames="${1}"
            ;;

        --verbose|-v)
            verbose=true
            ;;
    esac

    shift
done

if [ "${domain}X" = "X" ]; then
    echo "domain must be set!" >&2
    exit 1
fi

CN=${domain}

subject=""

if [ "${C}X" != "X" ]; then
    subject="${subject}/C=${C}"
fi

if [ "${ST}X" != "X" ]; then
    subject="${subject}/ST=${ST}"
fi

if [ "${O}X" != "X" ]; then
    subject="${subject}/O=${C}"
fi

if [ "${OU}X" != "X" ]; then
    subject="${subject}/OU=${OU}"
fi

if [ "${CN}X" != "X" ]; then
    # For the root certificate, allow it to wildcard cover the domain
    rootsubject="${subject}/CN=*.$(echo ${CN} | cut -d. -f2-)"
    subject="${subject}/CN=${CN}"
fi

if [ ! -f rootca.key ]; then
    logv "Generating rootca.key"
    openssl genrsa -des3 -out rootca.key 4096
fi

if [ ! -f rootca.crt ]; then
    logv "Generating rootca.crt: ${rootsubject}"

    # Make the root CA a wildcard for a single level subdomain
    # Haven't bothered with adding in the apex too
    openssl req -x509 -new -nodes \
        -key rootca.key \
        -subj "${rootsubject}" \
        -sha256 \
        -days 1024 \
        -out rootca.crt
fi

logv "Generating CSR Private key: ${domain}.key"
openssl genrsa -out ${domain}.key 4096

# Generate a configuration that includes the SAN subject alt name required by Chrome and well, most browsers
# these days
opensslconfig=$(mktemp)

if [ "${altnames}X" = "X" ]; then
    altnames=${domain}
fi

i=1
dnsentries=""
for dns in ${altnames}; do
    dnsentries="${dnsentries}DNS.${i} = ${dns}
"
    i=$((i + 1))
done


cat << EOF > ${opensslconfig}
[req]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
C=${C}
ST=${ST}
L=
O=${O}
OU=${OU}
emailAddress=brian@int.bjs
CN=${CN}

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
${dnsentries}
EOF

logv "Using openssl configuration" "${opensslconfig}"

logv "Generating csr ${domain}.csr"
openssl req -new -nodes -sha256 \
    -key ${domain}.key \
    -subj "/C=${C}/ST=${ST}/O=${O}/CN=${CN}" \
    -out ${domain}.csr \
    -config ${opensslconfig}


if [ $? -ne 0 ]; then
    echo "ERROR: Failed to create ${domain}.csr" >&2
    exit 1
fi

if ${verbose}; then
    logv "CSR Information"
    openssl req -in ${domain}.csr -noout -text
fi

logv "Generating service certificate: ${domain}.crt"
openssl x509 -req -in ${domain}.csr \
    -CA rootca.crt -CAkey rootca.key -CAcreateserial \
    -extfile ${opensslconfig} \
    -extensions req_ext \
    -out ${domain}.crt \
    -days 700 \
    -sha256
