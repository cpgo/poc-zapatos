#!/usr/bin/env sh

docker run --env-file=.env --rm -it -p 5432:5432 postgres:12
