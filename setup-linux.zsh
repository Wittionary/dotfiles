#!/bin/zsh


# Test if git repo env var is set
# If not, set it
if [[ -v $GIT_PATH ]]; then
    echo '$GIT_PATH is set'
else 
    echo 'Enter a value for $GIT_PATH : '
    read path
    export GIT_PATH=$path
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
    if [[ -f ~/.zshrc ]]; then
        /usr/bin/rm ~/.zshrc
    # If it's already a symlink, notify user and continue
    elif [[ -h ~/.zshrc ]]; then
        echo "~/.zshrc is already symlinked"
    else
        ln -s $GIT_PATH/dotfiles/zsh/.zshrc ~/.zshrc
        echo "~/.zshrc is now a symlink"
    fi

    # .zshenv
    if [[ -f ~/.zshenv ]]; then
        /usr/bin/rm ~/.zshenv
    elif [[ -h ~/.zshenv ]]; then
        echo "~/.zshenv is already symlinked"
    else
        ln -s $GIT_PATH/dotfiles/zsh/.zshenv ~/.zshenv
        echo "~/.zshenv is now a symlink"
    fi

    # VIM ---------------------------------------------------------
    # .vimrc
    if [[ -f ~/.vimrc ]]; then
        /usr/bin/rm ~/.vimrc
    elif [[ -h ~/.vimrc ]]; then
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
    if [[ -f ~/.vim/colors/codedark.vim ]]; then
        /usr/bin/rm ~/.vim/colors/codedark.vim
    elif [[ -h ~/.vim/colors/codedark.vim ]]; then
        echo "~/.vim/colors/codedark.vim is already symlinked"
    else
        ln -s $GIT_PATH/dotfiles/vim/colors/codedark.vim ~/.vim/colors/codedark.vim
        echo "~/.vim/colors/codedark.vim is now a symlink"
    fi
fi