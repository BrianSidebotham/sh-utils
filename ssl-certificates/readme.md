# SSL Certificates

Generate a rootca and server cert in one command, i.e.: `./mkcert.sh proxmox.int.bjs`

This will generate the whole cert pack for you.

## Debian

On Linux Mint here...

You need to add the root ca in your personal store:

If you don't yet have a store:

```
mkdir -p ~/.pki/nssdb
certutil -N -d sql:$HOME/.pki/nssdb
```

Then

```
certutil -d sql:$HOME/.pki/nssdb -A -t "C,," -n ".int.bjs" -i rootca.crt
```

List the rootca:

```
certutil -d sql:$HOME/.pki/nssdb -L <nickname of cert>
```

Info about the ca:

```
certutil -d sql:$HOME/.pki/nssdb -L <nickname of cert>
```

Also add it so that Firefox and Chrome recongnise the CA:

```
sudo cp ./rootca.crt /usr/share/ca-certificates/
sudo dpkg-reconfigure ca-certificates
```

## Using the certificates

Some things are fussy:

## Ubiquiti Unifi Controllers

It is required (believe it or not) to make all certificates single line certificates (remove all of the line breaks
in the cert file). You need the `rootca.crt` and `whatever.wherever.crt` certs to import into the unifi controller like
so:

```
java -jar lib/ace.jar import_cert /root/unifi.int.bjs.crt /root/wc.int.bjs.crt
```
