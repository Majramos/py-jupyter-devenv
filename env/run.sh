#!/usr/bin/env bash


# check if config files exists with name of the container
if [[ ! -f "${SCRIPT_PATH}/container_name" ]]; then
    die "Configuration file 'container' does not exists"
else
    # load container name
    container=$(eval "cat ${SCRIPT_PATH}/container_name")
    msg "Found container name: $container"
fi

# check if the container exits first
if [[ $(check_container $container) == "true" ]]; then
    # docker start regulacao_petrolifero
    echo "docker start regulacao_petrolifero"

    port=$(get_container_port $container)
    # xdg-open http://localhost:$port/
    # python3 -m webbrowser http://localhost:$port/
    echo "python3 -m webbrowser http://localhost:$port/"
else
    die "Container '$container' has not been created, please create first"
fi
