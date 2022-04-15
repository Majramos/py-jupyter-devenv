#!/bin/bash

# list all images with jupyterlab
images=($(eval "docker images -a" | awk '/jupyterlab/ {print $1}'))

# list all containers based on a jupyterlab image
containers=($(eval "docker container ls -a --format '{{.Names}} {{.Image}}'" | awk '/jupyterlab/ {print $1}'))

# get the external port for a container
get_container_port () {
    echo $(eval "docker inspect --format='{{json .HostConfig.PortBindings}}' $1" | awk -F '[][]' '{print $2}' | grep -o '[0-9]\{4\}')
}

# get all ports being used
ports=()
for i in "${containers[@]}" 
do
    :
    ports+=("$(get_container_port $i)")
done


# check if image exists
check_image () {
    [[ " ${images[*]} " =~ " $1 " ]] && echo "true" || echo "false"
}

# check if container name exists
check_container () {
    [[ " ${containers[*]} " =~ " $1 " ]] && echo "true" || echo "false"
}

# check if port is being used by a container
check_port () {
    [[ " ${ports[*]} " =~ " $1 " ]] && echo "true" || echo "false"
}

# generate random number between 1000 and 9999
random () {
    echo $[ $RANDOM % 8999+1000]
}

