ARG python_version

# call the operating system to be used
FROM python:${python_version}-slim

SHELL ["/bin/bash", "-c"]
ENV SHELL=/bin/bash

# install the linux libraries needed
RUN apt-get update
RUN apt-get install -y git nodejs vim nano
# clean temp files
RUN apt-get clean

ARG jupyterlab_version

# update pip and install necessary packages
# TODO: install python-dotenv
RUN /usr/local/bin/python -m pip install --upgrade pip
RUN pip install pip-tools jupyterlab==${jupyterlab_version}

ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV PATH="/home/pyuser/.local/bin:$PATH"

# make a user
RUN useradd -rm -s /bin/bash -g root -G sudo pyuser
USER pyuser

# set a directory for the app
WORKDIR /home/pyuser/workspace

EXPOSE 8888

# launch the notebook as the entrypoint
CMD jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --notebook-dir=/home/pyuser/workspace --allow-root --NotebookApp.token='' --NotebookApp.password=''