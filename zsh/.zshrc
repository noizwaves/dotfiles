typeset -U path cdpath fpath manpath


# TODO: from nix
#HELPDIR="/nix/store/s613jv7crzygmj38745a8jnjrlacyh2a-zsh-5.9/share/zsh/$ZSH_VERSION/help"

# TODO: required?
# Oh-My-Zsh/Prezto calls compinit during initialization,
# calling it twice causes slight start up slowdown
# as all $fpath entries will be traversed again.
autoload -U compinit && compinit

##
## Plugins via Antigen
##
for sp in /usr/local/share /opt/homebrew/share; do
  ap="$sp/antigen/antigen.zsh"
  if [ -f $ap ]; then
    source $ap
    antigen bundle zsh-users/zsh-autosuggestions
    antigen apply
    break
  fi
done

# History
HISTSIZE="10000"
SAVEHIST="10000"

HISTFILE="$HOME/.zsh_history"
mkdir -p "$(dirname "$HISTFILE")"

setopt HIST_FCNTL_LOCK
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
unsetopt HIST_EXPIRE_DUPS_FIRST
setopt SHARE_HISTORY
unsetopt EXTENDED_HISTORY

# play nicely with tmux workflow
bindkey -s '^f' "tmux-sessionizer\n"

# fix option+arrow word moving in iterm
bindkey "\e\e[D" backward-word # ⌥←
bindkey "\e\e[C" forward-word # ⌥→
# and edge case when tmux running in ubuntu
bindkey "\e\eOD" backward-word # ⌥←
bindkey "\e\eOC" forward-word # ⌥←

# execute any local overrides if present
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"

# execute any aliases files if present
[ -f "$HOME/.aliases" ] && source "$HOME/.aliases"

# load custom commands
[ -f "$HOME/.commands" ] && source "$HOME/.commands"

if type starship > /dev/null && [[ $TERM != "dumb" && (-z $INSIDE_EMACS || $INSIDE_EMACS == "vterm") ]]; then
  eval "$(starship init zsh)"
fi

if type direnv > /dev/null; then
  eval "$(direnv hook zsh)"
fi

# Aliases
alias vim='nvim'

alias ga='git add -p'
alias gc='git commit'
alias gca='git commit --amend'
alias gcan='git commit --amend --no-edit'
alias gcm='git commit -m'
alias gp='git pull'
alias gs='git status'

alias k='kubectl'

alias d='devspace'
alias dv='devspace dev'
alias ds='devspace run shell'

alias tks='tmux kill-server'

# Commands
function git-delete-branches() {
  git branch --sort committerdate |
    grep --invert-match '\*' |
    cut -c 3- |
    fzf --multi --no-sort --preview="git log -n 3 {} --" |
    xargs git branch --delete --force
}

function git-use-branch() {
  git checkout $(git branch --list | grep --invert-match '\*' | fzf)
}


function git-optimize() {
  git remote prune origin
  # git repack -A -d -f
  git gc --prune=now --aggressive
}

# Load Gusto env
source ~/.gusto/init.sh
