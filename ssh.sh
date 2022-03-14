#!/bin/sh
EMAIL=${1:-"medge@medgelabs.io"}

if [ ! -z "$HOME/.ssh/id_rsa" ]; then
  echo "SSH Key already present. Exiting.."
  exit 0
fi

# NOTE: `-q` silences the agent and `-N` sets an empty password
ssh-keygen -t rsa -b 4096 -C $EMAIL -f $HOME/.ssh/id_rsa -q -N "${SSH_PASS}"

# Ensure SSH agent is running
eval "$(ssh-agent -s)"

# Add key to
ssh-add "$HOME/.ssh/id_rsa"
