#!/bin/bash
# Autor: Eduardo Rosales (https://github.com/tato11)

#======================================
# Get and set config variables
#======================================
# Constants
HELP_MESSAGE="Use -h or --help for help."

# Config
SCRIPT_FILE=$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")
SCRIPT_DIR="$(cd "$(dirname "$0")"; pwd -P)"
cd "$SCRIPT_DIR"

# Variables
PROC_ID_LIST=
PROC_ID_SEED=0

# Flags
REQUIRE_SUDO=0
SUDO_ENV_COMMAND=
IS_FIRST_PARAM=1
YES_TO_ALL=0
START=0
BUILD=0
DOWN=0
STOP=0
BUILD_IMAGE=0
SWARM_MODE=0

# Load environment variables
while read LINE; do
  if [ "$(echo "$LINE" | grep -e '^\s*[^\#]')" != "" ]; then
    export "$LINE" || exit 1
  fi
done < "$SCRIPT_DIR/.env"

# Get app dir
cd "$APP_PATH" || exit 1
export APP_PATH="$(pwd -P)"
cd "$SCRIPT_DIR"

# Display a confirmation message
function confirm () {
  # Call with a prompt string or use a default
  local answer="Y"
  local response=""
  if [ $YES_TO_ALL -eq 1 ]; then
    echo "${1:-Are you sure? (y/n)} Y"
    local response="Y"
  else
    read -r -p "${1:-Are you sure? (y/n)} " local response
  fi
  if [ "$response" != "" ]; then
    local answer="$response"
  fi
  case $answer in
    [yY][eE][sS]|[yY])
      true
      ;;
    *)
      false
      ;;
  esac
}

# Show help message
function show_help() {
cat <<EOF

Description:
  This script will start or rebuild all containers described on docker compose
  file.

Usage:
EOF
  echo "  ./$1 <action> [options]"
cat <<EOF

Help:
  -h, --help               print this message

Actions:
  start                    Start the existing containers.
  rebuild                  Build or rebuild the containers.
  destroy                  Delete the containers.
  build-image              Build all images.
  publish                  Deploy services to docker swarm.

Options:
  -y, --yes                respond yes to all questions

EOF
  exit 0
}

# Show help message when no parameters
if [ $# -lt 1 ]; then
  show_help $SCRIPT_FILE
fi
while test $# -gt 0; do
  # Get action
  if [ "$IS_FIRST_PARAM" == "1" ] && [ "$1" != "-h" ] &&  [ "$1" != "--help" ]; then
    ACTION="$1"
    IS_FIRST_PARAM=0
    shift
    continue
  fi

  # Get options
  case "$1" in
    -h|--help)
      show_help $SCRIPT_FILE
      ;;
    -y|--yes)
      YES_TO_ALL=1
      shift
      ;;
    *)
      echo "Error: Invalid parameter '$1' found. $HELP_MESSAGE"
      exit 1
      ;;
  esac
done

# Validate action
case "$ACTION" in
  start)
    START=1
    STOP=1
    ;;
  rebuild)
    START=1
    DOWN=1
    BUILD=1
    STOP=1
    ;;
  destroy)
    DOWN=1
    STOP=1
    ;;
  swarm-mode)
    SWARM_MODE=1
    ;;
  build-image)
    BUILD_IMAGE=1
    ;;
  *)
    echo "Error: Invalid action \"$ACTION\". $HELP_MESSAGE"
    exit 1
    ;;
esac

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#Keep sudo alive
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
cat <<EOF

IMPORTANT
=========
You are about to $ACTION this docker compose and will need root access to do so.

EOF
echo ""
! confirm "  Do you want to continue? (y/n) [y]" && exit 0
echo ""

# Detect possible permission deny
echo "Testing docker access, executing \"docker info\" command..."
if [ "$(docker info | grep -i -E "^server\\s+version\\s*\\:\\s*")" == "" ]; then
  echo "Failed, it could be a permission issue, will try again using sudo..."

  # Ask for root access only once
  sudo -v
  # Keep-alive: update existing sudo time stamp if set, otherwise do nothing.
  while true; do sudo docker -v >> /dev/null; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

  # Test again with sudo
  if [ "$(sudo docker info | grep -i -E "^server\\s+version\\s*\\:\\s*")" == "" ]; then
    echo "Failed, please check that docker service is running"
    exit 1
  fi
  echo "Test successful, will use sudo for docker commands"
  REQUIRE_SUDO=1
  SUDO_ENV_COMMAND="sudo"
else
  echo "Test successful"
fi

function sudo_env() {
  $SUDO_ENV_COMMAND $*
}

function store_background_job() {
  PROC_ID_LIST[${PROC_ID_SEED}]=$1 || exit 1
  PROC_ID_SEED=$(($PROC_ID_SEED + 1)) || exit 1
}

function wait_background_jobs() {
  local PROC_ID=
  for PROC_ID in ${PROC_ID_LIST[*]}; do
    wait $PROC_ID
  done

  # Reset process list
  PROC_ID_LIST=
  PROC_ID_SEED=0
}

# Cancel background process
function cancel_background_jobs() {
  for PROC_ID in ${PROC_ID_LIST[*]}; do
    sudo kill -SIGINT $PROC_ID
  done
}

function stop_app() {
  echo "Stopping project's containers..."
  sudo_env docker-compose stop || exit 1
  echo "Done"
}

function stop_app_when_need() {
  if [ "$STOP" == "1" ]; then
    stop_app || exit 1
  fi
}

# Stop docker containers if started
stop_app_when_need || exit 1

# Safety cancel on ctrl + c
function catch_ctrl_c() {
  STOP=1
  stop_app
  wait_background_jobs
}

# trap ctrl-c and call ctrl_c()
trap 'catch_ctrl_c' SIGINT


if [ "$DOWN" == "1" ]; then
  echo "Destroying project's existing containers..."
  sudo_env docker-compose down || exit 1
  echo "Done."
fi

if [ "$BUILD_IMAGE" == "1" ]; then
  cd "$SCRIPT_DIR"
  if [ "$(ls -1q ./build/app/data/dependencies_config | wc -l)" != "0" ]; then
    rm -Rf ./build/app/data/dependencies_config/* || exit 1
  fi
  echo "Copy Gemfile and node package files to app image build context before build..."
  if [ -f "$APP_PATH/Gemfile" ]; then
    echo "\"Gemfile\" file found"
    cp "$APP_PATH/Gemfile" ./build/app/data/dependencies_config/ || exit 1
  fi
  if [ -f "$APP_PATH/Gemfile.lock" ]; then
    echo "\"Gemfile.lock\" file found"
    cp "$APP_PATH/Gemfile.lock" ./build/app/data/dependencies_config/ || exit 1
  fi
  if [ -f "$APP_PATH/package.json" ]; then
    echo "\"package.json\" file found"
    cp "$APP_PATH/package.json" ./build/app/data/dependencies_config/ || exit 1
  fi
  if [ -f "$APP_PATH/package-lock.json" ]; then
    echo "\"package-lock.json\" file found"
    cp "$APP_PATH/package-lock.json" ./build/app/data/dependencies_config/ || exit 1
  fi
  if [ -f "$APP_PATH/yarn.lock" ]; then
    echo "\"yarn.lock\" file found"
    cp "$APP_PATH/yarn.lock" ./build/app/data/dependencies_config/ || exit 1
  fi
  echo "Done"
  sudo_env docker-compose build || exit 1
fi

if [ "$BUILD" == "1" ]; then
  echo "Building project's containers..."
  sudo_env docker-compose up --no-start || exit 1
  echo "Done."
fi

if [ "$START" == "1" ]; then
  echo "Starting project's containers..."
  sudo_env docker-compose start || exit 1
  sudo_env docker-compose logs -f &
  store_background_job $!
  wait_background_jobs
  catch_ctrl_c
  echo "Done."
fi

if [ "$SWARM_MODE" == "1" ]; then
  sudo_env docker stack -c ./docker-compose.yml -c ./docker-compose.prod.yml
fi
