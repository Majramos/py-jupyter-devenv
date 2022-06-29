#!/usr/bin/env bash

SCRIPT_PATH="$(dirname "${BASH_SOURCE[0]}")"

ask_yesno() {
    while true
    do
      read -p "$1 [Y/n] " yesno
      yesno=${yesno:-Y}
      case $yesno in
        [Yy]*|yes) break;;
        [Nn]*|no ) exit;;
      esac
    done
}

ask_yesno "Rename directory?"

while [[ -z "$folder_name" ]]
do
    read -ep "Choose a name for the directory: " folder_name
done

# move to the location of the cloned directory
source_path=$(cd $SCRIPT_PATH && pwd)
cd "$(dirname $source_path)"

if [[ -d "$folder_name" ]]; then
    # check if folder exists just copy env to folder
    ask_yesno "Directory $folder_name already exists, use folder as devenv?"
    if [[ -d "$PWD/$folder_name/env" ]]; then
        # check if a env exists and offer to overwrite
        ask_yesno "Found a existing 'env' directory, overwrite?"
        rm -rf $PWD/$folder_name/env
    fi
else
    mkdir $PWD/$folder_name
fi

cp -r $PWD/py-jupyter-devenv/env $PWD/$folder_name

ask_yesno "Remove source /py-jupyter-devenv directory?"
rm -rf $PWD/$SCRIPT_PATH