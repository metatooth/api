#!/bin/bash


if [ $# -ne 1 ]
then
    echo "usage: logotype.sh [color]"
    echo
    echo "  Makes the Meta Tooth LLC logotype."
    exit
fi

color=$1

convert -font GaramondNo8-Regular -pointsize 200 label:Meta meta.gif
convert -font GaramondNo8-Medium -pointsize 200 label:tooth tooth.gif
convert +append meta.gif tooth.gif metatooth.gif
convert metatooth.gif -transparent white metatooth.png
