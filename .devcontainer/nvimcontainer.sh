#!/bin/bash

rebuild_flag=""
if [[ "$1" == "-r" || "$1" == "--rebuild" ]]; then
  rebuild_flag="--remove-existing-container"
fi

# Dotfiles configuration (temporary, hard-coded)
DOTFILES_REPO="https://github.com/WATA-Haru/dotfiles.git"
DOTFILES_INSTALL="install/devcontainers/ubuntu/install.sh"
DOTFILES_TARGET="/home/vscode/dotfiles"
dotfiles_args="--dotfiles-repository $DOTFILES_REPO \
  --dotfiles-install-command $DOTFILES_INSTALL \
  --dotfiles-target-path $DOTFILES_TARGET"

# Get the Neovim config path using headless nvim
config_path=$(nvim --headless -c 'lua io.stdout:write(vim.fn.stdpath("config"))' -c 'q' --clean)

# Resolve symlink for the config path
resolved_config_path=$(readlink -f "$config_path")

# Construct the command to run the devcontainer
#    --additional-features='{ \
#        \"ghcr.io/duduribeiro/devcontainer-features/neovim:1\": { \"version\": \"stable\" }, \
#    }' \
command="devcontainer up $rebuild_flag \
    $dotfiles_args \
    --mount type=bind,source=$resolved_config_path,target=/home/vscode/.config/nvim \
    --workspace-folder ."

eval "$command"
eval "devcontainer exec \
      --remote-env REMOTE_CONTAINERS=true \
      --workspace-folder . bash"
