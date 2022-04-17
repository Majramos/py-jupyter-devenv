#!/bin/bash

spath="$(dirname "${BASH_SOURCE[0]}")"

source "${spath}/container.sh"

# -- Get the container settings

# check if config files exists with name of the container
if [[ ! -f "${spath}/config/container" ]]; then
    echo "Configuration file 'container' does not exists"
    exit 1
else
    # load container name
    container=$(eval "cat ${spath}/config/container_name")
fi

# -- Start the container

# check if the container exits first
if [[ $(check_container $container) == "true" ]]; then
    # docker start regulacao_petrolifero
    echo "docker start regulacao_petrolifero"

    port=$(get_container_port $container)
    # xdg-open http://localhost:$port/
    # python3 -m webbrowser http://localhost:$port/
    echo "python3 -m webbrowser http://localhost:$port/"
else
    echo "Container '$container' has not been created, please create first"
fi

echo "Press enter to exit..."
read
