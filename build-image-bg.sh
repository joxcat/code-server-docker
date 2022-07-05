#!/bin/bash
name=${IMAGE_NAME:-codeserver}
nohup docker build -t "$name" --build-arg GIT_NAME="$GIT_NAME" --build-arg GIT_EMAIL="$GIT_EMAIL" dockerfile > build-image-bg.log &
disown
