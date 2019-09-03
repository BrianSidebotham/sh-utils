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
