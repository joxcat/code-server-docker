#!/bin/bash
name=${IMAGE_NAME:-codeserver}
nohup docker build -t "$name" dockerfile > build-image-bg.log &
disown
