#!/bin/sh

# (c)2019 Brian Sidebotham <brian.sidebotham@gmail.com>

if [ $# -lt 1 ]; then
    echo "usage: $0 server.domain.name" >&2
    exit 1
fi

domain=${1}

C=GB
ST=Bracknell
O=BJS
CN=${domain}

if [ ! -f rootca.key ]; then
    openssl genrsa -des3 -out rootca.key 4096
fi

if [ ! -f rootca.crt ]; then
    # Make the root CA a wildcard for a single level subdomain
    # Haven't bothered with adding in the apex too
    openssl req -x509 -new -nodes \
        -key rootca.key \
        -subj "/C=${C}/ST=${ST}/O=${O}/CN=*.$(echo ${CN} | cut -d. -f2-)" \
        -sha256 \
        -days 1024 \
        -out rootca.crt
fi

openssl genrsa -out ${domain}.key 4096

# Generate a configuration that includes the SAN subject alt name required by Chrome and well, most browsers
# these days
opensslconfig=$(mktemp)

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
OU=
emailAddress=brian@int.bjs
CN=${CN}

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = ${domain}
EOF

echo  "Generating CSR"

openssl req -new -nodes -sha256 \
    -key ${domain}.key \
    -subj "/C=${C}/ST=${ST}/O=${O}/CN=${CN}" \
    -out ${domain}.csr \
    -config ${opensslconfig}


if [ $? -ne 0 ]; then
    echo "ERROR: Failed to create ${domain}.csr" >&2
    exit 1
fi

echo "Generating Certificate"
openssl x509 -req -in ${domain}.csr \
    -CA rootca.crt -CAkey rootca.key -CAcreateserial \
    -extfile ${opensslconfig} \
    -extensions req_ext \
    -out ${domain}.crt \
    -days 700 \
    -sha256
