#!/bin/sh

MYRTLE_DIR=$(dirname "$0")

while :
do
        ruby $MYRTLE_DIR/moaningmyrtle.rb
        sleep 5
done
