# My NixOS Config

## Install from ISO

1. First connect to wifi:

Easy enough in an ISO with a GUI, but here's how to do it with `nmcli`:
```sh
nmcli radio wifi on  # might not be necessary, but may as well
sudo nmcli dev wifi connect -a <your-network-ssid-here>
```

2. Then
```sh
git clone https://github.com/eric-mckinney/nixos-config.git ~/nixos-config
bash ~/nixos-config/install.sh
```
