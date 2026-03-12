#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

DISK_DEVICE="/dev/disk/by-id/google-nfs-data"
MOUNT_POINT="/srv/nfs/shared"
CLIENT_CIDR="${gke_cluster_ipv4_cidr}"

apt-get update
apt-get install -y nfs-kernel-server

mkdir -p "${MOUNT_POINT}"

if ! blkid "${DISK_DEVICE}" >/dev/null 2>&1; then
  mkfs.ext4 -F "${DISK_DEVICE}"
fi

grep -q "${DISK_DEVICE}" /etc/fstab || echo "${DISK_DEVICE} ${MOUNT_POINT} ext4 defaults,nofail 0 2" >> /etc/fstab
mount -a

mkdir -p "${MOUNT_POINT}"
chown -R nobody:nogroup "${MOUNT_POINT}"
chmod 0770 "${MOUNT_POINT}"

cat >/etc/exports <<EOF
${MOUNT_POINT} ${CLIENT_CIDR}(rw,sync,no_subtree_check,no_root_squash)
EOF

exportfs -ra
systemctl enable nfs-kernel-server
systemctl restart nfs-kernel-server

echo "NFS bootstrap complete"