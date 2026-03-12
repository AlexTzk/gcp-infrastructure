#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg \
  jq \
  lsb-release \
  nfs-common \
  postgresql-client 

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

apt-get update
apt-get install docker-ce -y \
 docker-ce-cli \
 containerd.io \
 docker-buildx-plugin \
 docker-compose-plugin

if ! command -v snap >/dev/null 2>&1; then
  apt-get install -y snapd
fi

snap install google-cloud-cli --classic || true
snap install kubectl --classic || true

echo "Bastion bootstrap complete"