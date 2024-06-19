# https://stevenvanbael.com/profiling-zsh-startup
#zmodload zsh/zprof

typeset -U path cdpath fpath manpath

# Load homebrew early, kubectl for autocompletion
if [ -f ~/.gusto/init.sh ]; then
  # Load Gusto env
  source ~/.gusto/init.sh
else
  [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
fi

autoload -U compinit && compinit

##
## Plugins via Antigen
## run `antigen-reset` after changing
#export ANTIGEN_CACHE=false
for sp in /usr/local/share/antigen /opt/homebrew/share/antigen /usr/share/zsh-antigen; do
  ap="$sp/antigen.zsh"
  if [ -f $ap ]; then
    source $ap
    antigen bundle zsh-users/zsh-autosuggestions
#    antigen bundle kubectl
    antigen apply
    break
  fi
done

[[ $commands[kubectl] ]] && source <(kubectl completion zsh)

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

alias d='devspace'
alias dv='devspace dev'
alias ds='devspace run shell'

alias tks='tmux kill-server'

alias paths="echo \$PATH | tr : '\n'"

alias wakepcadam='wakeonlan B4:2E:99:36:96:0B'
alias wakepclauren='wakeonlan B4:2E:99:D1:85:3E'

# shell commands
function reload() {
  exec zsh
}

# git commands
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
alias aup="aws-use-profile"

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

function aws-sso-expiration() {
  local profile=$1

  local SHA=$(aws configure get sso_start_url --profile $profile | tr -d '\n' | sha1sum | cut -d' ' -f 1)

  local EXPIRES_AT=$(cat ~/.aws/sso/cache/${SHA}.json | jq -r .expiresAt)

  local EXP=$(TZ="UTC" date -j -f "%Y-%m-%dT%H:%M:%SZ" "+%s" "$EXPIRES_AT")

  local DIFF=$(( $EXP - $(TZ=UTC date "+%s") ))
  local DIFF_HOURS=$(echo "scale=2; $DIFF / 3600" | bc)

  echo "$DIFF seconds until expiry"
  echo "$DIFF_HOURS hours until expiry"
}

# kubectl commands
alias k='kubectl'

function kubectl-use-context() {
  KUBE_CONTEXT=$(kubectl config get-contexts -o 'name' | fzf)
  kubectl config use-context "${KUBE_CONTEXT}"
}
alias kuc="kubectl-use-context"

alias kgc="kubectl config get-contexts -o name"

# temp: delegate goenv setup to direnv via `use goenv`
#if type goenv > /dev/null; then
#  eval "$(goenv init -)"
#fi

# Go commands
function goenv-init() {
  if [ ! -f .go-version ]; then
    echo "1.21.5" > .go-version
  fi

  if [ ! -f .envrc ] || ! grep "use goenv" .envrc > /dev/null; then
    echo "use goenv" >> .envrc
  fi

  direnv allow
  # direnv reload
}

function go-scratch() {
  DIR=$(mktemp -d -t go_scratch)
  (cd $DIR && goenv-init)

  cd $DIR
  go mod init github.com/noizwaves/go-scratch
  cat << EOF > main.go
package main

import "fmt"

func main() {
  fmt.Println("Hello, world!")
}
EOF
  code --new-window --goto main.go:6:31 .

  echo "go-scratch in $(pwd)"
}

# Rust commands
function rust-scratch() {
  DIR=$(mktemp -d -t rust_scratch)
  cd $DIR
  cargo init --bin --name rust_scratch .

  code --new-window --goto src/main.rs:2:31 .

  echo "rust-scratch in $(pwd)"
}

# misc commands
function jwt-decode() {
  sed 's/\./\n/g' <<< $(cut -d. -f1,2 <<< $1) | base64 --decode | jq
}

export PATH="/usr/local/sbin:$PATH"

# temp: delegate NVM activation to direnv via `use nvm`
#if [[ "x${NVM_DIR}" == "x" ]]; then
#  export NVM_DIR="$HOME/.nvm"
#  [ -s "$(brew --prefix)/opt/nvm/nvm.sh" ] && \. "$(brew --prefix)/opt/nvm/nvm.sh"  # This loads nvm
#  [ -s "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
#fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

#zprof

