#!/bin/bash
docker build . -t jlab
docker run --rm -it -p 8888:8888 -v "${PWD}:/srv/project" jlab
