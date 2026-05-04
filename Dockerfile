ARG BASE_IMAGE=ubuntu:24.04
ARG KAIROS_INIT=v0.8.4

FROM quay.io/kairos/kairos-init:${KAIROS_INIT} AS kairos-init

FROM ${BASE_IMAGE} AS base-kairos
ARG MODEL=generic
ARG TRUSTED_BOOT=false
ARG KUBERNETES_DISTRO
ARG KUBERNETES_VERSION
ARG VERSION
ARG FIPS=no-fips

# Install Intel TDX/SGX attestation packages (QGS + DCAP libraries)
RUN apt-get update && apt-get install -y --no-install-recommends wget ca-certificates && \
    wget -qO /tmp/intel-sgx-deb.key https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.key && \
    mkdir -p /etc/apt/keyrings && \
    cat /tmp/intel-sgx-deb.key | tee /etc/apt/keyrings/intel-sgx-keyring.asc > /dev/null && \
    echo 'deb [signed-by=/etc/apt/keyrings/intel-sgx-keyring.asc arch=amd64] https://download.01.org/intel-sgx/sgx_repo/ubuntu noble main' | tee /etc/apt/sources.list.d/intel-sgx.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        tdx-qgs \
        sgx-dcap-pccs \
        sgx-pck-id-retrieval-tool \
        sgx-ra-service \
        libtdx-attest \
        libtdx-attest-dev \
        libsgx-dcap-default-qpl \
        libsgx-dcap-ql && \
    rm -f /tmp/intel-sgx-deb.key && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN --mount=type=bind,from=kairos-init,src=/kairos-init,dst=/kairos-init \
    if [ -n "${KUBERNETES_DISTRO}" ]; then \
        K8S_FLAG="-p ${KUBERNETES_DISTRO}"; \
        if [ "${KUBERNETES_DISTRO}" = "k0s" ] && [ -n "${KUBERNETES_VERSION}" ]; then \
            K8S_VERSION_FLAG="--provider-k0s-version \"${KUBERNETES_VERSION}\""; \
        elif [ "${KUBERNETES_DISTRO}" = "k3s" ] && [ -n "${KUBERNETES_VERSION}" ]; then \
            K8S_VERSION_FLAG="--provider-k3s-version \"${KUBERNETES_VERSION}\""; \
        else \
            K8S_VERSION_FLAG=""; \
        fi; \
    else \
        K8S_FLAG=""; \
        K8S_VERSION_FLAG=""; \
    fi; \
    if [ "$FIPS" == "fips" ]; then FIPS_FLAG="--fips"; else FIPS_FLAG=""; fi; \
    eval /kairos-init -l debug -s install -m \"${MODEL}\" -t \"${TRUSTED_BOOT}\" ${K8S_FLAG} ${K8S_VERSION_FLAG} --version \"${VERSION}\" \"${FIPS_FLAG}\" && \
    eval /kairos-init -l debug -s init -m \"${MODEL}\" -t \"${TRUSTED_BOOT}\" ${K8S_FLAG} ${K8S_VERSION_FLAG} --version \"${VERSION}\" \"${FIPS_FLAG}\"
