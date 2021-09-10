# ORCA installation instructions

Dependencies:
 - OpenMPI 3.1.4
 - GNU compiler (required by OpenMPI)

## Build OpenMPI

```
INSTALL_DIR=/work/gid/gid/uid/sw/openmpi

module restore -s PrgEnv-gnu
wget https://download.open-mpi.org/release/open-mpi/v3.1/openmpi-3.1.4.tar.gz
tar xf openmpi-3.1.4.tar.gz
cd openmpi-3.1.4
mkdir build
cd build
../configure CC=gcc CXX=g++ F77=gfortran FC=gfortran --prefix=$INSTALL_DIR
make
make install

export PATH=$PATH:$INSTALL_DIR
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$INSTALL_DIR
```

## Install ORCA 
1. Download `orca_4_2_1_linux_x86-64_shared_openmpi314.tar.xz` from the ORCA website.
2. Untar the file:
   ```
   tar xf orca_4_2_1_linux_x86-64_shared_openmpi314.tar.xz
   ```
3. Set the path to the ORCA binaries and libraries:
   ```
   export orcadir=/path/to/orca/orca_4_2_1_linux_x86-64_openmpi314
   export PATH=$orcadir:$PATH
   export LD_LIBRARY_PATH=$orcadir:$LD_LIBRARY_PATH
   ```

Further instructions can be found here:
https://sites.google.com/site/orcainputlibrary/setting-up-orca
