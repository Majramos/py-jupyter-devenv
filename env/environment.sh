#!/usr/bin/env bash


# check if is running inside the container
is_in_container() {
    if [ -f /.dockerenv ]; then
        return 0
    else
        return 1
    fi
}


# install the requirements for pyodbc 
dep_pyodbc() {
    if [ -f /.dockerenv ]; then
        eval "apt-get install -y gcc+ g++ unixodbc-dev"
    else
        echo 
        die "Currently not in a container environment"
    fi
}