#!/usr/bin/bash
set -e


# Test if git repo env var is set
# If not, set it
if [[ -v GIT_PATH || -n $GIT_PATH ]]; then
    echo '$GIT_PATH is set'
else 
    echo 'Enter a value for $GIT_PATH : '
    read input
    export GIT_PATH=$input
    echo "\$GIT_PATH is now $GIT_PATH"
fi

# Only continue if dotfiles repo is present
if [[ -d "$GIT_PATH/dotfiles" ]]; then
    repo_exists=true
    echo "dotfiles found"
else
    echo "dotfiles not found. Exiting."
    exit 1
fi

if [ "$repo_exists" = true ]; then
    # ZSH ---------------------------------------------------------
    # .zshrc
    # If a file, delete and create symlink to dotfiles repo dotfile
    if [[ -f ~/.zshrc && ! ( -L ~/.zshrc ) ]]; then
        rm -v ~/.zshrc
    # If it's already a symlink, notify user and continue
    elif [[ -L ~/.zshrc ]]; then
        echo "~/.zshrc is already symlinked"
    else
        ln -s -v $GIT_PATH/dotfiles/zsh/.zshrc ~/.zshrc && echo "~/.zshrc is now a symlink"
    fi

    # .zshenv
    if [[ -f ~/.zshenv && !( -L ~/.zshenv) ]]; then
        rm -v ~/.zshenv
    elif [[ -L ~/.zshenv ]]; then
        echo "~/.zshenv is already symlinked"
    else
        ln -s $GIT_PATH/dotfiles/zsh/.zshenv ~/.zshenv && echo "~/.zshenv is now a symlink"
    fi

    # VIM ---------------------------------------------------------
    # .vimrc
    if [[ -f ~/.vimrc && ! ( -L ~/.vimrc ) ]]; then
        rm -v ~/.vimrc
    elif [[ -L ~/.vimrc ]]; then
        echo "~/.vimrc is already symlinked"
    else
        ln -s -v $GIT_PATH/dotfiles/vim/.vimrc ~/.vimrc && echo "~/.vimrc is now a symlink"
    fi

    # vim theme
    if [[ ! -d ~/.vim/colors ]]; then
        mkdir -p ~/.vim/colors && echo "~/.vim/colors directory made"
    fi
    if [[ -f ~/.vim/colors/codedark.vim && ! ( -L ~/.vim/colors/codedark.vim ) ]]; then
        rm -v ~/.vim/colors/codedark.vim
    elif [[ -L ~/.vim/colors/codedark.vim ]]; then
        echo "~/.vim/colors/codedark.vim is already symlinked"
    else
        ln -s -v $GIT_PATH/dotfiles/vim/colors/codedark.vim ~/.vim/colors/codedark.vim && echo "~/.vim/colors/codedark.vim is now a symlink"
    fi

    # WSL ---------------------------------------------------------
    # TODO: DRY this up
    # wsl.conf
    # if file exists and isn't a symlink
    if [[ -f /etc/wsl.conf && ! ( -L /etc/wsl.conf ) ]]; then
        sudo rm -v /etc/wsl.conf
    elif [[ -L /etc/wsl.conf ]]; then
        echo "/etc/wsl.conf is already symlinked"
    else
        ln -s -v $GIT_PATH/dotfiles/wsl/ubuntu-wsl.conf /etc/wsl.conf && echo "/etc/wsl.conf is now a symlink"
    fi

    # resolv.conf
    if [[ -f /etc/resolv.conf && ! ( -L /etc/resolv.conf ) ]]; then
        sudo rm -v /etc/resolv.conf
    elif [[ -L /etc/resolv.conf ]]; then
        echo "/etc/resolv.conf is already symlinked"
    else
        sudo ln -s -v $GIT_PATH/dotfiles/wsl/resolv.conf /etc/resolv.conf && echo "/etc/resolv.conf is now a symlink"
    fi

    # change the default shell to zsh
    DESIRED_SHELL=zsh
    if [[ $(cat /etc/shells | grep "$DESIRED_SHELL") ]]; then
        chsh -s $(which $DESIRED_SHELL) witt
        echo "Shell changed to $(which $DESIRED_SHELL)"
    else
        echo "$DESIRED_SHELL not found in /etc/shells"
    fi
fi