#!/bin/bash

# Get secrets
export WEB_DOMAIN_NAME="$(cat "$WEB_DOMAIN_NAME_FILE")" || exit 1
export DOCKER_RESOLVER_IP="$(cat /etc/resolv.conf | grep nameserver | head -n1 | sed -E 's/^nameserver\s+(.+?)\s*$|^.*$/\1/' | tr '\n' ' ')"
#export SECRET_KEY_BASE="$(cat "$APP_SECRET_KEY_FILE")" || exit 1

$*
