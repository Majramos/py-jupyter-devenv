#!/usr/bin/env bash
#
# Module to manage containers


CONTAINER_NAME="${PWD##*/}"

# get all containers
# containers=($(get_containers)) to get a array
get_containers() {
    eval "docker container ls -a --format '{{.Names}} {{.Image}}'" | awk '{print $1}'
}

# list all containers based on a jupyterlab image
list_containers() {
    eval "docker container ls -a --format '{{.Names}} {{.Image}}'" \
        | awk '/jupyterlab/ {print $1"\t"$2}' \
        | column -t
}

# check if container name exists
check_container() {
    local containers=($(get_containers))
    [[ " ${containers[*]} " =~ " $1 " ]] && echo "true" || echo "false"
}

# get the external port for a container
get_container_port() {
    echo $(eval "docker inspect --format='{{json .HostConfig.PortBindings}}' $1" \
           | awk -F '[][]' '{print $2}' | grep -o '[0-9]\{4\}')
}

ports=()
# get all ports being used
get_ports() {
    local containers=($(get_containers))
    local ports=()
    for i in "${containers[@]}"; do
        ports+=("$(get_container_port $i)")
    done
    echo ${ports[*]}
}

# check if port is being used by a container
check_port() {
    (( ! ${#ports[@]} )) && ports=($(get_ports))
    
    [[ " ${ports[*]} " =~ " $1 " ]] && echo "true" || echo "false"
}

# generate random number between 1000 and 9999 to be used as port for containers
random () {
    echo $[ $RANDOM % 8999+1000]
}

# choose a name to the container and port
prompt_container() {

    # choose a random port that is available or sugest a new one if necessary
    PORT=$(random)
    while [[ "$(check_port $PORT)" == "true" ]]; do PORT=$(random); done

    if [[ $default_flag == "true" ]]; then
        container_name=$CONTAINER_NAME
        port=$PORT
    else
        container_name=""
        while [[ ! $container_name =~ ^[a-zA-Z0-9_-]+[^[:space:]]$ ]] \
                || [[ "$(check_container $container_name)" == "true" ]]; do
            read -ep "Choose a name for the container: " -i "${CONTAINER_NAME}" container_name
        done
        port=""
        while [[ ! $port =~ ^[1-9][0-9]{3}$ ]] || [[ "$(check_port $port)" == "true" ]]; do
            read -ep "Choose a port available: " -i "${PORT}" port
        done
    fi
    
    echo $container_name > ${SCRIPT_PATH}/container_name
    msg "Saving container name: $container_name"
    msg "Port choosen:          $port"

    workspace="${PWD}"
    msg "Workspace linked to folder: $workspace"
}

# Create the Container
create_container() {
    docker create \
        --name=$container_name \
        --restart=no \
        -v "/${workspace}":/workspace \
        -p $port:8888 \
        $image
        
    echo "Created container: $container_name @ $port"
    echo "From image:        $image"
    echo "Linked to:         $workspace"
}

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
