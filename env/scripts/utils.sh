#!/usr/bin/env bash
#
# utilities functions

# fail-fast
set -o errexit
set -o nounset
set -o pipefail

readonly VERSION=0.3.0

readonly PROJECT_PATH="${ENV_PATH%/*}"
readonly CONFIG_FILE="${ENV_PATH}/scripts/config"

# default Values for Stack Version
readonly PYTHON_VERSION="3.11"
readonly JUPYTERLAB_VERSION="4.1"
readonly IMAGE_NAME="python-jupyter-devenv"

# error handling
readonly ERROR_PARSING_OPTIONS=80
readonly ERROR_CODE=81

# common variables for running the package
verbose="false"
skip_docker_check_flag="false"

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

# list the configuration file content except the version of the package
list_configuration() {
    msg "Listing configuration..."
    echo ""
    cat "${CONFIG_FILE}" | grep -v "VERSION="$(read_config "VERSION")
    echo ""
}

# list default Values for Stack Version
list_defaults() {
    msg "Listing default stack versions..."
    echo ""
    echo "PYTHON VERSION     = "$PYTHON_VERSION
    echo "JUPYTERLAB VERSION = "$JUPYTERLAB_VERSION
    echo "IMAGE NAME         = "$IMAGE_NAME
    echo ""
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

    compare_value() {
        if (( $(get_version_value $latest_release $1) > $(get_version_value $VERSION $1) )); then
            return 1
        else
            return 0
        fi
    }

    if compare_value 1 && compare_value 2 && compare_value 3; then
        echo "Already running the latest and greatest!"
    else
        echo "New version '$latest_release' (> $VERSION) is available!"
    fi
}

usage () {
    cat <<USAGE_TEXT
Usage: env/setup ${1}
                 [-h | --help] [-v | --verbose] [-S | --skip-check] 
                 [--list-config] [-V | --version] [--check-updates]
DESCRIPTION
    Setup a python+jupyter development environment using containers trough Docker
OPTIONS:
    ${2}
    -h, --help
        Print this help and exit.
    -v, --verbose
        Verbose output
    -S, --skip-check
        Skip checking if docker is installed and initialized
    --list-config
        List configuration values (container and image name)
    --list-defaults
        List defaults values (stack version used, python and jupyter lab)
    -V | --version
        Display version information
    --check-update
        Checks for package updates
AUTHOR
    Marco Ramos @ marcoramos.me
USAGE_TEXT
}

# common short options
readonly common_short="h,v,S,V"
readonly common_long="help,verbose,skip-check,list-config,list-defaults,version,check-update"

parse_user_common_options() {
    case "${1}" in
        -h|--help)
            usage "${2}" "${3}"
            exit 0
            ;;
        -v|--verbose)
            verbose="true"
            msg "Running in verbose mode"
            ;;
        -S|--skip-check)
            skip_docker_check_flag="true"
            ;;
        --list-config)
            list_configuration
            exit 0
            ;;
        --list-defaults)
            list_defaults
            exit 0
            ;;
        -V|--version)
            echo "py-jupyter-devenv version: "$VERSION
            exit 0
            ;;
        --check-update)
            check_updates
            exit 0
            ;;
        *)
            usage "${2}" "${3}"
            exit 0
            ;;
    esac
}


# TODO: add option to use podman instead of docker | issue #10
check_installation() {
    if [[ $skip_docker_check_flag == "false" ]]; then
        # Check if docker is installed
        __temp=$(which docker)  
        if [[ $? -eq 1 ]]; then
            die "Docker instalation not found, please install docker first!"
        fi

        # TODO: check issue #7 in git repo
        # Check if docker is initilized
        docker_version=$(docker --version)
        if [[ $? -eq 1 ]]; then
            die "Docker is installed but not started, please start docker daemon!"
        else
            msg "Found Docker: ${docker_version}"
        fi
    else
        msg "Not checking for docker instalation"
    fi
}
