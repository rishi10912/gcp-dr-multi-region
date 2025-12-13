#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/.."
cd app
docker build -t gcp-dr-demo:day1 .
docker run --rm -p 8080:8080 gcp-dr-demo:day1