#!/usr/bin/env bash
#
# utilities functions

# fail-fast
set -o errexit
set -o nounset
set -o pipefail

readonly PROJECT_PATH="${ENV_PATH%/*}"
readonly CONFIG_FILE="${ENV_PATH}/scripts/config"

# error handling
readonly ERROR_PARSING_OPTIONS=80
readonly ERROR_CODE=81

# common variables for running the package
verbose="false"
skip_docker_check_flag="false"
default_flag="false"


die() {
    local -r msg="${1}"
    local -r code="${2:-90}"
    echo "${msg}" >&2
    exit "${code}"
}

# to send message in case of verbose output
msg() {
    local -r msg="${1}"
    if [[ $verbose == 'true' ]]; then echo "${msg}"; fi
}

if [[ ! -f $CONFIG_FILE ]]; then
    die "Configuration file couldn't be found!"
else
    msg "Found configuration file"
fi

read_config() {
    grep -w $1 "$CONFIG_FILE" | cut -d "=" -f 2
}

write_config() {
    local old_value="$1="$(read_config $1)
    local new_value="$1=$2"

    sed -i "s/$old_value/$new_value/" "$CONFIG_FILE"
}

# list the configuration file content except the versionof the package
list_configuration() {
    cat $CONFIG_FILE | grep -v "VERSION="$(read_config "VERSION")
}

# Get latest release from GitHub api
# get_latest_release() {
    # curl --silent "https://api.github.com/repos/Majramos/py-jupyter-devenv/releases/latest" |
    # grep '"tag_name":' |         # Get tag line
    # sed -E 's/.*"([^"]+)".*/\1/' # Pluck JSON value
# }

# Get latest release from GitLab api
get_latest_release() {
    curl --silent "https://gitlab.com/api/v4/projects/36457624/releases" |
    grep -Po '"tag_name":(\d*?,|.*?[^\\]",)' |  # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/' # Pluck JSON value
}

# split the version numbering and return the required value by index
get_version_value() {
    echo $1 | cut -d "." -f $2
}

# check for the latest releases and compares with the config.VERSION
check_updates() {
    local -r latest_release=$(get_latest_release | sed 's/v//')
    local -r current_version=$(read_config "VERSION")

    compare_value() {
        if (( $(get_version_value $latest_release $1) > $(get_version_value $current_version $1) )); then
            return 1
        else
            return 0
        fi
    }

    if compare_value 1 && compare_value 2 && compare_value 3; then
        echo "Already running the latest and greatest!"
    else
        echo "New version '$latest_release' (> $current_version) is available!"
    fi
}

# display package version
show_version() {
    echo "py-jupyter-env version: "$(read_config "VERSION")
}
