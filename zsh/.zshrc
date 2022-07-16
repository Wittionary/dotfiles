# Resources:
# - https://zsh.sourceforge.io/Guide/
# Originally started with this config for the Zoomer Shell
# https://gist.github.com/LukeSmithxyz/e62f26e55ea8b0ed41a65912fbebbe52

# Enable colors and change prompt:
zmodload zsh/nearcolor
autoload -U colors && colors
# PS1 deciphered:
# Start bolding text; yellow bg; name of logged in user; magenta bg; hostname
# blue bg; display working directory unless it's 3 dirs deep in which case display the current dir and its parent
# if in privileged shell then show the star emoji, else show nothing
# if last command exited 0 (success) then show happy face, else show mad face
# End bolding text; reset fg and bg colors to default
logged_in_user="%{$bg[yellow]%}%{$fg[black]%}%n"
hostname="%{$bg[magenta]%}%{$fg[white]%}%M"
#active_acct_az=""
working_dir="%{$bg[blue]%}%(4~|../%2~|%~)"
priv_shell="%(!.✨.)"
exit_code="%(?.😀.😡)"
PS1="%B$logged_in_user $active_acct_az $working_dir$priv_shell$exit_code%b%{$reset_color%} "

left_boundary="%{$fg[red]%}(%{$reset_color%}"
time="%T"
bg_jobs="%(1j., %j."")"
right_boundary="%{$fg[red]%})%{$reset_color%}"
RPS1="%K{$bg[black]%}$left_boundary$time$bg_jobs$right_boundary%k"
#RPS2="%{$fg_bold[red]%}(%{$reset_color%}witt{$fg_bold[red]%})%f"
# cp dotfiles/zsh/.zshrc ~/.zshrc;source ~/.zshrc
# HISTORY -------------------------
HISTSIZE=1001
SAVEHIST=1001
HISTFILE=~/.cache/zsh/history # So that it's not living in ~/.history, this neatens up homedir

setopt INC_APPEND_HISTORY # each line is appended to the history as it is executed
setopt EXTENDED_HISTORY # makes the format of the history entry more complicated: "history -fdD" vs "history"
setopt HIST_IGNORE_DUPS HIST_EXPIRE_DUPS_FIRST # space savers and clarity makers

# ALIASES ---------------------------
alias cls=clear
alias tf=terraform
alias tg=terragrunt
alias kc=kubectl

# FUNCTIONS ---------------------------
fsearch() { # Fuzzy search w/ file contents preview
    fzf --preview='batcat --style=numbers --color=always --line-range :500 {}' --preview-window=up:80% --height 100% --layout=default
}

get-aksconfig() {
    az aks get-credentials --resource-group $RANDOM_PET-rg --name $RANDOM_PET-aks --file kubeconfig --subscription 9ea62c4f-c45c-4e53-814e-96f6ad317ce6
    mv kubeconfig ~/.kube/config
    chmod 600 ~/.kube/config
}

whereami() { # determine which cloud provider and kubernetes' contexts I'm under and display
    if [[ -z $(history | grep --perl-regexp '^\s{2}\d{1,4}\s{2}az\s.*') ]]; then 
        # az command has not run recently 
        echo "az command has not run recently"
    else 
        active_acct_az=active-acct-az
        echo $active_acct_az
        source ~/.zshrc
    fi
}

active-acct-az() {
    az account show -o tsv --query name | cut -c 1-13
    echo "endd"
}


# FOLDER NAVIGATION -------------------------


# TAB COMPLETION -------------------------
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.
source <(kubectl completion zsh) # kubectl completion

# DYNAMIC VARIABLES -------------------------
if [[ $(cat /etc/hostname) == "Monolith" ]]; then
    # when on Monolith
    GIT_PATH=/mnt/c/Users/Witt/Documents/GitHub
elif [[ $(cat /etc/hostname) == "ubuntu-wsl" ]]; then
    # when on work laptop
    GIT_PATH=/mnt/c/Users/WittAllen/git
fi



# vi mode
bindkey -v
export KEYTIMEOUT=1


# https://github.com/zsh-users/zsh-autosuggestions
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Load zsh-syntax-highlighting; should be last.
# https://github.com/zsh-users/zsh-syntax-highlighting
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null