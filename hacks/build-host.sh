#!/bin/sh
# vim: et ts=2 sw=2 syn=sh
#
# Containerised build for the containerd/cloud-hypervisor system extension image.
# Usage:
#   hacks/build-sysext.sh [--arch <arch>]
# The optional <arch> can be x86-64 or arm64. The resulting image is containerd-cloudhypervisor.raw.

set -euo pipefail
scriptdir="$(cd "$(dirname "$0")"; pwd)"
source "${scriptdir}/util.inc"

# Runs inside the container
build() {
  local host_user_group="$1"

  mkdir -p /opt/build-host
  cd /opt/build-host
  cp -a /host/* .

  build_if_missing "$host_user_group" /host/hacks/build-static-rust.sh containerd-shim-cloudhv -- containerd-shim-cloudhv-v1
  build_if_missing "$host_user_group" /host/hacks/build-static-rust.sh cloudhv-sandbox-daemon -- cloudhv-sandbox-daemon

  cp containerd-shim-cloudhv-v1 \
     cloudhv-sandbox-daemon \
        /host
  chown "$host_user_group" \
        /host/containerd-shim-cloudhv-v1 \
        /host/cloudhv-sandbox-daemon
}
# --
  
if [ "${1:-}" = "build" ] ; then
  shift
  build ${@}
else
  echo -e "\n ------=======####### Building the system extension #######=======-------\n"
  docker_wrapper ${@}
  echo -e "\n ------=======#######  Sysext Build done #######=======-------\n"
fi
