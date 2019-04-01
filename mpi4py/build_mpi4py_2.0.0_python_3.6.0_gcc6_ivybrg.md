Python 3.6.0 using GCC 6.1.0 for ARCHER Compute Nodes
=====================================================

Download and Unpack
-------------------

```bash
wget https://www.python.org/ftp/python/3.6.0/Python-3.6.0.tgz
tar -xvf Python-3.6.0.tgz 
```

Configure
---------

Setup your environment:

```bash
module swap PrgEnv-cray PrgEnv-gnu
module swap gcc gcc/6.1.0 
module swap cray-mpich cray-mpich/7.4.3 
module load python-compute/3.6.0
module unload xalt
```

Edit `mpi.cfg` to add a section for ARCHER:

```
[ARCHER]
mpicc = gcc
mpicxx = g++
mpif90 = gfortran
libraries = mpich
mpi_dir              = /opt/cray/mpt/7.4.3/gni/mpich-gnu/5.1
include_dirs         = %(mpi_dir)s/include 
library_dirs         = %(mpi_dir)s/lib
runtime_library_dirs = %(mpi_dir)s/lib
```

Build, Test, and Install
------------------------

Build using correct Python

```bash
python3 setup.py build --mpi=ARCHER
python3 setup.py install --prefix=/work/y07/y07/cse/mpi4py/2.0.0-python3.6.0-mpich7.4.3
```

