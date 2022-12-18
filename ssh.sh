#!/bin/sh
EMAIL=${1:-"medge@medgelabs.io"}
EXPECTED_FILE=$HOME/.ssh/id_ed25519

if [ -f "$EXPECTED_FILE" ]; then
  echo "SSH Key already present. Exiting.."
  exit 0
fi

# NOTE: `-q` silences the agent and `-N` sets an empty password
ssh-keygen -t ed25519 -C $EMAIL -f $EXPECTED_FILE -q -N "${SSH_PASS}"

# Ensure SSH agent is running
eval "$(ssh-agent -s)"

# Add key to ssh-agent
ssh-add "$EXPECTED_FILE"
