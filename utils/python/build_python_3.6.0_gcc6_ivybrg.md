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
export CFLAGS=-fopenmp
export LDFLAGS=-fopenmp
```

OpenMP is required for both compiling and linking otherwise importing the build of NumPy linked against
LibSci will fail on compute nodes.

Now configure:

```bash
./configure --prefix=/work/y07/y07/cse/python/3.6.0 --enable-shared --enable-optimizations
```

Build, Test, and Install
------------------------

Make will build and run tests:

```bash
make
make install
```

(Parallel make with '-j 8' failed due to forking too many processes.)

