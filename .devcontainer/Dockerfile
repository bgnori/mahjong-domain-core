FROM mcr.microsoft.com/devcontainers/base:bookworm

ENV ELAN_HOME=/usr/local/elan
ENV PATH="/usr/local/elan/bin:${PATH}"

RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential ca-certificates curl git \
    && rm -rf /var/lib/apt/lists/* \
    && curl --proto '=https' --tlsv1.2 -fsSL https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -o /tmp/elan-init.sh \
    && sh /tmp/elan-init.sh -y --no-modify-path --default-toolchain none \
    && rm /tmp/elan-init.sh \
    && chown -R vscode:vscode "$ELAN_HOME"

COPY lean-toolchain /tmp/lean-toolchain
RUN toolchain="$(cat /tmp/lean-toolchain)" \
    && runuser -u vscode -- elan toolchain install "$toolchain" \
    && runuser -u vscode -- elan default "$toolchain" \
    && rm /tmp/lean-toolchain
