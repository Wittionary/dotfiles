# Resource: https://zsh.sourceforge.io/Guide/
# Originally started with Luke's config for the Zoomer Shell
# https://gist.github.com/LukeSmithxyz/e62f26e55ea8b0ed41a65912fbebbe52


# Gives me more colors on the prompt
zmodload zsh/nearcolor
# Enable colors and change prompt:
autoload -U colors && colors
#PS1="%F%{$fg[white]%}%B%K%{$bg[yellow]%}%n %{$bg[magenta]%}%M %{$bg[blue]%}%(4~|../%2~|%~)%{$reset_color%}%(0#."STAR"."")%b "
PS1="%B%{$bg[yellow]%}%n %{$bg[magenta]%}%M %{$bg[blue]%}%(4~|../%2~|%~)%(!.✨.)%(?.😀.😡)%b%{$reset_color%} "
# TODO: swap with sad face if prev cmd returns non-zero: "$?" or %? in prompt
RPS1="%K{$bg[black]%}%{$fg[red]%}(%{$reset_color%}%T%(1j., %j."")%{$fg[red]%})%k%{$reset_color%}"
#RPS2="%{$fg[red]%}(%{$reset_color%}witt{$fg[red]%})%f"
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