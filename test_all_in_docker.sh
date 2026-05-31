#!/bin/bash
set -e

docker build . -t irec
docker run -it -v .:/irec -w /irec irec ./test_all.sh