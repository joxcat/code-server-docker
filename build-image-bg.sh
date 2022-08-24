#!/bin/bash
name=${IMAGE_NAME:-codeserver}
with_cache=$([ -z "$NO_CACHE" ])
# shellcheck disable=2046
nohup docker build -t "$name" $(if ! $with_cache; then echo '--no-cache'; fi) --build-arg GIT_NAME="$GIT_NAME" --build-arg GIT_EMAIL="$GIT_EMAIL" dockerfile > build-image-bg.log &
disown
