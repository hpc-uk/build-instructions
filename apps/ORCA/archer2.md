# ORCA installation instructions

Dependencies:
 - OpenMPI 4.1.x
 - GNU compiler (required by OpenMPI)

## Build OpenMPI

Download and expand a version of OpenMPI 4.1.x from the OpenMPI website. e.g. for OpenMPI 4.1.1:

```
wget https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-4.1.1.tar.gz
tar -xvf openmpi-4.1.1.tar.gz
cd openmpi-4.1.1
```

Setup the compile environment (define the install locatio nto a directory you have write access to:

```
OMPI_INSTALL_DIR=/work/gid/gid/uid/sw/openmpi

module load PrgEnv-gnu

PMI_HDRS_DIR=/usr/include/slurm
PMI_LIBS_DIR=/usr/lib64
OFI_ROOT=`pkg-config --variable=prefix libfabric`
```

Configure, build and install OpenMPI:

```
./configure CC=cc CXX=CC FTN=ftn \
    CFLAGS="-I${PMI_HDRS_DIR} -O2 -march=znver2 -mno-avx512f" LDFLAGS="-L${PMI_LIBS_DIR}" \
    --enable-mpi1-compatibility --enable-mpi-fortran --enable-mpi-interface-warning \
    --with-ofi=${OFI_ROOT} --with-pmi=${PMI_HDRS_DIR} --with-pmi-libdir=${PMI_LIBS_DIR} \
    --with-slurm --with-singularity \
    --prefix=$OMPI_INSTALL_DIR
    
make -j 8 clean
make -j 8
make -j 8 install
```


## Install ORCA 


1. Download `orca_5_0_3_linux_x86-64_shared_openmpi411.tar.xz` from the ORCA website.
2. Expand the archive:
   ```
   tar xf orca_5_0_3_linux_x86-64_shared_openmpi411.tar.xz
   ```
3. Set the path to the ORCA libraries and executables and to the OpenMPI libraries and executables:
   ```
   export orcadir=orca_5_0_3_linux_x86-64_shared_openmpi411
   export PATH=$orcadir:$PATH
   export LD_LIBRARY_PATH=$orcadir:$LD_LIBRARY_PATH
   
   export LD_LIBRARY_PATH=$OMPI_INSTALL_DIR/lib:$LD_LIBRARY_PATH
   export PATH=$OMPI_INSTALL_DIR/bin:$PATH
   ```

Further instructions can be found here:
https://sites.google.com/site/orcainputlibrary/setting-up-orca
