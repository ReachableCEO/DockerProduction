# README for KNEL CLoudron Packaging

```shell
mkdir Docker
chmod +x *.sh
./UpstreamVendor-Clone.sh
```

The above will do a (sparse) clone of all the upstream vendor software/docker repositories for every app TSYS runs on Cloudron.

You can keep the checkouts synced with

```shell
UpstreamVendor-Update.sh
```