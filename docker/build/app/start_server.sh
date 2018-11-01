#!/bin/bash
SCRIPT_FILE=$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")
SCRIPT_DIR="$(cd "$(dirname "$0")"; pwd -P)"
cd "$SCRIPT_DIR"

# Load scripts
source /opt/deploy/bin/template_tools.sh

# # Apply database configuration template
# echo ""
# echo "Apply templates"
# echo ""
# TEMPLATE_VARIABLE_LIST='${DB_DATABASE_NAME} ${DB_WRITE_USER} ${DB_WRITE_PASS} ${SECRET_KEY_BASE}'
# apply_templates /var/www/html/config/database.yml.template /var/www/html/config || exit 1

# Remove existing server process ID
if [ -d /var/www/html/tmp ] && [ -d /var/www/html/tmp/pids ] && [ -f /var/www/html/tmp/pids/server.pid ]; then
  echo "Old process id found, removing..."
  rm /var/www/html/tmp/pids/* || exit 1
  echo "Done"
fi

# Delete Gemfile.lock file
if [ -e /var/www/html/Gemfile.lock ] || [ -L /var/www/html/Gemfile.lock ]; then
  echo "Deleting \"./Gemfile.lock\" file..."
  rm -Rf /var/www/html/Gemfile.lock
  echo "Done"
fi
echo "Installing cached Gemfile.lock file..."
if [ -f /opt/deploy/dependencies_config/Gemfile.lock ]; then
  cp /opt/deploy/dependencies_config/Gemfile.lock /var/www/html/Gemfile.lock || exit 1
  echo "Done"
else
  echo "No cached Gemfile.lock found"
fi

# Delete vendors directory content
if [ -e /var/www/html/vendor ] || [ -L /var/www/html/vendor ]; then
  if [ "$(ls -1q /var/www/html/vendor | wc -l)" != "0" ]; then
    echo "Deleting \"./vendor\" directory contents..."
    rm -Rf /var/www/html/vendor/*
    echo "Done"
  fi
fi
echo "Installing cached gem vendors..."
#gem install bundle || exit 1
#gem install libv8 || exit 1
#bundle install --jobs=4 $(if [ "$IS_PROD" == "1" ]; then echo "--without development test"; fi) || exit 1
if [ -d /opt/deploy/dependencies_config/vendor ]; then
  cp -Rf /opt/deploy/dependencies_config/vendor /var/www/html/vendor || exit 1
  echo "Done"
else
  echo "No cached gem vendors found"
fi

# Delete package-lock.json file
if [ -e /var/www/html/package-lock.json ] || [ -L /var/www/html/package-lock.json ]; then
  echo "Deleting \"./package-lock.json\" file..."
  rm -Rf /var/www/html/package-lock.json
  echo "Done"
fi
echo "Installing cached package-lock.json file..."
if [ -f /opt/deploy/dependencies_config/package-lock.json ]; then
  cp /opt/deploy/dependencies_config/package-lock.json /var/www/html/package-lock.json || exit 1
  echo "Done"
else
  echo "No cached package-lock.json found"
fi

# Delete yarn.lock file
if [ -e /var/www/html/yarn.lock ] || [ -L /var/www/html/yarn.lock ]; then
  echo "Deleting \"./yarn.lock\" file..."
  rm -Rf /var/www/html/yarn.lock
  echo "Done"
fi
echo "Installing cached yarn.lock file..."
if [ -f /opt/deploy/dependencies_config/yarn.lock ]; then
  cp /opt/deploy/dependencies_config/yarn.lock /var/www/html/yarn.lock || exit 1
  echo "Done"
else
  echo "No cached yarn.lock found"
fi

# Delete node modules directory
if [ -e /var/www/html/node_modules ] || [ -L /var/www/html/node_modules ]; then
  echo "Deleting \"./node_modules\" directory..."
  rm -Rf /var/www/html/node_modules
  echo "Done"
fi
echo "Installing cached node modules..."
if [ -d /opt/deploy/dependencies_config/node_modules ]; then
  cp -R /opt/deploy/dependencies_config/node_modules /var/www/html/node_modules || exit 1
  echo "Done"
else
  echo "No cached node modules found"
fi

cd /var/www/html

echo "Server is ready"
ping 127.0.0.1 > /dev/null
