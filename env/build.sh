#!/bin/bash

spath="$(dirname "${BASH_SOURCE[0]}")"

source "${spath}/container.sh"

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
