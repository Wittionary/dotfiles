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
working_dir="%{$bg[blue]%}%(4~|../%2~|%~)"
priv_shell="%(!.✨.)"
exit_code="%(?.😀.😡)"
PS1="%B$logged_in_user $hostname $working_dir$priv_shell$exit_code%b%{$reset_color%} "

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


# FOLDER NAVIGATION -------------------------
setopt AUTO_CD # change to dir if just the path is entered w/o the "cd" command

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.

# vi mode
bindkey -v
export KEYTIMEOUT=1


# https://github.com/zsh-users/zsh-autosuggestions
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Load zsh-syntax-highlighting; should be last.
# https://github.com/zsh-users/zsh-syntax-highlighting
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null