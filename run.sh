#!/usr/bin/env bash

docker run --rm -it --init \
  --publish 8888:8888 \
  --volume="$PWD:/home/jupyter:rw" \
  wn1980/solidpython
