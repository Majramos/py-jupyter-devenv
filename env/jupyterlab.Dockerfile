ARG python_version

# call the operating system to be used
FROM python:${python_version}-slim

# Install the linux libraries needed and java
RUN apt-get update && apt-get clean
# git and pyodbc build dependencies
RUN apt-get install -y gcc+ g++ unixodbc-dev git nodejs

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

# remove stuff not needed to save space, nodejs
# RUN apt-get remove -y git nodejs && apt-get clean

ENV PIP_DISABLE_PIP_VERSION_CHECK=1

# set a directory for the app
WORKDIR /workspace

EXPOSE 8888

# launch the notebook as the entrypoint
CMD jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --notebook-dir=/workspace --allow-root --NotebookApp.token='' --NotebookApp.password=''