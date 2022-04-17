#!/bin/bash

spath="$(dirname "${BASH_SOURCE[0]}")"


# write to configuration file
# >> write_config var filename
write_config () { echo $1 > ${spath}/config/$2 ; }

# read configuration file
# >> $(read_config filename)
read_config () {
    __file="${spath}"/config/$1
    if [ -f "$__file" ]; then
        echo $(cat $__file)
    fi
}


# -- Load Preset Config for Stack Version

PYTHON_VERSION="3.9.12" # $(read_config "python_version")
JUPYTERLAB_VERSION="3.2.9" # $(read_config "jupyterlab_version")
EXECUTETIME_VERSION="2.1.0" # $(read_config "executetime_version")

# -- Prompt for other versions

# python
while [[ ! $python_version =~ ^[0-9]+(\.[0-9]+){1,2}$ ]] ; do 
    read -ep "Specify a python version:" -i "${PYTHON_VERSION}" python_version
done
write_config $python_version python_version

#jupyter lab
while [[ ! $jupyterlab_version =~ ^[0-9]+(\.[0-9]+){1,2}$ ]] ; do 
    read -ep "Specify a jupyter lab version:" -i "${JUPYTERLAB_VERSION}" jupyterlab_version
done

write_config $jupyterlab_version jupyterlab_version

#execution time
while [[ ! $executetime_version =~ ^[0-9]+(\.[0-9]+){1,2}$ ]] ; do 
    read -ep "Specify a jupyter lab version:" -i "${EXECUTETIME_VERSION}" executetime_version
done

write_config $executetime_version executetime_version


# -- Building the Image

image="jupyterlab:py${python_version}-jupyterlab${jupyterlab_version}"

docker build \
    --no-cache \
    --build-arg python_version="${python_version}" \
    --build-arg jupyterlab_version="${jupyterlab_version}" \
    --build-arg executetime_version="${executetime_version}" \
    -f env/jupyterlab.Dockerfile \
    -t $image .
