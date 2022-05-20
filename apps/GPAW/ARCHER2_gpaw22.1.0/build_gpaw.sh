#!/usr/bin/env bash

# GPAW

export my_prefix=$(pwd)

module load PrgEnv-gnu
module load cray-python
module load cray-fftw

git clone -b 22.1.0 https://gitlab.com/gpaw/gpaw.git 
cd gpaw

cp ../siteconfig.py .
sed -i "s#LIBXC_PATH#${prefix}#" siteconfig.py

python setup.py build_ext
python setup.py install --prefix=${my_prefix}
