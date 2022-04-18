#!/usr/bin/env bash


# list all containers based on a jupyterlab image
# containers=($(get_containers)) to get a array
get_containers() {
    eval "docker container ls -a --format '{{.Names}} {{.Image}}'" | awk '/jupyterlab/ {print $1}'
}

# check if container name exists
check_container() {
    [[ " ${containers[*]} " =~ " $1 " ]] && echo "true" || echo "false"
}

# get the external port for a container
get_container_port() {
    echo $(eval "docker inspect --format='{{json .HostConfig.PortBindings}}' $1" | awk -F '[][]' '{print $2}' | grep -o '[0-9]\{4\}')
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

# generate random number between 1000 and 9999
random () {
    echo $[ $RANDOM % 8999+1000]
}

# choose a name to the container and port
prompt_container() {
    CONTAINER_NAME="${PWD##*/}"
    while [[ ! $container_name =~ ^[a-zA-Z0-9_-]+[^[:space:]]$ ]] || [[ "$(check_container $container_name)" == "true" ]]; do
        read -ep "Choose a name for the container:" -i "${CONTAINER_NAME}" container_name
    done

    echo $container_name > ${SCRIPT_PATH}/container_name
    msg "Saving container name: $container_name"

    # choose a random port that is available or sugest a new one if necessary
    PORT=$(random)
    while [[ "$(check_port $PORT)" == "true" ]]; do
        msg "Port '$PORT' is already in use"
        PORT=$(random)
    done
    while [[ ! $port =~ ^[1-9][0-9]{3}$ ]] || [[ "$(check_port $port)" == "true" ]]; do
        read -ep "Choose a port available:" -i "${PORT}" port
    done
    msg "Port choosen: $port"
    
    workspace="${PWD}"
    msg "Workspace linked to folder: $workspace"
}

# Create the Container
create_container() {    
    docker create \
        --name=$container_name \
        --restart=no \
        -v $workspace:/workspace \
        -p $port:8888 \
        $image
        
    echo "Created container: $container_name @ $port"
    echo "From image:        $image"
    echo "Linked to:         $workspace"
}