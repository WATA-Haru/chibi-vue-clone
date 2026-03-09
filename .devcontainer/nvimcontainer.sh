#!/bin/bash

# Dotfiles configuration (temporary, hard-coded)
DOTFILES_REPO="https://github.com/WATA-Haru/dotfiles.git"
DOTFILES_INSTALL="install/devcontainers/ubuntu/install.sh"
DOTFILES_TARGET="/home/vscode/dotfiles"
dotfiles_args="--dotfiles-repository $DOTFILES_REPO \
  --dotfiles-install-command $DOTFILES_INSTALL \
  --dotfiles-target-path $DOTFILES_TARGET"


eval "devcontainer up  $dotfiles_args \
      --config .devcontainer/my-override/devcontainer.json \
      --workspace-folder ."
eval "devcontainer exec \
      --config .devcontainer/my-override/devcontainer.json \
      --remote-env REMOTE_CONTAINERS=true \
      --workspace-folder . bash"
