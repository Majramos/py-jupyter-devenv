#!/usr/bin/env bash


# Default Values for Stack Version
readonly PYTHON_VERSION="3.9.12"
readonly JUPYTERLAB_VERSION="3.2.9"
readonly EXECUTETIME_VERSION="2.1.0"

list_stack_version() {
    echo "Python Version:              $PYTHON_VERSION"
    echo "Jupyter lab Version:         $JUPYTERLAB_VERSION"
    echo "Executime Extension Version: $EXECUTETIME_VERSION"
}

set_defaults() {
    python_version=$PYTHON_VERSION
    jupyterlab_version=$JUPYTERLAB_VERSION
    executetime_version=$EXECUTETIME_VERSION
    msg "Using default stack version values (see --show-defaults)"
}

# list all image:tag with jupyterlab
# images=($(get_images)) to get a array
get_images() {
    eval "docker images -a" | awk '/^jupyterlab/ {print $1":"$2}'
}

# check if image exists
check_image() {
    [[ " ${images[*]} " =~ " $1 " ]] && echo "true" || echo "false"
}

# Prompt for stack versions
prompt_versions() {
    # python
    while [[ ! $python_version =~ ^[0-9]+(\.[0-9]+){1,2}$ ]] ; do 
        read -ep "Specify a Python version:" -i "${PYTHON_VERSION}" python_version
    done
    #jupyter lab
    while [[ ! $jupyterlab_version =~ ^[0-9]+(\.[0-9]+){1,2}$ ]] ; do 
        read -ep "Specify a Jupyter Lab version:" -i "${JUPYTERLAB_VERSION}" jupyterlab_version
    done
    #execution time
    while [[ ! $executetime_version =~ ^[0-9]+(\.[0-9]+){1,2}$ ]] ; do 
        read -ep "Specify a Execute Time Extension version:" -i "${EXECUTETIME_VERSION}" executetime_version
    done
    msg "Setting Python:$python_version, JupyterLab:$jupyterlab_version"
}

# Building the Image
build_image() {
    image="jupyterlab:py${python_version}-jl${jupyterlab_version}"
    docker build \
        --no-cache \
        --build-arg python_version="${python_version}" \
        --build-arg jupyterlab_version="${jupyterlab_version}" \
        --build-arg executetime_version="${executetime_version}" \
        -f env/jupyterlab.Dockerfile \
        -t $image .
    msg "Built image: $image"
}

# See images available and either choose one to use or build a new one
prompt_images() {
    local images=($(get_images))
    IFS=$'\n' images=($(sort -r <<<"${images[*]}")); unset IFS  # sort list of images
    images=("Build a new image" "${images[@]}")
    local -r len_options=${#images[@]}
    local i=0
    echo "Found existing jupyterlab images:"
    for item in "${images[@]}"; do
        printf '%s\n' "  $((++i))) $item"
    done
    while :; do  # choose a valid option
        read -ep "Choose a image:" -i 2 index
        if (( $index >= 1 && $index <= $len_options )); then
            break
        else
            echo "Incorrect Input: Select a number 1-$len_options"
        fi
    done
    
    if [[ $index == 1 ]]; then
        prompt_versions
        build_image
    else
        image=${images[$index-1]}
        echo $image
    fi
}
