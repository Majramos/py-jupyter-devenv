#!/usr/bin/env bash

SCRIPT_PATH="$(dirname "${BASH_SOURCE[0]}")"

CONFIG_FILE="${SCRIPT_PATH}/config"


read_config() {
    grep -w $1 $CONFIG_FILE | cut -d "=" -f 2
}


write_config() {
    local old_value="$1="$(read_config $1)
    local new_value="$1=$2"

    sed -i "s/$old_value/$new_value/" $CONFIG_FILE
}


# value=$(read_config "CONTAINER_HASH")

# if [[ $value == "" ]]; then
    # echo "no value"
# fi


echo $(read_config "PYTHON_VERSION")
