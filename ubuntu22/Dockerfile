FROM ubuntu:22.04
ENV LANG=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive 
COPY bin/inert bin/yq /bin/helm /bin/kubectl /bin/rke /bin
RUN apt-get update && \
    apt install software-properties-common -y &&\
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-add-repository ppa:ansible/ansible && \
    apt install python3.9 python3.9-dev ansible vim git openssh-server -y
