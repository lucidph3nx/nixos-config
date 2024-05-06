#!bash
echo "on which disk am I setting up nixos?"
read diskname
let device="/dev/${diskname}"

sudo nix --experimental-features "nix-command flakes" \
    run github:nix-community/disko -- \
    --mode disko ./disko.nix
    --arg device $device

sudo nixos-generate-config --no-filesystems --root /mnt

cp ./configuration.nix /mnt/etc/nixos/configuration.nix

sudo nixos-rebuild boot
