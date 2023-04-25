# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] - YYYY-MM-DD

### Added
- store image name and id in config when creating
- base image dockerfile without jupyter lab

### Changed
- all config stored in one file (env/scripts/config)
- set to use bash as shell in container
- separate image from containers scritps
- app version moved from config to utils.sh
- image name to "python-jupyter-devenv" to avoid colision with jupyterlab own images

### Deprecated

### Removed
- remove file env/container_name
- support for python2
- auto open of web browser window
- detailed usage from README

### Fixed

### Security
- custom user instead of root user



## [0.1.2] - 2022-07-02

### Added
- Option to list container name and image name values

### Changed
- Renamed build stage to badge stage
- Configuration variables stored in file "env/config"
- Check updates compares number by number if theres is a new release

### Removed
- get-badge-info.sh
- update.sh
- option to update the package

### Fixed
- missing option in usage text


## [0.1.1] - 2022-06-30

### Added
- Option to stop containers
- Comments to functions
- environment.sh to store functionality related to container environment
- update.sh to store functionality related to updates and version
- Option to setup env in a existing folder
- Option to keep original cloned directory

### Changed
- README.md to add updated usage
- Replaced folder by directory in documentation and usage
- Installation to a step by step guided procedure


## [0.1.0] - 2022-04-20

### Added
- First release