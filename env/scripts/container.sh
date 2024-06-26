#!/usr/bin/env bash
#
# Module to manage containers


# get all containers
# containers=($(get_containers)) to get a array
get_containers() {
    eval "docker container ls -a --format '{{.Names}} {{.Image}}'" | awk '{print $1}'
}


# get also the state and then select only the colum when 
# list all containers based on a python-jupyter-devenv image
list_containers() {
    eval "docker container ls -a --format '{{.Names}} {{.Image}} {{.Status}}'" \
        | awk '/python-jupyter-devenv/ {print $1"\t"$2"\t"$3}'
}


# check if container name exists
check_container() {
    local containers=($(get_containers))
    [[ " ${containers[*]} " =~ " $1 " ]] && echo "true" || echo "false"
}


# get the id of the container
get_container_id() {
    docker container inspect --format="{{.Id}}" $1
}


# get the external port for a container
get_container_port() {
    echo $(eval "docker inspect --format='{{json .HostConfig.PortBindings}}' $1" \
           | awk -F '[][]' '{print $2}' | grep -o '[0-9]\{4\}')
}


# get all ports being used
ports=()
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

    local default_container_name=$(basename "$PROJECT_PATH")

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

    msg "Saving container name: $container_name"
    msg "Port choosen:          $port"

    workspace=$PROJECT_PATH
    msg "Workspace linked to folder: $workspace"
}


# See images available and either choose one to use or build a new one
prompt_images() {

    local images=($(list_images))

    if [[ ${#images[@]} == 0 ]]; then
        echo "No python-jupyter-devenv images were found, need to create one"
        index=1
    else
        IFS=$'\n' images=($(sort -r <<<"${images[*]}")); unset IFS  # sort list of images
        images=("Build a new image" "${images[@]}")
        local -r len_options=${#images[@]}
        local i=0
        echo "Found existing python-jupyter-devenv images:"
        # print all available images
        for item in "${images[@]}"; do printf '%s\n' "  $((++i))) $item"; done
        while :; do  # choose a valid option
            read -ep "Choose a image: " -i 2 index
            if (( $index >= 1 && $index <= $len_options )); then
                break
            else
                echo "Incorrect Input: Select a number 1-$len_options"
            fi
        done
    fi

    if [[ $index == 1 ]]; then
        # first option is to build a new image
        if [[ $default_flag == "false" ]]; then prompt_versions; fi
        build_image
    else
        image=${images[$index-1]}
        msg "Choose image '$image'"
    fi
}


# create the Container and store caracteristics in config
# TODO: make sure of the dns server of the container | issue #22
create_container() {

    docker create \
        --name=$container_name \
        --hostname=$container_name \
        --restart=no \
        -v "/${workspace}":/home/pyuser/workspace \
        -p $port:8888 \
        $extra_build_args $image

    write_config "CONTAINER_NAME" $container_name
    write_config "CONTAINER_ID" $(get_container_id $container_name)

    write_config "IMAGE_NAME" $image
    write_config "IMAGE_ID" $(get_image_id $image)

    # get the stack version from the image nametag
    local second="${image//python-jupyter-devenv:/''}"
    python_version=$(echo $second | tr "-" "\n" | grep py | sed 's/py//')
    jupyterlab_version=$(echo $second | tr "-" "\n" | grep jl | sed 's/jl//')

    write_config "PYTHON_VERSION" "${python_version}"
    write_config "JUPYTERLAB_VERSION" "${jupyterlab_version}"

    echo "Created container: $container_name @ $port"
    echo "From image:        $image"
    echo "Linked to:         $workspace"
}


# container is 'running' or 'exited'
_get_container_name() {

    # load container name
    local container=$(read_config "CONTAINER_NAME")
    msg "Found container name: $container"

    # check if the container exits first
    if [[ $(check_container $container) == "true" ]]; then
        echo $container
    else
        die "Container '$container' doesn't exit"
    fi
}


_get_container_status() {
    docker container inspect -f '{{.State.Status}}' $1
}


run_container() {
    
    local container=$(_get_container_name)

    if [[ "$( _get_container_status $container )" != "running" ]]; then
        msg "Starting $container using docker"
        docker start $container
    else
        msg "Container '$container' is already running"
    fi

    port=$(get_container_port $container)
    echo ""
    echo "Environment at: http://localhost:$port/"
}


delete_container() {

    local container=$(_get_container_name)

    if [[ "$( _get_container_status $container )" != "running" ]]; then
        msg "Starting $container using docker"
        docker rm $container

        write_config "CONTAINER_NAME" "${IMAGE_NAME}"
        write_config "CONTAINER_ID" ""
        write_config "IMAGE_NAME" ""
        write_config "IMAGE_ID" ""
        write_config "PYTHON_VERSION" "${PYTHON_VERSION}"
        write_config "JUPYTERLAB_VERSION" "${JUPYTERLAB_VERSION}"
    else
        echo ""
        die "Container '$container' is still running"
    fi
}


stop_container() {

    local container=$(_get_container_name)

    if [[ "$( _get_container_status $container )" == "running" ]]; then
        msg "Starting $container using docker"
        docker stop $container
    else
        echo ""
        die "Container '$container' is not running and can't be stopped"
    fi
}


restart_container() {

    local container=$(_get_container_name)

    msg "Starting $container using docker"
    docker restart $container
}
