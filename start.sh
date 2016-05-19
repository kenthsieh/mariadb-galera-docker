#!/bin/bash

if [ -f "/mysql-setup.sh" ]; then
    /mysql-setup.sh
    mv /mysql-setup.sh /root
fi

