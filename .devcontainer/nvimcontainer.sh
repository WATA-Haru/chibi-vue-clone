#!/bin/bash

rebuild_flag=""
if [[ "$1" == "-r" || "$1" == "--rebuild" ]]; then
  rebuild_flag="--remove-existing-container"
fi

# Get the Neovim config path using headless nvim
config_path=$(nvim --headless -c 'lua io.stdout:write(vim.fn.stdpath("config"))' -c 'q' --clean)

# Resolve symlink for the config path
resolved_config_path=$(readlink -f "$config_path")

# dotfile config
dotfiles-repository="https://github.com/WATA-Haru/dotfiles.git"
dotfiles-target-path="~/dotfiles"
dotfiles-install-command="~/dotfiles/install.sh"

# Construct the command to run the devcontainer
command="devcontainer up $rebuild_flag \
    --mount type=bind,source=$resolved_config_path,target=/home/code/.config/container-nvim \
    --additional-features='{ \
        \"ghcr.io/duduribeiro/devcontainer-features/neovim:1\": { \"version\": \"stable\" }, \
    }' \
    --dotfiles-repository=$dotfiles-repository \
    --dotfiles-target-path=$dotfiles-target-path \
    --dotfiles-install-command=$dotfiles-install-command \
    --workspace-folder ."

eval "$command"
eval "devcontainer exec --remote-env NVIM_APPNAME=container-nvim --workspace-folder . nvim"
