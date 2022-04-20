#!/usr/bin/env bash


readonly VERSION="0.1.0"

# Get latest release from GitHub api
get_latest_release() {
    curl --silent "https://api.github.com/repos/Majramos/py-jupyter-devenv/releases/latest" |
    grep '"tag_name":' |         # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/' # Pluck JSON value
}


check_updates() {
    local -r latest_release=$(get_latest_release | sed 's/v//')
    if [[ $latest_release == $VERSION ]]; then
        echo "Already running the latest and greatest!"
        return 0
    else
        echo "New version '$latest_release' is available!"
        return 1
    fi
}

# Get latest release from GitHub api and use the api to get 'tarball_url'

update() {
    if check_updates ; then exit 0; else
        echo "Update functionality not available yet!"
    fi
}