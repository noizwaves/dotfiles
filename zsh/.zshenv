# Only source this once
if [[ -z "$ZSH_SESS_VARS_SOURCED" ]]; then
  export ZSH_SESS_VARS_SOURCED=1

  export WORDCHARS=""
fi

if [[ "$PATH" != *"$HOME/.local/bin"* ]]; then
  export PATH=$PATH:~/.local/bin
fi

# Always DEx
# export AWS_PROFILE=dex-admin-gusto-main

# Load cargo if installed
if [ -d "$HOME/.cargo" ]; then
  . "$HOME/.cargo/env"
fi
