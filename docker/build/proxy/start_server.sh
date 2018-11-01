#!/bin/bash
SCRIPT_FILE=$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")
SCRIPT_DIR="$(cd "$(dirname "$0")"; pwd -P)"
cd "$SCRIPT_DIR"

# Load scripts
source /opt/deploy/bin/template_tools.sh

# Delete previous configurations
rm -Rf /etc/nginx/conf.d/*

# Apply configuration templates
echo ""
echo "Apply templates"
echo ""
TEMPLATE_VARIABLE_LIST='${ENV} ${WEB_DOMAIN_NAME} ${PROXY_APP_CERTIFICATE_FILE} ${PROXY_APP_CERTIFICATE_KEY_FILE} ${DOCKER_RESOLVER_IP}'
apply_templates /opt/deploy/templates/* /etc/nginx/conf.d || exit 1

# Start nginx service
nginx -g 'daemon off;' || exit 1
