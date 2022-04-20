ARG python_version

# call the operating system to be used
FROM python:${python_version}-slim

# install the linux libraries needed
RUN apt-get update
# git and pyodbc build dependencies
RUN apt-get install -y gcc+ g++ unixodbc-dev git nodejs
RUN apt-get clean

ARG jupyterlab_version
ARG executetime_version

# update pip and install necessary packages
RUN /usr/local/bin/python -m pip install --upgrade pip
RUN pip install pip-tools jupyterlab==${jupyterlab_version} jupyterlab-execute-time==${executetime_version}
# install theme
RUN pip install git+https://github.com/Majramos/jupyterlab-theme-solarized-dark
# setup jupyter lab configurations
RUN git clone https://github.com/Majramos/jupyterlab-settings.git
RUN chmod u+x ./jupyterlab-settings/install.sh && ./jupyterlab-settings/install.sh

ENV PIP_DISABLE_PIP_VERSION_CHECK=1

# set a directory for the app
WORKDIR /workspace

EXPOSE 8888

# launch the notebook as the entrypoint
CMD jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --notebook-dir=/workspace --allow-root --NotebookApp.token='' --NotebookApp.password=''