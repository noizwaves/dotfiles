# https://stevenvanbael.com/profiling-zsh-startup
#zmodload zsh/zprof

typeset -U path cdpath fpath manpath

# Load homebrew early, kubectl for autocompletion
if [ -f ~/.gusto/init.sh ]; then
  # Load Gusto env
  source ~/.gusto/init.sh
else
  # specify shell because $SHELL shenanigans on cachyos
  command -v mise >/dev/null && eval "$(mise activate --shell zsh)"
fi

autoload -U compinit && compinit

##
## Plugins via Antigen
## run `antigen-reset` after changing
#export ANTIGEN_CACHE=false
for sp in /usr/local/share/antigen /opt/homebrew/share/antigen /usr/share/zsh-antigen /usr/share/zsh/share; do
  ap="$sp/antigen.zsh"
  if [ -f $ap ]; then
    source $ap
    antigen bundle zsh-users/zsh-autosuggestions
    #antigen bundle kubectl

    # This seems to take priority over regular activation, but only over SSH
    #antigen bundle atuinsh/atuin@main
    antigen apply
    break
  fi
done

[[ $commands[kubectl] ]] && source <(kubectl completion zsh)

# History
HISTSIZE="100000"
SAVEHIST="100000"

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

if type atuin >/dev/null; then
  # Add `--disable-up-arrow` to disable up arrow integration
  eval "$(atuin init zsh --disable-up-arrow)"
fi

if type starship > /dev/null && [[ $TERM != "dumb" && (-z $INSIDE_EMACS || $INSIDE_EMACS == "vterm") ]]; then
  eval "$(starship init zsh)"
else
  echo "warning: starship not installed"
fi

if type direnv > /dev/null; then
  eval "$(direnv hook zsh)"
else
  echo "warning: direnv not installed"
fi

if type grab > /dev/null; then
  eval "$(grab completion zsh)"
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
alias glp=git-log-pretty
alias gub='git-use-branch'
alias gdp='gdev pull'

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

# from https://github.com/mrnugget/dotfiles/blob/c4624ed521d539856bcf764f04a295bb19093566/githelpers#L11-L15
# from https://registerspill.thorstenball.com/p/how-i-use-git
function git-log-pretty() {
  HASH="%C(always,yellow)%h%C(always,reset)"
  RELATIVE_TIME="%C(always,green)%ar%C(always,reset)"
  AUTHOR="%C(always,bold blue)%an%C(always,reset)"
  REFS="%C(always,red)%d%C(always,reset)"
  SUBJECT="%s"

  FORMAT="$HASH $RELATIVE_TIME $AUTHOR $REFS $SUBJECT"

  git log --graph --pretty="tformat:$FORMAT" $*
}

# AWS Commands
function aws-use-profile() {
  export AWS_PROFILE=$(cat ~/.aws/config | grep '\[profile' | cut -d ' ' -f 2 | cut -d ']' -f 1 | fzf)
}
alias aup="aws-use-profile"

function aws-ssm-to() {
  local instance_id=$1
  aws ssm start-session --target $instance_id
}

function aws-ssm-to-asg {
    local asg;
    asg="${1:-buildkite_dev_adam}";
    local instance_id;
    instance_id="$(aws-ec2-get-instance-ids-asg "${asg}" | jq -r '. | first')";
    aws-ssm-to "${instance_id}"
}

function aws-ec2-get-instance-ids-asg {
    local asg;
    asg="${1}";
    aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "${asg}" --output json --query="AutoScalingGroups[*].Instances[].InstanceId"
}

function aws-ssm-upload-public-key() {
  instance_id=$1
  public_key=$(cat ~/.ssh/id_ed25519.pub | tr -d '\n')

  aws ssm send-command \
    --document-name "AWS-RunShellScript" \
    --parameters 'commands=["mkdir -p /home/ssm-user/.ssh", "echo \"'${public_key}'\" > /home/ssm-user/.ssh/authorized_keys", "chown ssm-user:ssm-user /home/ssm-user/.ssh/authorized_keys"]' \
    --targets "Key=instanceids,Values=$instance_id" \
    --comment "upload public key"
}


# Gets the expiration for a v2 style `aws sso login` login
function aws-sso-expiration-v2() {
  local profile=$1

  if [[ -z "$profile" ]]; then
    echo "Usage: aws-sso-expiration-v2 <profile-name>"
    return 1
  fi

  local SHA=$(aws configure get sso_start_url --profile $profile | tr -d '\n' | sha1sum | cut -d' ' -f 1)

  local EXPIRES_AT=$(cat ~/.aws/sso/cache/${SHA}.json | jq -r .expiresAt)

  local EXP=$(TZ="UTC" date -j -f "%Y-%m-%dT%H:%M:%SZ" "+%s" "$EXPIRES_AT")

  local DIFF=$(( $EXP - $(TZ=UTC date "+%s") ))
  local DIFF_HOURS=$(echo "scale=2; $DIFF / 3600" | bc)

  echo "$DIFF seconds until expiry"
  echo "$DIFF_HOURS hours until expiry"
}

# Gets the expiration for a v3 style `aws sso login --sso-session` login
function aws-sso-expiration-v3() {
  local sso_session=$1

  if [[ -z "$sso_session" ]]; then
    echo "Usage: aws-sso-expiration-v3 <sso-session-name>"
    return 1
  fi

  local SHA=$(echo -n $sso_session | sha1sum | cut -d' ' -f 1)

  local EXPIRES_AT=$(cat ~/.aws/sso/cache/${SHA}.json | jq -r .expiresAt)

  local EXP=$(TZ="UTC" date -j -f "%Y-%m-%dT%H:%M:%SZ" "+%s" "$EXPIRES_AT")

  local DIFF=$(( $EXP - $(TZ=UTC date "+%s") ))
  local DIFF_HOURS=$(echo "scale=2; $DIFF / 3600" | bc)

  echo "$DIFF seconds until expiry"
  echo "$DIFF_HOURS hours until expiry"
}

function aws-sso-expiration-for-cache-file() {
  local filePath=$1

  local EXPIRES_AT=$(cat $filePath | jq -r .registrationExpiresAt)

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

# Go commands
function goenv-init() {
  if [ ! -f .go-version ]; then
    echo "1.23.5" > .go-version
  fi

  mise install
}

function go-scratch() {
  DIR=$(mktemp -d -t go_scratch.XXXXXXX)
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

# Claude commands
function claude-scratch() {
  DIR=$(mktemp -d -t claude_scratch.XXXXXXX)
  cd $DIR
  echo "claude-scratch in $(pwd)"

  claude
}

# misc commands
function jwt-decode() {
  sed 's/\./\n/g' <<< $(cut -d. -f1,2 <<< $1) | base64 --decode | jq
}

export PATH="/usr/local/sbin:$PATH"

function claude-done() {
  $ terminal-notifier -title "Claude Code" -message "Claude has finished working"
}

function crush() {
  local AWS_PROFILE="bedrock-users"
  export AWS_REGION="us-west-2"

  # Check if AWS SSO is logged in for given profile
  if ! aws sts get-caller-identity >/dev/null 2>&1; then
    echo "AWS SSO session not found. Logging in..."
    aws sso login
    if [ $? -ne 0 ]; then
      echo "AWS SSO login failed"
      return 1
    fi
  fi

  # Export credentials for the profile and eval directly
  eval "$(aws configure export-credentials --profile $AWS_PROFILE --format env)"
  if [ $? -ne 0 ]; then
    echo "Failed to export AWS credentials"
    return 1
  fi

  $HOME/.local/bin/crush "$@"
}

# Disable fzf integration in favor of atuin
# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

#zprof
