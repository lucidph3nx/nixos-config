#!/usr/bin/env bash

# Create a temporary directory
temp=$(mktemp -d)

# Function to cleanup temporary directory on exit
cleanup() {
  rm -rf "$temp"
}
trap cleanup EXIT

# Create the directory where sshd expects to find the host keys
install -d -m755 "$temp/etc/ssh"
install -d -m755 "$temp/persist/system/etc/ssh"

# Copy private and public keys from local machine
cp ~/.ssh/nix-ed25519 "$temp/etc/ssh/nix-ed25519"
cp ~/.ssh/nix-ed25519.pub "$temp/etc/ssh/nix-ed25519.pub"
cp ~/.ssh/nix-ed25519 "$temp/persist/system/etc/ssh/nix-ed25519"
cp ~/.ssh/nix-ed25519.pub "$temp/persist/system/etc/ssh/nix-ed25519.pub"

# Set the correct permissions so sshd will accept the key
chmod 600 "$temp/etc/ssh/nix-ed25519"
chmod 600 "$temp/etc/ssh/nix-ed25519.pub"
chmod 600 "$temp/persist/system/etc/ssh/nix-ed25519"
chmod 600 "$temp/persist/system/etc/ssh/nix-ed25519.pub"

# Install NixOS to the host system with our secrets
nix run github:nix-community/nixos-anywhere -- --extra-files "$temp" --flake '.#surface' nixos@10.93.149.61
