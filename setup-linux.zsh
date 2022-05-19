#!/bin/zsh


# Test if git repo env var is set
# If not, set it
if [[ ! -z $GIT_PATH ]]; then
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
    if [[ -f ~/.zshrc && !( -L ~/.zshrc) ]]; then
        rm ~/.zshrc
    # If it's already a symlink, notify user and continue
    elif [[ -L ~/.zshrc ]]; then
        echo "~/.zshrc is already symlinked"
    else
        ln -s $GIT_PATH/dotfiles/zsh/.zshrc ~/.zshrc
        echo "~/.zshrc is now a symlink"
    fi

    # .zshenv
    if [[ -f ~/.zshenv && !( -L ~/.zshenv) ]]; then
        rm ~/.zshenv
    elif [[ -L ~/.zshenv ]]; then
        echo "~/.zshenv is already symlinked"
    else
        ln -s $GIT_PATH/dotfiles/zsh/.zshenv ~/.zshenv
        echo "~/.zshenv is now a symlink"
    fi

    # VIM ---------------------------------------------------------
    # .vimrc
    if [[ -f ~/.vimrc && !( -L ~/.vimrc) ]]; then
        rm ~/.vimrc
    elif [[ -L ~/.vimrc ]]; then
        echo "~/.vimrc is already symlinked"
    else
        ln -s $GIT_PATH/dotfiles/vim/.vimrc ~/.vimrc
        echo "~/.vimrc is now a symlink"
    fi

    # vim theme
    if [[ ! -d ~/.vim/colors ]]; then
        mkdir ~/.vim/colors
        echo "~/.vim/colors directory made"
    fi
    if [[ -f ~/.vim/colors/codedark.vim && !( -L ~/.vim/colors/codedark.vim) ]]; then
        rm ~/.vim/colors/codedark.vim
    elif [[ -L ~/.vim/colors/codedark.vim ]]; then
        echo "~/.vim/colors/codedark.vim is already symlinked"
    else
        ln -s $GIT_PATH/dotfiles/vim/colors/codedark.vim ~/.vim/colors/codedark.vim
        echo "~/.vim/colors/codedark.vim is now a symlink"
    fi
fi