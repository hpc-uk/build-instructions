Instructions for building Pynamic on ARCHER2
============================================

These instructions are for building Pynamic on the ARCHER2 full system (HPE Cray EX, AMD Zen2 7742).


Setup initial environment
-------------------------

```bash
PRFX=${HOME/home/work}/tools

PYNAMIC_LABEL=pynamic
PYNAMIC_ROOT=${PRFX}/${PYNAMIC_LABEL}
```

Remember to change the setting for `PRFX` to a path appropriate for your ARCHER2 project.


Download source code
--------------------

```bash
cd ${PRFX}

git clone https://github.com/LLNL/${PYNAMIC_LABEL}
```


Build a Pynamic benchmark
-------------------------

We will now build a Pynamic benchmark.
The first step is to move in to the `pyMPI` folder.

```bash
cd ${PYNAMIC_ROOT}/pynamic-pyMPI-2.6a1
```

Second, we need to amend the `mpi4py` makefile.

```bash
module -q restore
module -q load PrgEnv-gnu
module -q load cray-python

CRAY_PYTHON_VER=`echo $CRAY_PYTHON_LEVEL | cut -d'.' -f1-2`

sed -i "s:python-config:python${CRAY_PYTHON_VER}-config:g" Makefile.mpi4py
sed -i "s:CC = mpicc:CC = cc:g" Makefile.mpi4py
```

Next, we build a Pynamic benchmark for a particular library/module load, as indicated by
the `PYNAMIC` environment variables initialised in the Slurm submission script shown below.

```slurm
#!/bin/bash

#SBATCH --job-name=pynamic
#SBATCH --time=02:00:00
#SBATCH --ntasks=8
#SBATCH --account=<budget code>
#SBATCH --partition=serial
#SBATCH --qos=serial

module -q restore
module -q load PrgEnv-gnu
module -q load cray-python

CRAY_PYTHON_VER=`echo $CRAY_PYTHON_LEVEL | cut -d'.' -f1-2`

export PATH=${PWD}:${PATH}

export OMP_NUM_THREADS=1

PYNAMIC_SHARED_OBJS=900
PYNAMIC_MATH_MODS=350
PYNAMIC_FUNCS_PER_SHARED_OBJ=1250
PYNAMIC_FUNCS_PER_MATH_MOD=1250
PYNAMIC_FUNC_NAME_LEN=150

./config_pynamic.py ${PYNAMIC_SHARED_OBJS} ${PYNAMIC_FUNCS_PER_SHARED_OBJ} \
    -e -i ${CRAY_PYTHON_PREFIX}/include/python${CRAY_PYTHON_VER} \
    -j ${SLURM_NTASKS} -n ${PYNAMIC_FUNC_NAME_LEN} \
    -u ${PYNAMIC_MATH_MODS} ${PYNAMIC_FUNCS_PER_MATH_MOD} \
    --with-cc=cc \
    --with-python=${CRAY_PYTHON_PREFIX}/bin/python \
    --with-mpi4py
```

It will take some time to build all the objects and modules that make up the benchmark, therefore,
the `config_pynamic.py` script is executed from within a serial node job.

When the build has completed you should see something like the following text in the Slurm output file.

```bash
************************************************
summary of pynamic-mpi4py executable and 924 shared libraries
Size of aggregate total of shared libraries: 2.2GB
Size of aggregate texts of shared libraries: 769.5MB
Size of aggregate data of shared libraries: 18.4MB 
Size of aggregate debug sections of shared libraries: 1.1GB
Size of aggregate symbol tables of shared libraries: 45.5MB
Size of aggregate string table size of shared libraries: 310.4MB 
************************************************ 
```

You can find further details on how to build Pynamic benchmarks in the 
`${PYNAMIC_ROOT}/pynamic.README` file.
