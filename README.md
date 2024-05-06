# py-jupyter-devenv

<div align="center">

![GitLab Release](https://img.shields.io/gitlab/v/release/majramos%2Fpy-jupyter-devenv?sort=date&date_order_by=released_at&label=latest%20release)
![GitLab Tag](https://img.shields.io/gitlab/v/tag/majramos%2Fpy-jupyter-devenv?sort=date&label=latest%20tag)
![GitLab Last Commit](https://img.shields.io/gitlab/last-commit/majramos%2Fpy-jupyter-devenv?ref=dev)
![GitLab License](https://img.shields.io/gitlab/license/majramos%2Fpy-jupyter-devenv?color=008080)

</div>

Setup a python with jupyter lab container and configurations

This library allows to build images and create/run containers

The images built are named **python-jupyter-devenv:pyX.Y.Z-jlX.Y.Z**

You may adapt Dockerfile at /env/scripts/jupyterlab.Dockerfile


## Features
- Creates a fully contained python development environment with jupyterlab
- Mounts local directory as volume


## Installation

use git to repo to a directory of your choosing and run install.sh to remove files not needed
```bash
git clone --depth=1 https://gitlab.com/majramos/py-jupyter-devenv.git && py-jupyter-devenv/install.sh
```

follow through installation steps to rename the directory or to adapt a existing project  
you may choose to create a new folder and keep the py-jupyter-devenv folder

finally move in to the directory
```bash
cd ./<name of my project>
```

can also just clone the repo and copy the "env" directory


## Usage

In your project directory you can call the scripts to get usage
```bash
env/image --help
```
or
```bash
env/container --help
```


## Defaults

`PYTHON_VERSION=^3.11`

`JUPYTERLAB_VERSION=^4.1`


## Files

/env/scripts/config
- configuration variables

/env/scripts/jupyterlab.Dockerfile
- File for creating docker image

/install.sh
- For when cloning repo, installation procedure


## Roadmap

look in milestones


## License

[GPLv3](https://choosealicense.com/licenses/gpl-3.0/)


## Authors

[@marcoramos](https://marcoramos.me)


## Acknowledgements

[Docker](https://www.docker.com/)

[Jupyter Lab](https://jupyter.org/)

[Python](https://www.python.org/)
