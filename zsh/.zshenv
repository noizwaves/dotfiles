# Only source this once
if [[ -z "$ZSH_SESS_VARS_SOURCED" ]]; then
  export ZSH_SESS_VARS_SOURCED=1

  export WORDCHARS=""
  export PATH=$PATH:~/.local/bin
fi

# DevSpace global defaults
export DEVSPACE_LOG_TIMESTAMPS=true

# Always DEx
export AWS_PROFILE=dex-admin-gusto-main
