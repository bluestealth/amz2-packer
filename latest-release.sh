#!/usr/bin/env bash

set -euf -o pipefail

BASE_URL="https://cdn.amazonlinux.com/os-images"

curl "${BASE_URL}/latest/" -I -s -f | grep "^location:" | sed -r "s#location: ${BASE_URL}/([^/]+)/#\1#"
