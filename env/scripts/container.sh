#!/usr/bin/env bash
#
# Module to manage containers


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

    local default_container_name=$(read_config "CONTAINER_NAME")

    # choose a random port that is available or sugest a new one if necessary
    PORT=$(random)
    while [[ "$(check_port $PORT)" == "true" ]]; do PORT=$(random); done

    if [[ $default_flag == "true" ]]; then
        container_name=$default_container_name
        port=$PORT
    else
        container_name=""
        while [[ ! $container_name =~ ^[a-zA-Z0-9_-]+[^[:space:]]$ ]] \
                || [[ "$(check_container $container_name)" == "true" ]]; do
            read -ep "Choose a name for the container: " -i "${default_container_name}" container_name
        done
        port=""
        while [[ ! $port =~ ^[1-9][0-9]{3}$ ]] || [[ "$(check_port $port)" == "true" ]]; do
            read -ep "Choose a port available: " -i "${PORT}" port
        done
    fi
    
    write_config "CONTAINER_NAME" $container_name
    msg "Saving container name: $container_name"
    msg "Port choosen:          $port"

    # TODO: check if this is getting the correct directory
    workspace=$PROJECT_PATH
    msg "Workspace linked to folder: $workspace"
}

# get the id of the container
get_container_id() {
    docker container inspect --format="{{.Id}}" $1
}

# create the Container
create_container() {
    docker create \
        --name=$container_name \
        --restart=no \
        -v "/${workspace}":/home/pyuser/workspace \
        -p $port:8888 \
        $image

    write_config "CONTAINER_ID" $(get_container_id $container_name)

    echo "Created container: $container_name @ $port"
    echo "From image:        $image"
    echo "Linked to:         $workspace"
}

run_container() {
    # load container name
    local container=$(read_config "CONTAINER_NAME")
    msg "Found container name: $container"

    # check if the container exits first
    if [[ $(check_container $container) == "true" ]]; then
        if [[ "$( docker container inspect -f '{{.State.Status}}' $container )" != "running" ]]; then
            msg "Starting $container using docker"
            docker start $container
        else
            msg "Container '$container' is already running"
        fi

        port=$(get_container_port $container)
        echo "Environment at: http://localhost:$port/"
    else
        die "Container '$container' has not been created, please create it first"
    fi
}

stop_container() {
    # load container name
    local container=$(read_config "CONTAINER_NAME")

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

    echo "Stopping '$(docker stop $container)' ..."
}
