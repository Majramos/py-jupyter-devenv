#!/usr/bin/env bash

SCRIPT_PATH="$(dirname "${BASH_SOURCE[0]}")"

# remove unwanted folders from git
rm -rf $SCRIPT_PATH/.git
rm -rf $SCRIPT_PATH/.gitignore
rm -rf $SCRIPT_PATH/CHANGELOG.md
rm -rf $SCRIPT_PATH/README.md
rm -rf $SCRIPT_PATH/LICENSE
rm -rf $SCRIPT_PATH/install.sh
rm -rf $SCRIPT_PATH/get-badge-info.sh
