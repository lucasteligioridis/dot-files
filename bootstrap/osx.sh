#!/usr/bin/env bash

set -euo pipefail

echo "[brew] Installing brew from source..."
#curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
#
## Set the brew shellenv correctly before beginning
#eval "$(/opt/homebrew/bin/brew shellenv)"

echo "[brew] Installing regular brew packages..."
brew install \
  asdf \
  bash \
  bat \
  coreutils \
  fasd \
  fzf \
  git \
  gnupg \
  hashicorp/tap/terraform-ls \
  helm \
  htop \
  hub \
  k9s \
  kubectx \
  lsd \
  make \
  minikube \
  neovim \
  podman \
  ripgrep \
  shellcheck \
  tig \
  tmux \
  tree \
  wget \
  ykman

echo "[brew] Installing cask brew packages..."
brew install --cask \
  1password \
  discord \
  firefox \
  font-roboto-mono-nerd-font \
  kitty \
  launchbar \
  logitech-g-hub \
  signal \
  slack \
  zoom

plugins=(
  "gcloud https://github.com/jthegedus/asdf-gcloud"
  "nodejs https://github.com/asdf-vm/asdf-nodejs.git"
  "ruby https://github.com/asdf-vm/asdf-ruby.git"
  "python https://github.com/danhper/asdf-python.git"
  "rust https://github.com/code-lever/asdf-rust.git"
  "terraform https://github.com/Banno/asdf-hashicorp.git"
  "terraform-lsp https://github.com/bartlomiejdanek/asdf-terraform-lsp.git"
)

echo "[asdf] Loading asdf..."
echo source "$(brew --prefix asdf)/libexec/asdf.sh"

echo "[asdf] Adding asdf plugins..."
for plugin in "${plugins[@]}"; do
  echo "[asdf] Adding ${plugin}..."
  echo asdf plugin add "${plugin}"
done

echo "[asdf] Installing asdf plugins from ..."
for plugin in $(asdf plugin list); do
  echo "[asdf] Installing ${plugin}..."
  echo "asdf install ${plugin}"
done
