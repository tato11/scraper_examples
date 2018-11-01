#!/bin/bash
SCRIPT_FILE=$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")
SCRIPT_DIR="$(cd "$(dirname "$0")"; pwd -P)"
cd "$SCRIPT_DIR"

# Load scripts
source /opt/deploy/bin/template_tools.sh

# Delete all previous seeds
rm -Rf /docker-entrypoint-initdb.d/*

# Build seed templates
echo ""
echo "Apply templates"
echo ""
TEMPLATE_VARIABLE_LIST='${DB_DATABASE_NAME} ${DB_WRITE_USER} ${DB_WRITE_PASS}'
apply_templates /opt/deploy/templates/* /docker-entrypoint-initdb.d || exit 1

# Copy seeds
cp /opt/deploy/seeds/* /docker-entrypoint-initdb.d/

# Start mysql service
/usr/local/bin/docker-entrypoint.sh mysqld || exit 1
