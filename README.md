# py-jupyter-devenv

Setup a python with jupyter lab container and configurations

This library allows to build images and create/run containers

The images built are named **jupyterlab:py<version>-jl<version>**

Currently creates containers using a highly customized docker image.
You may adapt it at /env/jupyterlab.Dockerfile

![License](https://img.shields.io/github/license/Majramos/py-jupyter-devenv)
![Top languague](https://img.shields.io/github/languages/top/Majramos/py-jupyter-devenv)
![latest tag](https://img.shields.io/github/v/tag/Majramos/py-jupyter-devenv)
![latest commit](https://img.shields.io/github/last-commit/Majramos/py-jupyter-devenv)


## Features
- Creates a fully contained dpython development environment with jupyterlab
- Setups my jupyterlab user settings and installs a custom theme and extensions
- Mounts volume using a local folder


## Installation

use git to repo to a folder of your choosing and run install.sh to remove files not needed
```bash
git clone --depth=1 https://github.com/Majramos/py-jupyter-devenv.git && py-jupyter-devenv/install.sh
```

rename the cloned repository to a name of your liking and go into the folder
```bash
mv ./py-jupyter-devenv ./<name of my project>
cd ./<name of my project>
```

## Usage

In your project folder you can call the script
```bash
Usage: env/setup [-h | --help] [-v | --verbose] [-s | --skip] [-b | --build]
                 [-d | --default] [-c | --create] [-r | --run] [--lc] [--li]
                 [--show-defaults]
DESCRIPTION
    Setup a python+jupyter development environment using containers trough Docker
OPTIONS:
    -h, --help
        Print this help and exit.
    -v, --verbose
        Verbose output
    -s, --skip
        Skip checking if docker is installed and initialized
    -b, --build
        Build a new image skipping the lookup for new images
    -d, --default
        Build a new image using default stack versions
        Creates container using name of the parent folder and a random port
        Use --show-defaults to list the defaults values
    -c, --create
        Create a container from a existing image
    -r, --run
        Run a existing container
    --li
        List available images with python and jupyterlab
    --lc
        List available containers with python and jupyterlab
    --show-defaults
        List stack version used (python and jupyter lab)
AUTHOR
    Marco Ramos
```


## Defaults

`PYTHON_VERSION=3.9.12`

`JUPYTERLAB_VERSION=3.2.9`

`EXECUTETIME_VERSION=2.1.0`


# Files

/env/container_name
- File with the name of the container created

/env/jupyterlab.Dockerfile
- File for creating docker image

/install.sh
- For when cloning repo, file cleaning


## Roadmap
Add way to change volume mount in case of workspace folder changes location

Add option to build workspace folder structure

Add option to change .Dockerfile settings/build the Dockerfile


## License

[GPLv3](https://choosealicense.com/licenses/gpl-3.0/)


## Authors

[@marcoramos](https://github.com/Majramos)


## Acknowledgements

[Docker](https://www.docker.com/)
[Jupyter Lab](https://jupyter.org/)
[jupyterlab-execute-time](https://github.com/deshaw/jupyterlab-execute-time)
[jupyter lab theme (original)](https://github.com/AllanChain/jupyterlab-theme-solarized-dark)
[jupyter lab theme (adapted)](https://github.com/Majramos/jupyterlab-theme-solarized-dark)

