# kiali-installer

A simple makefile to install [Kiali](https://kiali.io/) into your dev cluster.

**WARNING**: I use this on my own clusters with great success, but YMMV greatly; I am not responsible.

Note: Only runs on a Mac (tools target is currently Apple Silicon only)

# Usage

Just point kubectl at your cluster and type `make`

# TODO

* [ ] set up auth with keycloak
* [ ] Make auth pass through to grafana
* [ ] Make auth pass through to prometheus server so we dont install our own.
