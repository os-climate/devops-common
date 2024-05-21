#!/usr/bin/env bash

# Script to extract and execute suitably marked
#  shell code from a workflow YAML file

set -eu -o pipefail
# set -xv


# Variables

AUTOMATION_BRANCH="update-gha-workflows"


# Checks

if [ $# -ne 1 ]; then
    echo "Usage:    $0 [workflow file path]"; exit 1
else
    YAML_PATH="$1"
    if [ ! -f "$YAML_PATH" ]; then
        echo "The specified file could not be found: $YAML_PATH"; exit 1
    fi
fi

GIT_CMD=$(which git)
if [ ! -x "$GIT_CMD" ]; then
    echo "GIT command was NOT found in PATH"; exit 1
fi

# Running in temporary containers doesn't require mktemp
# MKTEMP_CMD=$(which mktemp)
# if [ ! -x "$MKTEMP_CMD" ]; then
#     echo "MKTEMP command was NOT found in PATH"; exit 1
# fi
# # SHELL_SCRIPT=$(mktemp -t script-XXXXXXXX.sh)
SHELL_SCRIPT="/tmp/extracted.sh"


# Functions

change_dir_error() {
    echo "Could not change directory"; exit 1
}

check_for_local_branch() {
    BRANCH="$1"
    git show-ref --quiet refs/heads/"$BRANCH"
    return $?
}

check_for_remote_branch() {
    BRANCH="$1"
    git ls-remote --exit-code --heads origin "$BRANCH"
    return $?
}

cleanup_on_exit() {
    # Remove PR branch, if it exists
    echo "Cleaning up on exit: bootstrap.sh"
    echo "Swapping from temporary branch to: $HEAD_BRANCH"
    git checkout main > /dev/null 2>&1
    if (check_for_local_branch "$AUTOMATION_BRANCH"); then
        echo "Removing temporary local branch: $AUTOMATION_BRANCH"
        git branch -d "$AUTOMATION_BRANCH" > /dev/null 2>&1
    fi
    #if [ -f "$SHELL_SCRIPT" ]; then
    #    echo "Removing temporary shell code"
    #    rm "$SHELL_SCRIPT"
    #fi
}
trap cleanup_on_exit EXIT

### Main script entry point

# Get organisation and repository name
# e.g. ModeSevenIndustrialSolutions/test-bootstrap.git
URL=$(git config --get remote.origin.url | awk -F: '{print $2}')
# Convert to format e.g. ModeSevenIndustrialSolutions/test-bootstrap
ORG_AND_REPO=${URL/%.git}
HEAD_BRANCH=$("$GIT_CMD" rev-parse --abbrev-ref HEAD)
REPO_DIR=$(git rev-parse --show-toplevel)

echo "Organisation and repository: $ORG_AND_REPO"

# Change to top-level of GIT repository
CURRENT_DIR=$(pwd)
if [ "$REPO_DIR" != "$CURRENT_DIR" ]; then
    echo "Changing directory to: $REPO_DIR"
    cd "$REPO_DIR" || change_dir_error
fi

# The section below extracts shell code from the YAML file
echo "Extracting shell code from: $YAML_PATH"
EXTRACT="false"
while read -r LINE; do
    if [ "$LINE" = "#SHELLCODESTART" ]; then
        EXTRACT="true"
        touch "$SHELL_SCRIPT"
        chmod a+x "$SHELL_SCRIPT"
        echo "Creating shell script: $SHELL_SCRIPT"
        echo "#!/bin/sh" > "$SHELL_SCRIPT"
    fi
    if [ "$EXTRACT" = "true" ]; then
        echo "$LINE" >> "$SHELL_SCRIPT"
        if [ "$LINE" = "#SHELLCODEEND" ]; then
            break
        fi
    fi
done < "$YAML_PATH"

echo "Running extracted shell script code"
# https://www.shellcheck.net/wiki/SC1090
# Shell code executed is temporary and cannot be checked by linting
# shellcheck disable=SC1090
. "$SHELL_SCRIPT"
