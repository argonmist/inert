#!/bin/bash

docker rmi argonhiisi/inert:ubuntu22
docker build -t argonhiisi/inert:ubuntu22 .
