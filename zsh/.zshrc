# Resources:
# - https://zsh.sourceforge.io/Guide/
# Originally started with this config for the Zoomer Shell
# https://gist.github.com/LukeSmithxyz/e62f26e55ea8b0ed41a65912fbebbe52

# Gives me more colors on the prompt
zmodload zsh/nearcolor
# Enable colors and change prompt:
autoload -U colors && colors
# PS1 deciphered:
# Start bolding text; yellow bg; name of logged in user; magenta bg; hostname
# blue bg; display working directory unless it's 3 dirs deep in which case display the current dir and its parent
# if in privileged shell then show the star emoji, else show nothing
# if last command exited 0 (success) then show happy face, else show mad face
# End bolding text; reset fg and bg colors to default
PS1="%B%{$bg[yellow]%}%n %{$bg[magenta]%}%M %{$bg[blue]%}%(4~|../%2~|%~)%(!.✨.)%(?.😀.😡)%b%{$reset_color%} "
RPS1="%K{$bg[black]%}%{$fg[red]%}(%{$reset_color%}%T%(1j., %j."")%{$fg[red]%})%k%{$reset_color%}"
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


# Load zsh-syntax-highlighting; should be last.
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null