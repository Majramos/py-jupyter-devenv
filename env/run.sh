#!/usr/bin/env bash


run_container() {
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
        if [[ "$( docker container inspect -f '{{.State.Status}}' $container )" != "running" ]]; then
            msg "Starting $container using docker"
            docker start $container
        else
            msg "Container '$container' is already running"
        fi

        port=$(get_container_port $container)
        msg "Opening in browser at http://localhost:$port/"
        # using python to open a browser
        check_python=$(eval which python) && check_python=${check_python##*/}
        if [[ $check_python == "python3" ]]; then
            # xdg-open http://localhost:$port/
            python3 -m webbrowser http://localhost:$port/
        elif [[ $check_python == "python" ]]; then
            python -m webbrowser http://localhost:$port/
        else
            echo "Can't find a python installation to auto open browser"
            echo "Go to 'http://localhost:$port/'"
        fi
    else
        die "Container '$container' has not been created, please create first"
    fi
}

stop_container() {
    if [[ ! -f "${SCRIPT_PATH}/container_name" ]]; then
        container=$(eval "cat ${SCRIPT_PATH}/container_name")
    else
        local containers=($(get_containers))
        if [[ ${#containers[@]} == 0 ]]; then
            echo "No containers were found!"
            exit 0
        else
            local -r len_options=${#containers[@]}
            local i=0
            echo "Found existing jupyter lab containers:"
            for item in "${containers[@]}"; do
                printf '%s\n' "  $((++i))) $item"
            done
            while :; do  # choose a valid option
                read -ep "Choose a container: " index
                if (( $index >= 1 && $index <= $len_options )); then
                    break
                else
                    echo "Incorrect Input: Select a number 1-$len_options"
                fi
            done
        fi
        container=${containers[$index-1]}
    fi
    
    echo "Stopping '$(docker stop $container)' ..."
}