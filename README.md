# Kairos k3s on Ubuntu 24.04

Builds a Kairos ISO: **Ubuntu 24.04** base, **amd64**, **generic** model, with **k3s** (latest) preinstalled, plus Intel TDX/SGX attestation packages.

## Releases

Push a tag (e.g. `v1.0.0`) to trigger the [release workflow](.github/workflows/release.yaml). The ISO and its checksum are published on the GitHub release for that tag.

## How it works

Uses [kairos-factory-action](https://github.com/kairos-io/kairos-factory-action). The workflow passes `dockerfile_path: "Dockerfile"` so the build uses the `Dockerfile` at the root of this repo instead of the upstream default.

The `Dockerfile` starts from the upstream Kairos base and adds extra packages before handing off to `kairos-init`, which installs k3s and configures the Kairos system.

## Customizing the image

All image customization happens in [`Dockerfile`](./Dockerfile). The general pattern:

1. Add a `RUN` layer **before** the `kairos-init` step for packages that need to be present when kairos-init runs.
2. Add a `RUN` layer **after** the `kairos-init` step for anything that should survive on top of the fully initialized system.

### Adding packages from a third-party apt repository

```dockerfile
RUN apt-get update && apt-get install -y --no-install-recommends wget ca-certificates && \
    wget -qO /tmp/repo.key https://example.com/repo.key && \
    mkdir -p /etc/apt/keyrings && \
    cat /tmp/repo.key | tee /etc/apt/keyrings/repo.asc > /dev/null && \
    echo 'deb [signed-by=/etc/apt/keyrings/repo.asc] https://example.com/repo distro main' | tee /etc/apt/sources.list.d/repo.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends my-package && \
    rm -f /tmp/repo.key && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
```

### Currently included extras

**Intel TDX attestation** ([source](https://cc-enabling.trustedservices.intel.com/intel-tdx-enabling-guide/05/host_os_setup/#__tabbed_3_2)) — packages from the Intel SGX apt repository (`noble` suite):

| Package | Description |
|---|---|
| `tdx-qgs` | TDX Quote Generation Service |
| `libsgx-dcap-default-qpl` | SGX DCAP default Quote Provider Library |
| `libsgx-dcap-ql` | SGX DCAP Quote Library |
