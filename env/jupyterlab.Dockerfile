ARG python_version

# call the operating system to be used
FROM python:${python_version}-slim

# install the linux libraries needed
RUN apt-get update
# git and pyodbc build dependencies
RUN apt-get install -y git nodejs
# clean temp files
RUN apt-get clean

ARG jupyterlab_version

# update pip and install necessary packages
RUN /usr/local/bin/python -m pip install --upgrade pip
RUN pip install pip-tools jupyterlab==${jupyterlab_version}

ENV PIP_DISABLE_PIP_VERSION_CHECK=1

# set a directory for the app
WORKDIR /workspace

EXPOSE 8888

# launch the notebook as the entrypoint
CMD jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --notebook-dir=/workspace --allow-root --NotebookApp.token='' --NotebookApp.password=''