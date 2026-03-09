containerID=$(devcontainer up "${dotfiles_args[@]}" --additional-features='{"ghcr.io/devcontainers/features/sshd:1": {}}' --workspace-folder . | tail -n1 | jq -r .containerId)

devcontainer exec --container-id "$containerID" bash -c 'chmod 700 /home/vscode/.ssh'

TERM="xterm-256color" ssh -t -i ~/.ssh/id_ed25519 -o NoHostAuthenticationForLocalhost=yes -o UserKnownHostsFile=/dev/null -o GlobalKnownHostsFile=/dev/null -p 2222 vscode@localhost
