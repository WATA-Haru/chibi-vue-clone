#!/bin/bash

# Dotfiles configuration (temporary, hard-coded)
DOTFILES_REPO="https://github.com/WATA-Haru/dotfiles.git"
DOTFILES_INSTALL="install/devcontainers/ubuntu/install.sh"
DOTFILES_TARGET="/home/vscode/dotfiles"
dotfiles_args=(
  --dotfiles-repository "$DOTFILES_REPO"
  --dotfiles-install-command "$DOTFILES_INSTALL"
  --dotfiles-target-path "$DOTFILES_TARGET"
)

# ==== success ===
containerID=$(devcontainer up "${dotfiles_args[@]}" --additional-features='{"ghcr.io/devcontainers/features/sshd:1": {}}' --workspace-folder . | tail -n1 | jq -r .containerId)

# sshのときだと以下は意味ない
# devcontainer exec --remote-env REMOTE_CONTAINERS=true
docker exec -u vscode $containerID bash -c 'mkdir -p /home/vscode/.ssh'
docker cp ~/.ssh/id_ed25519.pub $containerID:/home/vscode/.ssh/authorized_keys
devcontainer exec --container-id "$containerID" bash -c 'chmod 644 /home/vscode/.ssh/authorized_keys'
devcontainer exec --container-id "$containerID" bash -c 'chmod 700 /home/vscode/.ssh'

# ssh でコンテナに接続する
TERM="xterm-256color" ssh -t -i ~/.ssh/id_ed25519 -o NoHostAuthenticationForLocalhost=yes -o UserKnownHostsFile=/dev/null -o GlobalKnownHostsFile=/dev/null -p 2222 vscode@localhost
# コンテナ内で GitHub に接続できるか確認
# ssh -T git@github.com
