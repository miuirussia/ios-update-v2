#!/bin/sh -e

apk --no-cache --no-progress upgrade
apk --no-cache --no-progress add \
  bash \
  curl \
  xz \
  sudo

mkdir /etc/nix
printf "build-users-group =\n" > /etc/nix/nix.conf
mkdir /root/.nixpkgs
printf "{ allowUnfree = true; }\n" > /root/.nixpkgs/config.nix

curl -L https://nixos.org/nix/install | sh

export NIX_PATH=nixpkgs=/root/.nix-defexpr/channels/nixpkgs
export PATH=/root/.nix-profile/bin:/root/.nix-profile/sbin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

nix-env -iA nixpkgs.cacert

nix-channel --add https://github.com/miuirussia/nixpkgs/archive/nixpkgs-unstable.tar.gz nixpkgs
nix-channel --update

nix-collect-garbage -d
rm /tmp/bootstrap.sh
