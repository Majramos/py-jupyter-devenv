#!/usr/bin/env bash

SCRIPT_PATH="$(dirname "${BASH_SOURCE[0]}")"

# remove unwanted folders from git
# rm -rf $SCRIPT_PATH/.git
# rm -rf $SCRIPT_PATH/.gitignore
# rm -rf $SCRIPT_PATH/.gitlab-ci.yml
# rm -rf $SCRIPT_PATH/CHANGELOG.md
# rm -rf $SCRIPT_PATH/README.md
# rm -rf $SCRIPT_PATH/LICENSE
# rm -rf $SCRIPT_PATH/install.sh
# rm -rf $SCRIPT_PATH/get-badge-info.sh

function choose_name() {
    
    while [[ -z "$folder_name" ]]
    do
        read -ep "Choose a name for the folder: " folder_name
    done

    source_path=$(cd $SCRIPT_PATH && pwd)

    cd "$(dirname $source_path)"

    # make new folder and just copy necessary stuff
    # TODO: check if folder exists just copy env to folder 
    mkdir $PWD/$folder_name
    cp -r $PWD/py-jupyter-devenv/env $PWD/$folder_name
    rm -rf $PWD/$SCRIPT_PATH
}


while true
do
  read -p "Rename folder? [Y/n] " yesno
  yesno=${yesno:-Y}
  case $yesno in
    [Yy]*|yes)
        choose_name
        exit
        ;;
    [Nn]*|no ) exit;;
  esac
done