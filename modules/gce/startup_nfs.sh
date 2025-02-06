#!/bin/bash
set -e  # Exit script on any error
set -x  # Print commands for debugging

LOGFILE="/var/log/startupscript.log"
exec > >(tee -a "$LOGFILE") 2>&1

# Update system
sudo apt-get update -y
sudo apt-get install -y nfs-kernel-server mdadm apt-transport-https ca-certificates gnupg curl

# RAID Setup
if ! grep -qs "/dev/md127" /etc/fstab; then
    sudo mdadm --zero-superblock /dev/nvme0n1
    sudo mdadm --zero-superblock /dev/nvme0n2
    sudo mdadm --create --verbose /dev/md127 --level=0 --raid-devices=2 /dev/nvme0n1 /dev/nvme0n2
    sudo mkfs.ext4 -F /dev/md127
fi

# Mounting RAID
sudo mkdir -p /data
echo "/dev/md127 /data ext4 defaults 0 0" | sudo tee -a /etc/fstab
sudo mount -a
sudo chown -R nobody:nogroup /data
sudo chmod -R 777 /data

# Configure NFS
echo "/data *(rw,sync,no_subtree_check)" | sudo tee -a /etc/exports
sudo systemctl restart nfs-kernel-server
sudo exportfs -a
sudo systemctl enable nfs-server

# Add Google Cloud SDK
if ! command -v gcloud &> /dev/null; then
    echo "Installing Google Cloud SDK..."
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list
    sudo apt-get update -y
    sudo apt-get install -y google-cloud-cli kubectl google-cloud-sdk-gke-gcloud-auth-plugin
fi

# Install Terraform
if ! command -v terraform &> /dev/null; then
    sudo snap install terraform --classic
fi

# Update GRUB
if ! grep -q 'scsi_mod.use_blk_mq=Y' /etc/default/grub; then
    sudo sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="scsi_mod.use_blk_mq=Y"/g' /etc/default/grub
    sudo update-grub
fi

# Disable Google startup scripts and reboot
sudo systemctl disable google-startup-scripts
nohup bash -c "sleep 5 && reboot" &

echo "Startup script execution completed!"