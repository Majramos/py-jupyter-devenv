ARG python_version

# call the operating system to be used
FROM python:${python_version}-slim

SHELL ["/bin/bash", "-c"]
ENV SHELL=/bin/bash

# install the linux libraries needed
RUN apt-get update
RUN apt-get install -y git vim nano
# clean temp files
RUN apt-get clean

# update pip and install necessary packages
RUN /usr/local/bin/python -m pip install --upgrade pip

ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV PATH="/home/pyuser/.local/bin:$PATH"

# make a user
RUN useradd -rm -s /bin/bash -g root -G sudo pyuser
USER pyuser

# set a directory for the app
WORKDIR /home/pyuser/workspace

# launch the notebook as the entrypoint
ENTRYPOINT ["/bin/bash"]