#!/bin/bash

# See also https://www.numpy.org/devdocs/user/building.html

# python-compute/3.6.0_gcc6.1.0 switches to PrgEnv-gnu and unloads
# xalt
module load python-compute/3.6.0_gcc6.1.0
# Use the default Libsci.  site.cfg.bash sets this correctly in site.cfg-libsci
./site.cfg.bash
# These environment variables should have an effect (and override
# site.cfg), but don't.
export BLAS=$CRAY_LIBSCI_PREFIX_DIR/lib/libsci_gnu_mp.so
export LAPACK=$BLAS

module list &> module.log
which python3
python3 --version

export CRAYPE_LINK_TYPE=dynamic
prefix=/work/y07/y07/cse/numpy/1.16.2-python3.6.0-libsci_build1
# setup.py install doesn't create this directory.
mkdir -p $prefix/lib/python3.6/site-packages
(
    cd numpy-1.16.2
    cp -p ../site.cfg-libsci site.cfg
    python3 setup.py build --fcompiler=gnu95 &> ../build.log
    # The PYTHONPATH needs to be set before setup.py install.
    export PYTHONPATH=$prefix/lib/python3.6/site-packages:$PYTHONPATH
    python3 setup.py install --prefix=$prefix &> ../install.log
)
