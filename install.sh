#!/usr/bin/env bash

set -e  # exit immediately upon any command failure

CONFIG_FILE=~/nixos-config/configuration.nix
DISKO_CONFIG_FILE=~/nixos-config/disko.nix

print_help() {
    cat <<-HEREDOC
	usage: ${0##*/} [--config|-c FILE] [--disk-config|-d FILE] [--server|-s] [--help]

	DESCRIPTION
	    Install nixos from within a nixos iso.

	OPTIONS
	    --config, -c
            Specify a file (given as a relative or absolute path) to use as the system
	        configuration. The file does not need to be named configuration.nix to be
	        used. The default configuration is ~/nixos-config/configuration.nix which
	        is used when no config file is specified.

	    --disk-config, -d
	        Specify a file (given as a relative or absolute path) to use as the disko
	        configuration for partitioning the block device chosen when the script is
	        run. The file does not need to be named disko.nix to be used. The default
	        configuration is ~/nixos-config/disko.nix which is used when no config
	        file is specified.

	    --server, -s
	        Use server_configuration.nix for the install. (Equivalent to using
            --config ~/nixos-config/server_configuration.nix)

	    --help
	        Display this message and exit.
	HEREDOC
}

while [[ $# -ne 0 ]]
do
    curr_opt="$1"
    case "$curr_opt" in
        --config|-c)
            shift

            if [[ ! -f "$1" ]]
            then
                echo "${0##*/}: error: config file \"$1\" specified via --config or -c does not exist"
                exit 1
            fi

            CONFIG_FILE="$1"
            ;;
        --disk-config|-d)
            shift

            if [[ ! -f "$1" ]]
            then
                echo "${0##*/}: error: disk config file \"$1\" specified via --disk-config or -d does not exist"
                exit 1
            fi

            DISKO_CONFIG_FILE="$1"
            ;;
        --server|-s) CONFIG_FILE=~/nixos-config/server_configuration.nix ;;
        --help) print_help; exit 0 ;;
        *) echo "${0##*/}: error: unknown option \"$curr_opt\""; exit 1 ;;
    esac
    shift
done

# TODO: exclude iso from block device listing
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

sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- \
    --mode destroy,format,mount "$DISKO_CONFIG_FILE"

sudo nixos-generate-config --root /mnt  # need for hardware-configuration.nix
sudo cp "$CONFIG_FILE" /mnt/etc/nixos/configuration.nix
sudo cp ~/nixos-config/dell-thunder.jpg /mnt/boot
sudo nixos-install

for i in {15..0}
do
  echo -ne "\rRebooting in ${i} seconds "
  sleep 1
done

reboot

# [EOF]
