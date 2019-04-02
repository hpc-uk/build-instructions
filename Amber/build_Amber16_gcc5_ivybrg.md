Instructions for compiling Amber 16 for ARCHER using GCC 5 compilers
====================================================================

We assume that you have obtained the Amber source code from the Amber website.

__Note:__ As this is a dynamic build you should install Amber in the 
`\work` file system on ARCHER so the required librarie s are available on 
the compute nodes at runtime.

__Note:__ The whole build and install process should take a couple of 
hours.

Unpack the Amber source code
----------------------------

Make sure you are in your `/work` directory on ARCHER.

Create a directory to hold Amber and set the striping to 1 to give best 
performance:

```bash
mkdir Amber
lfs setstripe -c 1 Amber
```

Unpack the source:

```bash
cd Amber
tar -xjvf Amber16.tar.bz2
tar -xjvf AmberTools16.tar.bz2
```

Compile Serial Version for PP nodes
-----------------------------------

Log into an ARCHER post processing node to build the serial code so it
is compatible with the older processors and move to the correct 
directory:

```bash
ssh espp1
cd /work/path/to/Amber/source/code
export AMBERHOME=$PWD
```

### Setup correct modules and specify dynamic build ###

Switch to the GCC compilers and load the NetCDF module: 

```bash
module swap PrgEnv-cray PrgEnv-gnu
module add cray-netcdf
```

Set the environment variable to specify dynamic build (rather than default
static build):

```bash
export CRAYPE_LINK_TYPE=dynamic
```

### Configure and Build Serial Version ###

Configure Amber using the following parameters:

```bash
./configure --with-netcdf /opt/cray/netcdf/4.3.3.1/GNU/51 -nomtkpp -crayxt5 -nofftw3 gnu
```

Build and install:

```bash
make install
```

Compile Parallel Version for compute  nodes
-------------------------------------------

Make sure that you are on an ARCHER login node rather than a PP node (log
out of the PP node if you are following on directly from the serial
install above).

Make sure you switch to the location of the Amber source code:

```bash
cd /work/path/to/Amber/source/code
export AMBERHOME=$PWD
```

### Setup correct modules and specify dynamic build ###

Switch to the GCC compilers and load the Python and NetCDF modules:

```bash
module swap PrgEnv-cray PrgEnv-gnu
module add python-compute
module add cray-netcdf
```

Set the environment variable to specify dynamic build (rather than default
static build):

```bash
export CRAYPE_LINK_TYPE=dynamic
```

### Configure and Build Parallel Version ###

Make sure build process uses the compiler wrapper scripts:

```bash
export MPI_HOME=$MPICH_DIR
export MPICC=cc
export MPICXX=CC
```

Configure Amber using the following parameters:

```bash
./configure -mpi --with-python /work/y07/y07/cse/python/2.7.6/bin/python2.7 \
   --with-netcdf /opt/cray/netcdf/4.3.3.1/GNU/51 -nomtkpp -crayxt5 -nofftw3 \
   gnu
```

Build and install:

```bash
make install
```

