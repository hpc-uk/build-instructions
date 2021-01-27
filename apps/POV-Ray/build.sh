#!/bin/bash 

DIR_TO_INSTALL=$1
USER_EMAIL=$2
if [[ -z $DIR_TO_INSTALL ]];then
	echo "USAGE: ./build.sh <DIRECTORY-TO-INSTALL-TO> <USER-EMAIL>"  
	exit
fi
if [[ -z $USER_EMAIL ]];then
	echo "USAGE: ./build.sh <DIRECTORY-TO-INSTALL-TO> <USER-EMAIL>"  
	exit
fi
  
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
./configure --prefix=$DIR_TO_INSTALL COMPILED_BY=$USER_EMAIL --with-boost=/lustre/sw/boost/1.73.0 --with-boost-libdir=/lustre/sw/boost/1.73.0/lib

# Compile 
make check install


