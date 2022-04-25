#!/bin/sh

# Test if git repo env var is set
# If not, set it

# Test if .zshrc .vimrc etc files exist
# If yes, delete and create symlink to dotfiles repo dotfile
# If it's already a symlink, notify user and continue