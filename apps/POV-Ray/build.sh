#!/bin/bash 
  
# Download repository
git clone --single-branch --branch 3.7-stable https://github.com/POV-Ray/povray.git
cd povray/unix

# Setup environment
module load gcc
module load boost/1.73.0
module load zlib
module load libpng

# Run prebuild script
./prebuild.sh

cd ../

# Run configure script
./configure --prefix=./ COMPILED_BY=$USER --with-boost=/lustre/sw/boost/1.73.0 --with-boost-libdir=/lustre/sw/boost/1.73.0/lib

# Compile 
make check install


