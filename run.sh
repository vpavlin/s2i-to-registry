#!/usr/bin/bash

if [ -n ${REBUILD} ]; then
    ./rebuild.sh
fi

if [ -n ${MOVE} ]; then
    ./move.sh
fi