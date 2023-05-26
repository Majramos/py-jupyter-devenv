#!/usr/bin/env bash
#
# Setup a python+jupyter development environment
# This script installs the package


SCRIPT_PATH="$(dirname "${BASH_SOURCE[0]}")"

ask_yesno() {
    while true
    do
      read -p "$1 [Y/n] " yesno
      yesno=${yesno:-Y}
      case $yesno in
        # [Yy]*|yes) break;;
        # [Nn]*|no ) exit;;
        [Yy]*|yes) 
            echo "true" 
            break;;
        [Nn]*|no) 
            echo "false"
            break;;
      esac
    done
}


## move to the location of the cloned directory
source_path=$(cd $SCRIPT_PATH && pwd)
cd "$(dirname $source_path)"


move_env() {
    # create a new directory
    echo "mkdir 
        $PWD/$2
        "
    mkdir $PWD/$2
    
    # copy the env to new directory
    echo "coping 
        $PWD/$1/env 
        $PWD/$2
        "
    cp -r $PWD/$1/env $PWD/$2
}

# ask for renaming the directory
if [[ $(ask_yesno "Rename directory?") == "true" ]]; then

    while [[ -z "$folder_name" ]]
    do
        read -ep "Choose a name for the directory: " folder_name
    done

    # check if directory exists
    if [[ -d "$folder_name" ]]; then
        # ask for use existing directory
        echo "Found a directory a existing '$folder_name' directory!"
        if [[ $(ask_yesno "Overwrite the directory?") == "true" ]]; then
            # check if env exists in directory
            if [[ -d "$PWD/$folder_name/env" ]]; then
                # ask for overwrite the env directory
                echo "Found a existing $folder_name/env!"
                if [[ $(ask_yesno "Overwrite the $folder_name/env directory?") == "false" ]]; then
                    echo "Check the target directory and try installing again"
                    exit 0
                fi
                # remove existing env directory that will be replaced
                rm -rf $PWD/$folder_name/env
            fi
            # copy the env directory
            cp -r $PWD/py-jupyter-devenv/env $PWD/$folder_name
        else
            exit 0
        fi
    else
        move_env "py-jupyter-devenv" $folder_name
    fi
else
    # clear current directory of files not required
    # using a temp directory '_py-jupyter-devenv' that will be removed
    move_env "py-jupyter-devenv" "_py-jupyter-devenv"
    rm -rf $PWD/$SCRIPT_PATH
    move_env "_py-jupyter-devenv" "py-jupyter-devenv"
    rm -rf $PWD/"_py-jupyter-devenv"
    exit 0
fi


if [[ $(ask_yesno "Keep original folder ?") == "false" ]]; then
    # delete old directory
    rm -rf $PWD/$SCRIPT_PATH
fi