#!/bin/bash

version=$1

rm -f /data/wwwroot/dev.com
ln -s /data/devs/$version /data/wwwroot/dev.com