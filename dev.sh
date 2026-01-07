#!/bin/sh
set -e

docker build -t mkdocs-material-mermaid .

docker run --rm -it \
  -p 8000:8000 \
  -v "$(pwd):/docs" \
  -e WATCHFILES_FORCE_POLLING=true \
  mkdocs-material-mermaid
