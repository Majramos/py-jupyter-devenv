#!/usr/bin/env bash


readonly VERSION="0.1.0"

# Get latest release from GitHub api
# get_latest_release() {
    # curl --silent "https://api.github.com/repos/Majramos/py-jupyter-devenv/releases/latest" |
    # grep '"tag_name":' |         # Get tag line
    # sed -E 's/.*"([^"]+)".*/\1/' # Pluck JSON value
# }


# Get latest release from GitLab api
get_latest_release() {
    curl --silent "https://gitlab.com/api/v4/projects/36457624/releases" |
    grep -Po '"tag_name":(\d*?,|.*?[^\\]",)' |         # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/' # Pluck JSON value
}


# 
# download_latet_release() {
    # curl "https://gitlab.com/api/v4/projects/34112665/repository/archive.zip?sha=v1.0.0" -o test.zip
# }

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