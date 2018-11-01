#!/bin/bash

function apply_templates() {
  local TARGET_DIR="${@:$#}" || exit 1
  local DOLLAR='$'
  local VARIABLE_LIST="$TEMPLATE_VARIABLE_LIST" || exit 1

  # Use all env variables as default when no variable list was defined
  if [ "$VARIABLE_LIST" == "" ]; then
    echo "No 'TEMPLATE_VARIABLE_LIST' variable was set, default to environment variable list."
    local VARIABLE_LIST="`printf '${%s} ' $(compgen -A variable)`"
  fi

  # Add dollar variable when needed
  if [ "$(echo "$VARIABLE_LIST" | grep -o '${DOLLAR}')" == "" ]; then
    echo "'DOLLAR' variable not detected, adding it to variable template list."
    local VARIABLE_LIST="${VARIABLE_LIST} $(echo '${DOLLAR}')"
  fi

  # Copy or apply template files
  for SOURCE_FILE_PATH in "${@:1:$#-1}"; do
    if [ "$SOURCE_FILE_PATH" == "" ]; then continue; fi
    local FILENAME="$(basename "$SOURCE_FILE_PATH")" || exit 1
    local EXTENSION="$(echo "$SOURCE_FILE_PATH" | grep -Eo "[^/]\\.[^./]+$" | grep -Eo "\\..+")" || exit 1
    if [ "$EXTENSION" = ".template" ]; then
      # Apply template into target
      local BASENAME="${FILENAME%.*}" || exit 1
      local TARGET_FILE_PATH="$TARGET_DIR/$BASENAME" || exit 1
      echo "Apply \"$SOURCE_FILE_PATH\" template into \"$TARGET_FILE_PATH\"."
      # Use ${D} to escape $ inside the template
      env D='$' envsubst "$VARIABLE_LIST" < "$SOURCE_FILE_PATH" > "$TARGET_FILE_PATH" || exit 1
    else
      # Copy file into target
      if [ -f "$SOURCE_FILE_PATH" ]; then
        # Don't copy directories just files
        local TARGET_FILE_PATH="$TARGET_DIR/$FILENAME" || exit 1
        echo "Copy non-template file \"$SOURCE_FILE_PATH\" into \"$TARGET_FILE_PATH\"."
        cp -f "$SOURCE_FILE_PATH" "$TARGET_FILE_PATH" || exit 1
      fi
    fi
  done
}
export apply_templates
