# py-jupyter-devenv

Setup a python with jupyter lab container and configurations

This library allows to build images and create/run containers

The images built are named **jupyterlab:pyX.Y.Z-jlX.Y.Z**

You may adapt Dockerfile at /env/jupyterlab.Dockerfile


## Features
- Creates a fully contained python development environment with jupyterlab
- Setup with my jupyterlab user settings and a custom theme and extensions
- Mounts volume using a local folder


## Installation

use git to repo to a folder of your choosing and run install.sh to remove files not needed
```bash
git clone --depth=1 https://gitlab.com/majramos/py-jupyter-devenv.git && py-jupyter-devenv/install.sh
```

rename the cloned repository to a name of your liking and go into the folder
```bash
mv ./py-jupyter-devenv ./<name of my project>
cd ./<name of my project>
```

## Usage

In your project folder you can call the script
```bash
Usage: env/setup [-h | --help] [-v | --verbose] [-b | --build] [-d | --default]
                 [-c | --create] [-r | --run] [--skip-check] [--lc] [--li]
                 [--show-defaults] [--version] [--check-updates] [--update]
DESCRIPTION
    Setup a python+jupyter development environment using containers trough Docker
OPTIONS:
    -h, --help
        Print this help and exit.
    -v, --verbose
        Verbose output
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
    --skip-check
        Skip checking if docker is installed and initialized
    --li
        List available images with python and jupyterlab
    --lc
        List available containers with python and jupyterlab
    --show-defaults
        List stack version used (python and jupyter lab)
    --version
        Display version information
    --check-updates
        Checks for package updates
    --update
        Updates package
```


## Defaults

`PYTHON_VERSION=3.9.12`

`JUPYTERLAB_VERSION=3.2.9`


## Files

/env/container_name
- File with the name of the container created

/env/jupyterlab.Dockerfile
- File for creating docker image

/install.sh
- For when cloning repo, file cleaning


## Roadmap

look in milestones


## License

[GPLv3](https://choosealicense.com/licenses/gpl-3.0/)


## Authors

[@marcoramos](https://gitlab.com/majramos)


## Acknowledgements

[Docker](https://www.docker.com/)

[Jupyter Lab](https://jupyter.org/)

[Python](https://www.python.org/)
