# deal.II build instructions

deal.II is a library used by [ASPECT](https://aspect.geodynamics.org/) (among others).

Dependencies:
 - Trilinos (available on ARCHER2)
 - p4est


## Build p4est

```bash
wget https://p4est.github.io/release/p4est-2.2.tar.gz
tar xf p4est-2.2.tar.gz
cd p4est-2.2/doc
FC=ftn F77=ftn CC=cc CXX=CC ./p4est-setup.sh ../../p4est-2.2.tar.gz /work/y07/shared/libs/p4est
```

## Build deal.II

```bash
wget https://github.com/dealii/dealii/releases/download/v9.3.1/dealii-9.3.1.tar.gz
tar xf dealii-9.3.1.tar.gz
cd dealii-9.3.1
mkdir build
cd build

module restore -s PrgEnv-gnu
module load trilinos
module load cray-hdf5-parallel

CC=cc CXX=CC FC=ftn cmake -D CMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/work/y07/shared/deal.II/9.3.1-gcc10 -DTRILINOS_DIR=$TRILINOS_DIR -DP4EST_DIR=/work/y07/shared/libs/p4est -DDEAL_II_WITH_MPI=ON -DDEAL_II_CXX_FLAGS=-fopenmp -DDEAL_II_COMPONENT_EXAMPLES=OFF ..
make
make install
```
