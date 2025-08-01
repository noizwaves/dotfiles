#!/usr/bin/env bash

github_token() {
	token=$(gh auth token)
    eval "$(direnv dotenv bash <(
        echo "GITHUB_TOKEN=${token@Q}"
    ))"
}
