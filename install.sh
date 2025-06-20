#!/usr/bin/env bash

set -e  # exit immediately upon any command failure

disks=$(lsblk -o PATH,TYPE | grep disk | cut -d " " -f 1)
lsblk ${disks}

i=1
echo
for disk in ${disks}
do
  echo -n "(${i}) ${disk}, "
  choice[${i}]="${disk}"
  i=$((i + 1))
done
echo -e "\b\b "  # remove trailing comma

read -p "Choose a disk: " -n 1
echo

disk="${choice[${REPLY}]}"
if [ "${disk}" == "" ]
then
  echo "ERROR: Invalid disk choice"
  exit 1
fi

sed -i "s|device = \"\";|device = \"${disk}\";|" ~/nixos-config/disko.nix

sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount ~/nixos-config/disko.nix

sudo mkdir -p /mnt/etc/nixos
sudo cp ~/nixos-config/configuration.nix /mnt/etc/nixos
sudo cp ~/nixos-config/dell-thunder.jpg /mnt/boot
sudo nixos-install

for i in {15..0}
do
  echo -ne "\rRebooting in ${i} seconds "
  sleep 1
done

reboot

# [EOF]
