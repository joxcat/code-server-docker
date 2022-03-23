#!/bin/bash
name=${IMAGE_NAME:-codeserver}
nohup docker build -t "$name" . > build-image-bg.log &
disown
