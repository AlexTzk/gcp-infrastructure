#! /bin/bash
sudo apt-get -y update && sudo apt-get -y install nfs-kernel-server
sudo sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="scsi_mod.use_blk_mq=Y"/g' /etc/default/grub
sudo mdadm --zero-superblock /dev/nvme0n1
sudo mdadm --zero-superblock /dev/nvme0n2
sudo mdadm --create --verbose /dev/md127 --level=0 --raid-devices=2 /dev/nvme0n1 /dev/nvme0n2
sudo mkfs.ext4 -F /dev/md127
sudo mkdir /data
sudo echo "/dev/md127 /data ext4 defaults 0 0" | sudo tee -a /etc/fstab
sudo mount -a
sudo chown -R nobody:nogroup /data
sudo chmod -R 777 /data
sudo sh -c 'echo "/data *(rw,sync,no_subtree_check)" >> /etc/exports'
sudo systemctl restart nfs-kernel-server
sudo exportfs -a
sudo systemctl restart nfs-server
sudo systemctl enable nfs-server
sudo update-grub
sudo systemctl disable google-startup-scripts
sudo reboot
EOF