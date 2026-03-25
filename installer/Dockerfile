# Lightweight installer image for the release workflow.
# This Dockerfile packages pre-built binaries (not compiled here).
# The release workflow builds each component separately and copies
# them into the build context before running this Dockerfile.
#
# Cloud Hypervisor is built from source (main branch) to get
# userfaultfd OnDemand restore (PR #7800). Switch to a released
# version once CH >= v51 is published.

# --- Stage 1: Build Cloud Hypervisor from source ---
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

COPY cloud-hypervisor /opt/cloudhv/cloud-hypervisor

COPY opt/cloudhv/ /opt/cloudhv/

RUN chmod +x /opt/cloudhv/containerd-shim-cloudhv-v1 \
             /opt/cloudhv/cloudhv-sandbox-daemon \
             /opt/cloudhv/cloud-hypervisor \
             /opt/cloudhv/install.sh

ENTRYPOINT ["/opt/cloudhv/install.sh"]
