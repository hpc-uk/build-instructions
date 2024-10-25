# Building MOOSE on ARCHER2

Uses the GCC compilers. XDR functionality disabled (XDA is preferred by MOOSE anyway so 
should not be an issue).

Based on instructions at:

 - https://mooseframework.inl.gov/getting_started/installation/hpc_install_moose.html

## Setup environment

```
module load PrgEnv-gnu
module load cray-python
module load cmake

export CC=cc CXX=CC FC=ftn


```

## Obtain the source code

```
git clone https://github.com/idaholab/moose.git
cd moose
git checkout master
```

## Modify the configuration options for libmesh

ARCHER2 does not have the `libtirpc` headers installed so we need to disable the 
optional XDR functionality (preferred XDA functionality will still be available).

Edit the `scripts/configure_libmesh.sh` file and **remove** the following line
(line 68 of the script in the version we tested):

```
               --enable-xdr-required \
```

## Build the dependencies

From the base `moose` source directory

```
cd scripts

export MOOSE_JOBS=6 METHODS=opt

./update_and_rebuild_petsc.sh CC=cc CXX=CC FC=ftn
./update_and_rebuild_libmesh.sh CC=cc CXX=CC FC=ftn
./update_and_rebuild_wasp.sh
```

## Build MOOSE

From the base `moose` source directory

```
cd test
make -j 6
```

## Test MOOSE

From the `moose/test` source directory after building the software.

Create a job submission script with the following contents (change the budget to
one that you have access to on ARCHER2). Once the file is created, submit with
`sbatch` .

```
#!/bin/bash --login

#SBATCH --job-name=moosetest
#SBATCH --nodes=1
#SBATCH --tasks-per-node=8
#SBATCH --cpus-per-task=1
#SBATCH --time=12:0:0
#SBATCH --account=[replace with valid account]
#SBATCH --partition=standard
#SBATCH --qos=standard

# Setup the batch environment
module load PrgEnv-gnu
module load cmake
module load cray-python

# Setup the correct path for MOOSE required libraries
export LD_LIBRARY_PATH=/path/to/moose/petsc/arch-moose/$LD_LIBRARY_PATH

export OMP_NUM_THREADS=1

export MOOSE_MPI_COMMAND="srun --unbuffered --hint=nomultithread --distribution=block:block"

./run_tests -j8 -t
```


