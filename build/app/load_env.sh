#!/bin/bash

# Detect env
case $ENV in
  dev)
    export RAILS_ENV="development" || exit 1
    ;;
  prod)
    export RAILS_ENV="production" || exit 1
    ;;
  *)
    echo "Error: Bad environment, please select \"dev\" or \"prod\" as environment."
    exit 1
    ;;
esac

# # Get secrets
# export DB_DATABASE_NAME="$(cat "$DB_DATABASE_NAME_FILE")" || exit 1
# export DB_WRITE_USER="$(cat "$DB_WRITE_USER_FILE")" || exit 1
# export DB_WRITE_PASS="$(cat "$DB_WRITE_PASS_FILE")" || exit 1
# export SECRET_KEY_BASE="$(cat "$APP_SECRET_KEY_FILE")" || exit 1

$*
