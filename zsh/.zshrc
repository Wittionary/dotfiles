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
# if last command exited 0 (success) then show happy face, else show mad/poo face
# End bolding text; reset fg and bg colors to default
logged_in_user="%{$bg[yellow]%}%{$fg[black]%}%n"
kube_context="%{$bg[yellow]%}%{$fg[black]%} $active_kube_context"

hostname="%{$bg[magenta]%}%{$fg[white]%}%M"
active_acct_display="%{$bg[magenta]%}%{$fg[white]%}☁️ $active_acct_az"

working_dir="%{$bg[blue]%}%(4~|../%2~|%~)"
priv_shell="%(!.✨.)"
exit_code="%(?.😀.💩)"
PS1="%B$kube_context$active_acct_display$working_dir$priv_shell$exit_code%b%{$reset_color%} "

left_boundary="%{$fg[red]%}(%{$reset_color%}"
time="%T"
bg_jobs="%(1j., %j."")"
right_boundary="%{$fg[red]%})%{$reset_color%}"
#RPS1="%K{$bg[black]%}$bg_jobs%k"
RPS1="%K{$bg[black]%}$left_boundary$time$bg_jobs$right_boundary%k "
#RPS2="%{$fg_bold[red]%}(%{$reset_color%}witt{$fg_bold[red]%})%f"
# cp dotfiles/zsh/.zshrc ~/.zshrc;source ~/.zshrc
# HISTORY -------------------------
HISTSIZE=1001
SAVEHIST=1001
HISTFILE=~/.cache/zsh/history # So that it's not living in ~/.history, this neatens up homedir

setopt INC_APPEND_HISTORY # each line is appended to the history as it is executed
setopt EXTENDED_HISTORY # makes the format of the history entry more complicated: "history -fdD" vs "history"
setopt HIST_IGNORE_DUPS HIST_EXPIRE_DUPS_FIRST # space savers and clarity makers
setopt INTERACTIVE_COMMENTS # don't process '#' in the terminal

# ALIASES ---------------------------
alias cls=clear
alias d=docker
alias tf=terraform
alias tg=terragrunt
#alias kc=kubectl
alias aws.whoami='aws iam get-user --query User.Arn --output text'
alias az.whoami='az ad signed-in-user show --query userPrincipalName --output tsv'
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# FUNCTIONS ---------------------------
g() { # git aliases/chords
    if [[ "$1" == "s" || "$1" == "" ]]; then
        git status -sb
    elif [[ "$1" == "b" ]]; then
        git branch --list
    elif [[ "$1" == "p" ]]; then
        git pull
    elif [[ "$1" == "can" ]]; then
        # Commit all now
        git add .
        CommitMessage = "Commit All @ $(date +%m-%d-%y) $(date +%H:%M:%S)"
        git commit -am $CommitMessage
    elif [[ "$1" == "ca" ]]; then
        git add .
        git commit -am $2
    elif [[ "$1" == "cu" ]]; then
        # Undo that last commit
        #echo "StackOverflow link is in clipboard"
        echo "https://stackoverflow.com/questions/927358/how-do-i-undo-the-most-recent-local-commits-in-git"
    elif [[ "$1" == "pp" ]]; then
        git push --progress
    fi
}
kc() { # kubectl but as a rainbow
    kubectl $@ | lolcat --freq=0.3
}

fsearch() { # Fuzzy search w/ file contents preview
    fzf --preview='batcat --style=numbers --color=always --line-range :500 {}' --preview-window=up:80% --height 100% --layout=default
}

get-aksconfig() {
    az aks get-credentials --resource-group $RANDOM_PET-rg --name $RANDOM_PET-aks --file kubeconfig --subscription 9ea62c4f-c45c-4e53-814e-96f6ad317ce6
    mv kubeconfig ~/.kube/config
    chmod 600 ~/.kube/config
}

whereami() { # determine which cloud provider and kubernetes' contexts I'm under and display
    # AZ CLI
    if [[ -z $(history | grep --perl-regexp '^\s{1,2}\d{1,4}\s{2}az\s.*') ]]; then 
        # az command has not run recently 
        active_acct_az=""
    else 
        active_acct_az=$(az account show -o tsv --query name | cut -c 1-13)
    fi

    # KUBECTL
    if [[ -z $(history | grep --perl-regexp '^\s{1,2}\d{1,4}\s{2}(sudo\s)?(kubectl|kc){1}\s.*$') ]]; then 
        # kubectl (or alias) has not run recently 
        active_kube_context=""
    else 
        active_kube_context=$(kubectl config current-context)
    fi
    
    source ~/.zshrc
}

settitle() { # Set terminal window/tab title with argument
    window_title=$(history -1 | cut -d ' ' -f 4-)
    echo -ne '\033]0;'"${window_title}"'\a'
}

# HOOKS ---------------------------
autoload -Uz add-zsh-hook
PERIOD=600
#add-zsh-hook periodic whereami # the source-ing lags up the terminal; frustrating
add-zsh-hook precmd settitle


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
elif [[ $(cat /etc/hostname) == "STARMACHINE" ]]; then
    # when on STARMACHINE
    GIT_PATH=/mnt/c/Users/qwert/Documents/git
elif [[ $(cat /etc/hostname) == "ubuntu-wsl" ]]; then
    # when on work laptop
    GIT_PATH=/mnt/c/Users/WittAllen/git
elif [[ $(cat /etc/hostname) == "hacktop" ]]; then
    # when on linux laptop
    GIT_PATH=/home/witt/git
elif [[ $(cat /etc/hostname) == "snowmachine" ]]; then
    # when on linux laptop
    GIT_PATH=/home/witt/git
fi

# STATIC VARIABLES -------------------------
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$GIT_PATH/add-thing


# vi mode
bindkey -v
export KEYTIMEOUT=1

# autosuggestion - accept next word
#bindkey '^[[1;5C' forward-word # Ctrl + Right


# https://github.com/zsh-users/zsh-autosuggestions
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# https://github.com/wting/autojump
source /usr/share/autojump/autojump.sh

# Load zsh-syntax-highlighting; should be last.
# https://github.com/zsh-users/zsh-syntax-highlighting
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
# add Pulumi to the PATH
export PATH=$PATH:$HOME/.pulumi/bin

# bun completions
[ -s "/home/witt/.bun/_bun" ] && source "/home/witt/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"