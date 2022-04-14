#!/bin/bash


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

check_port () {
    [[ " ${ports[*]} " =~ " $1 " ]] && echo "true" || echo "false"
}


check_name () {
    [[ " ${containers[*]} " =~ " $1 " ]] && echo "true" || echo "false"
}



# -- Software Stack Version

PYTHON_VERSION="3.9.12"
JUPYTERLAB_VERSION="3.2.9"

# -- Building the Image

docker build \
  --build-arg python_version="${PYTHON_VERSION}" \
  --build-arg jupyterlab_version="${JUPYTERLAB_VERSION}" \
  -f env/jupyterlab.Dockerfile \
  -t jupyterlab:"py${PYTHON_VERSION}-jupyterlab${JUPYTERLAB_VERSION}" .
  
  
# -- Create the Container

docker create \
    --name='regulacao_petrolifero' \
    --restart=no \
    -v "/${PWD}":/workspace \
    -p 4445:8888 \
    jupyterlab:"py3.9.12-jupyterlab3.2.9"
  
 
echo "Press enter to exit..."
read
