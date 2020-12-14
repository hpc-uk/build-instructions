#!/bin/bash
# python-compute/3.6.0_gcc6.1.0 switches to PrgEnv-gnu
module load python-compute/3.6.0_gcc6.1.0
module load numpy
module load scipy
module list &> module.log
which python3
python3 --version

prefix=/work/y07/y07/cse/ase/3.17.0_build2
pip3 install --upgrade --prefix=$prefix ase
