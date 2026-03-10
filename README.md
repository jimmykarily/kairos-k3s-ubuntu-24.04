# Kairos k3s on Ubuntu 24.04

Builds a single Kairos ISO: **Ubuntu 24.04** base, **amd64**, **generic** model, with **k3s** (latest) preinstalled.

## Releases

Push a tag (e.g. `v1.0.0`) to trigger the [release workflow](.github/workflows/release.yaml). The ISO and its checksum are published on the GitHub release for that tag.

## How it works

Uses [kairos-factory-action](https://github.com/kairos-io/kairos-factory-action) with the upstream Kairos Dockerfile from [kairos-io/kairos](https://github.com/kairos-io/kairos). No custom Dockerfile in this repo—just the workflow and config.
