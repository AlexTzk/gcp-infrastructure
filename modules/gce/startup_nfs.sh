#!/bin/bash
set +e
set -x

LOGFILE="/var/log/startupscript.log"
exec > >(sudo tee -a "$LOGFILE") 2>&1

# Update and install
sudo apt-get update -y
sudo apt-get install -y nfs-kernel-server mdadm apt-transport-https ca-certificates gnupg curl

# RAID Setup
if ! grep -qs "/dev/md127" /etc/fstab; then
    sudo mdadm --zero-superblock /dev/nvme0n1
    sudo mdadm --zero-superblock /dev/nvme0n2
    sudo mdadm --create --verbose /dev/md127 --level=0 --raid-devices=2 /dev/nvme0n1 /dev/nvme0n2
    sudo mkfs.ext4 -F /dev/md127
fi

# Mounting RAID Array
sudo mkdir -p /data
if ! grep -qs "/dev/md127" /etc/fstab; then
    echo "/dev/md127 /data ext4 defaults 0 0" | sudo tee -a /etc/fstab
fi
sudo mount -a
sudo chown -R nobody:nogroup /data
sudo chmod -R 777 /data

# Configure NFS
echo "/data *(rw,sync,no_subtree_check)" | sudo tee -a /etc/exports
sudo systemctl restart nfs-kernel-server
sudo exportfs -a
sudo systemctl enable nfs-server

# install Google Cloud SDK
echo "Installing Google Cloud SDK and dependencies..."
sudo apt-get install -y apt-transport-https ca-certificates gnupg curl

curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list

sudo apt-get update -y
sudo apt-get install -y google-cloud-cli kubectl google-cloud-sdk-gke-gcloud-auth-plugin

# Install Terraform via Snap
sudo snap install terraform --classic

# Update GRUB configuration
if ! grep -q 'scsi_mod.use_blk_mq=Y' /etc/default/grub; then
    sudo sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="scsi_mod.use_blk_mq=Y"/g' /etc/default/grub
    sudo update-grub
fi

# Disable Google startup scripts and schedule reboot
sudo systemctl disable google-startup-scripts
nohup bash -c "sleep 5 && sudo reboot" &
echo "Startup script execution completed!"
