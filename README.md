# py-jupyter-devenv

Setup a python with jupyter lab container and configurations

## Installation

```bash 
git clone --depth=1 https://github.com/Majramos/py-jupyter-devenv.git && py-jupyter-devenv/install.sh
```

## Usage/Examples

rename the cloned repository to a name of your liking and go into the folder
```bash
mv ./py-jupyter-devenv ./<name of my project>
cd ./<name of my project>
```

In your project folder you can call the script
```bash
Usage: ./env/dev [-h | --help] [-v | --verbose] [-s | --skip] [-b | --build]
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
        Build a new image using default versions
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
```

## Roadmap
 - Add way to change volume mount in case of workspace folder changes location
 - Add option to build workspace folder structure
 - Add option to change .Dockerfile settings
 
## License

[![GPLv3 License](https://img.shields.io/badge/License-GPL%20v3-yellow.svg)](https://opensource.org/licenses/)

[GPLv3](https://choosealicense.com/licenses/gpl-3.0/)

## Authors

- [@marcoramos](https://github.com/Majramos)
