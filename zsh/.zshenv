if [[ $(cat /etc/hostname) -eq "Monolith" ]]; then
    # when on Monolith
    GIT_PATH=/mnt/c/Users/Witt/Documents/GitHub
elif [[ $(cat /etc/hostname) -eq "WAllen-LT2" ]]; then
    # when on work laptop
    GIT_PATH=/mnt/c/Users/WittAllen/git
fi

FZF_DEFAULT_OPTS='--height 25% --layout=reverse'
