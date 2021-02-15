# AmberTools20 (no Amber)

You need to fill in the web form at
https://ambermd.org/GetAmber.php#ambertools
to download the source code bundle `AmberTools20.tar.bz2`.

From your `/work` directory, unzip the file, and go into the generated directory:

```
tar -xvf AmberTools20.tar.bz
cd amber-src
```

## Build serial version

From a login node, run the following:

```
module restore -s PrgEnv-gnu
module switch gcc gcc/9.3.0
module load cray-python
module load cray-netcdf
module load cray-hdf5

./configure --with-python $CRAY_PYTHON_PREFIX/bin/python \
            --with-netcdf $NETCDF_DIR -noX11 gnu

make -j 8 install
```

## Parallel version

The parallel version needs to be compiled from an interactive shell. You can 
load one by running the following command (remembering to input the appropriate 
account code):

```
srun --account=<account> --partition=standard --qos=short \
     --reservation=shortqos --nodes=1 --time=0:20:0 --pty /bin/bash
```

Once logged in, run the following commands:

```
module restore -s /etc/cray-pe.d/PrgEnv-gnu
module switch gcc gcc/9.3.0
module load cray-python
module load cray-netcdf
module load cray-hdf5

export MPI_HOME=$CRAY_MPICH_BASEDIR/gnu/9.1
export MPICC=cc
export MPICXX=CC
export FC=ftn
export MPIF90=ftn

./configure --with-python $CRAY_PYTHON_PREFIX/bin/python --with-netcdf $NETCDF_DIR -mpi -noX11 gnu
make -j 8 install
```

## Run time

On success, you may need to source the amber.sh script:

```
$ source ./amber20_src/amber.sh
```

to set the relevant environment variables to use AmberTools.

At run time, a consistent set of modules is required so that dynamic
libraries can be located:

```
module load cray-python
```

or you could place these commands in the `amber.sh` script.
