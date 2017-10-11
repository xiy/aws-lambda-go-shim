#!/bin/bash

echo "Downloading and extracting libvips 8.5.8 source..."
wget -qO- https://github.com/jcupitt/libvips/releases/download/v8.5.8/vips-8.5.8.tar.gz | bsdtar -xvf-

echo "Building libvips for Amazon Linux..."
cd vips-8.5.8
./configure && make && make install

echo "Finished building libvips! Removing junk..."

cd ..
rm -rf vips-8.5.8
