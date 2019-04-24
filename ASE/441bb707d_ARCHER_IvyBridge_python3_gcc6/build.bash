#!/bin/bash
# python-compute/3.6.0_gcc6.1.0 switches to PrgEnv-gnu
module load python-compute/3.6.0_gcc6.1.0
module load numpy/1.16.2-libsci_build1
module load scipy/1.2.1-libsci_build1
module list &> module.log
which python3
python3 --version

prefix=/work/y07/y07/cse/ase/441bb707d_build1
pip3 install --upgrade --prefix=$prefix git+https://gitlab.com/ase/ase.git@441bb707dafe03e2f864a442c350aa00d0553ba6
