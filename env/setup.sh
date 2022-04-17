#!/bin/bash

spath="$(dirname "${BASH_SOURCE[0]}")"

source "${spath}/container.sh"

# -- Make Intital Checks

#check if docker is installed
__temp=$(which docker)
if [[ $? -eq 1 ]]; then
    echo "Docker instalation not found, please install docker first!"
    exit 1
fi

# check if docker is initilized
docker_version=$(docker --version)
if [[ $? -eq 1 ]];
then
    echo "Docker is installed but not started, please start docker daemon!"
    exit 1
else
    echo "Found Docker: ${docker_version}"
fi


# -- Choose to Build a Image or Use a New One

# See images available
images_options=("${images[@]}" "Build a new one")
len_options=${#images_options[@]}
PS3="Choose a image: "
echo "Found existing jupyterlab images:"
select image in "${images_options[@]}"; do
    if [[ $REPLY =~ ^[0-9]$ ]] && [ 1 -le "$REPLY" ] && [ $REPLY -le $(($len_options)) ]; then
        break;
    else
        echo "Incorrect Input: Select a number 1-$len_options"
    fi
done

if [[ "$image" == "Build a new one" ]]; then
    source "${spath}/build.sh"  # run build step to build a image
fi


# -- Select a container name and port

# choose a name to the container
CONTAINER_NAME="${PWD##*/}" # $(read_config "container_name")
while [[ ! $container_name =~ ^[a-zA-Z0-9_-]+[^[:space:]]$ ]] || [[ "$(check_container $container_name)" == "true" ]]; do
    read -ep "Choose a name for the container:" -i "${CONTAINER_NAME}" container_name
done

# write_config $container_name container_name


# choose a random port that is available or sugest a new one if necessary
PORT=$(random)
while [[ "$(check_port $PORT)" == "true" ]]; do
    PORT=$(random)
done

while [[ ! $port =~ ^[1-9][0-9]{3}$ ]] || [[ "$(check_port $port)" == "true" ]]; do
    read -ep "Choose a port available:" -i "${PORT}" port
done


# -- Create the Container

echo ""
echo "Creating container '$container_name' @$port"
echo "From $image"

# docker create \
    # --name=$container_name \
    # --restart=no \
    # -v "/${PWD}":/workspace \
    # -p $port:8888 \
    # $image

# echo "Press enter to exit..."
# read
