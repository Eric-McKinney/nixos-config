#!/usr/bin/env bash

set -e  # exit immediately upon any command failure

curl -sSL https://raw.githubusercontent.com/eric-mckinney/nixos-config/main/disko.nix -o ~/disko.nix

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

sed -i "s|device = \"\";|device = \"${disk}\";|" ~/disko.nix

sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount ~/disko.nix

sudo nixos-generate-config --root /mnt
sudo nixos-install

for i in {15..0}
do
  echo -ne "\rRebooting in ${i} seconds "
  sleep 1
done

reboot

# [EOF]
