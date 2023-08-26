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

if [ -f "/usr/local/opt/asdf/libexec/asdf.sh" ] && [ -f "$HOME/.asdf/.enabled" ]; then
  . /usr/local/opt/asdf/libexec/asdf.sh
fi

# Aliases
if command -v nvim &> /dev/null; then
  alias vim='nvim'
fi

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

alias wakepcadam='wakeonlan B4:2E:99:36:96:0B'
alias wakepclauren='wakeonlan B4:2E:99:D1:85:3E'

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

# AWS Commands
function aws-use-profile() {
  export AWS_PROFILE=$(cat ~/.aws/config | grep '\[profile' | cut -d ' ' -f 2 | cut -d ']' -f 1 | fzf)
}

alias aws-ssm-to="aws ssm start-session --target"

function aws-ssm-upload-public-key() {
  instance_id=$1
  public_key=$(cat ~/.ssh/id_ed25519.pub | tr -d '\n')

  aws ssm send-command \
    --document-name "AWS-RunShellScript" \
    --parameters 'commands=["mkdir -p /home/ssm-user/.ssh", "echo \"'${public_key}'\" > /home/ssm-user/.ssh/authorized_keys", "chown ssm-user:ssm-user /home/ssm-user/.ssh/authorized_keys"]' \
    --targets "Key=instanceids,Values=$instance_id" \
    --comment "upload public key"
}

# adamctl commands
function fix() {
  if [ "${ADAMCTL_FIX}" = "" ]; then
    echo "No ADAMCTL_FIX defined"
    return 1
  else
    sh -c "${ADAMCTL_FIX}"
  fi
}

function tst() {
  if [ "${ADAMCTL_TST}" = "" ]; then
    echo "No ADAMCTL_TST defined"
    return 1
  else
    sh -c "${ADAMCTL_TST}"
  fi
}

function bld() {
  if [ "${ADAMCTL_BLD}" = "" ]; then
    echo "No ADAMCTL_BLD defined"
    return 1
  else
    sh -c "${ADAMCTL_BLD}"
  fi
}

function run() {
  if [ "${ADAMCTL_RUN}" = "" ]; then
    echo "No ADAMCTL_RUN defined"
    return 1
  else
    sh -c "${ADAMCTL_RUN}"
  fi
}

# Go setup
if type go > /dev/null; then
  export GOPATH=$(go env GOPATH)
  export PATH=$PATH:"$GOPATH/bin"
fi

# Load Gusto env
[ -f "$HOME/.gusto/init.sh" ] && source "$HOME/.gusto/init.sh"

export PATH="/usr/local/sbin:$PATH"

# temp: delegate NVM activation to direnv via `use nvm`
#if [[ "x${NVM_DIR}" == "x" ]]; then
#  export NVM_DIR="$HOME/.nvm"
#  [ -s "$(brew --prefix)/opt/nvm/nvm.sh" ] && \. "$(brew --prefix)/opt/nvm/nvm.sh"  # This loads nvm
#  [ -s "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
#fi

# /opt/homebrew/opt/fzf/install or brew info fzf to install this
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
