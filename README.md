# Simple Tor Fileserver

Launch a simple tor-connected fileserver in a docker image.

## How to use

*Make sure that docker is installed, and you are part of docker group.*

```
git clone *repository url*
cd tor-fileserver
./start.sh
```

Place desired files into `tor-fileserver/files` directory.

You can access files via `address.onion/files/filename.ext`. 

Onion address will be printed to console when you run `./start.sh`

## Development

The `start.sh` script includes environment flags for force-rebuilding the docker image, as well as mounting the container in bash.