#!/bin/bash

# See also http://scipy.github.io/devdocs/building

# python-compute/3.6.0_gcc6.1.0 switches to PrgEnv-gnu and unloads
# xalt.  The numpy module loads cray-libsci (which, in fact, is always
# loaded by default).
module load python-compute/3.6.0_gcc6.1.0
module load numpy/1.16.2-libsci_build1
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
prefix=/work/y07/y07/cse/scipy/1.2.1-python3.6.0-libsci_build1
# setup.py install doesn't create this directory.
mkdir -p $prefix/lib/python3.6/site-packages
(
    cd scipy-1.2.1
    cp -p ../site.cfg-libsci site.cfg
    python3 setup.py build --fcompiler=gnu95 &> ../build.log
    # The PYTHONPATH needs to be set before setup.py install.
    export PYTHONPATH=$prefix/lib/python3.6/site-packages:$PYTHONPATH
    python3 setup.py install --prefix=$prefix &> ../install.log
)
