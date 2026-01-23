#!/bin/sh

# Git config
git config --global user.name "Medge"
git config --global user.email "medge@medgelabs.io"
git config --global core.pager 'cat'
git config --global init.defaultBranch main
git config --global pull.rebase true
git config --global push.autoSetupRemote true
git config --global branch.sort -committerdate
git config --global tag.sort version:refname

# Keep local context clean of server-deleted branches
git config --global fetch.prune true
git config --global fetch.pruneTags true
git config --global fetch.all true

# TODO needs more reps but does make rebasing a bit
# quicker
git config --global rebase.autoSquash true
git config --global rebase.autoStash true
git config --global rebase.updateRefs true

# Prefer diff prefixes i/, w/, c/, etc
git config --global diff.mnemonicPrefix true

# TODO: eval patience version
git config --global diff.algorithm histogram
# Color moved vs. changed more clearly
git config --global diff.colorMoved plain

cp .gitignore_global $HOME/.gitignore_global
git config --global core.excludesfile $HOME/.gitignore_global
