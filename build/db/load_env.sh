#!/bin/bash

# Get secrets
export DB_DATABASE_NAME="$(cat "$DB_DATABASE_NAME_FILE")" || exit 1
export DB_WRITE_USER="$(cat "$DB_WRITE_USER_FILE")" || exit 1
export DB_WRITE_PASS="$(cat "$DB_WRITE_PASS_FILE")" || exit 1

$*
