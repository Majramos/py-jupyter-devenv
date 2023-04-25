#!/usr/bin/env bash
#
# Module to manage container images


# start by setting this as default stack version
python_version=$PYTHON_VERSION
jupyterlab_version=$JUPYTERLAB_VERSION


# list all <image name>:<tag> for python-jupyter-devenv
# images=($(get_images)) to get a array
get_images() {
    eval "docker images -a" | awk '/^python-jupyter-devenv/ {print $1":"$2}'
}

# check if image exists
check_image() {
    [[ " ${images[*]} " =~ " $1 " ]] && echo "true" || echo "false"
}

# get the id of the image
get_image_id() {
    docker image inspect --format="{{.Id}}" "python-jupyter-devenv:$1" | cut -d ":" -f 2
}

# prompt for a version, expecting a semver type version like 1.1.1
__prompt_version() {
    local version
    read -ep "Specify a $1 version:" -i $2 version
    while [[ ! $version =~ ^[0-9]+(\.[0-9]+){1,2}$ ]] ; do
        read -ep "Specify a $1 version: " -i "$2" version
    done
    echo $version
}

# Prompt for stack versions
prompt_versions() {
    python_version=$(__prompt_version "Python" $PYTHON_VERSION $python_version)
    jupyterlab_version=$(__prompt_version "Jupyter Lab" $JUPYTERLAB_VERSION $jupyterlab_version)
    
    write_config "PYTHON_VERSION" "${python_version}"
    write_config "JUPYTERLAB_VERSION" "${jupyterlab_version}"
    
    msg "Setting Stack Versions Python:$python_version, JupyterLab:$jupyterlab_version"
}

# Building the Image
build_image() {

    image="python-jupyter-devenv:py${python_version}-jl${jupyterlab_version}"

    # --no-cache 
    docker build \
        --build-arg python_version="${python_version}" \
        --build-arg jupyterlab_version="${jupyterlab_version}" \
        -f env/jupyterlab.Dockerfile \
        -t $image .

    write_config "IMAGE_NAME" $image
    write_config "IMAGE_ID" $(get_image_id $image)

    msg "Built image: $image"
}

# See images available and either choose one to use or build a new one
# TODO: store name of image and id in config | issue #9
prompt_images() {
    local images=($(get_images))

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
