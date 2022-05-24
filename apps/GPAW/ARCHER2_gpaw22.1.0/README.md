# ARCHER2 GPAW version 22.1.0

Arrange the four accompanying files in a suitable location on
e.g.,`/work`
```
kevin@ln01:> ls
build_gpaw.sh  build_libxc.sh  siteconfig.py  slurm.sh
```

Run the script to build `libxc`:
```
kevin@ln01:> bash ./build_libxc.sh
```
which will use the current directory as the install location.

Run the script to build `GPAW`:
```
kevin@ln01:> bash ./build_gpaw.sh
```
which will install in the same location. At the moment the GPAW script
requires that the `libxc` install location and the GPAW install
location must be the same.

## GPAW data

One needs atomic potential information from GPAW. So, in the same location,
```
kevin@ln01:> wget https://wiki.fysik.dtu.dk/gpaw-files/gpaw-setups-0.9.20000.tar.gz
kevin@ln01:> tar xf gpaw-setups-0.9.20000.tar.gz 

```

## Run time

The location of both `libxc` and `GPAW` should be added to the
`PATH` and `LD_LIBRARY_PATH`, e.g.,
```
export my_prefix=$(pwd)
export PATH=${PATH}:${my_prefix}/bin
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${my_prefix}/lib
export GPAW_SETUP_PATH=${my_prefix}/gpaw-setups-0.9.20000
```

An appropriate batch script might be (again, assuming the same location
on `/work`):

```
#!/bin/bash

#SBATCH --time=00:02:00
#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --partition=standard
#SBATCH --qos=short
#SBATCH --export=none

module load PrgEnv-gnu
module load cray-python
module load cray-fftw

export MY_PREFIX=$(pwd)
export LIBXC_DIR=${MY_PREFIX}
export GPAW_DIR=${MY_PREFIX}
export GPAW_SETUP_PATH=${GPAW_DIR}/gpaw-setups-0.9.20000

export PATH=${GPAW_DIR}/bin:${PATH}
export LB_LIBRARY_PATH=${GPAW_DIR}/lib:${LIBXC_DIR}/lib:${LD_LIBRARY_PATH}
export PYTHONPATH=${GPAW_DIR}/lib/python3.8/site-packages:${PYTHONPATH}

export OMP_NUM_THREADS=1

srun --ntasks=8 gpaw test
```
The output appears in a file `test.txt` in the working directory.
This can be run using the accompanying copy `sbatch slurm.sh`.

Details of parallelisation will depend on the problem size (number of
k-points, bands etc available).


Thanks to Alexander Bagger for help with the example submission script.
