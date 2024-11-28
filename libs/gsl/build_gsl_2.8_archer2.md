Instructions for installing GSL 2.8.0 on ARCHER2
================================================

These instructions show how to install GSL 2.8.0 for use on ARCHER2 (HPE Cray EX, AMD Zen2 7742).


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., PRFX=/mnt/lustre/a2fs-work4/work/y07/shared/libs/core
GSL_LABEL=gsl
GSL_VERSION=2.8
GSL_NAME=${GSL_LABEL}-${GSL_VERSION}
```

Remember to change the setting for `PRFX` to a path appropriate for your ARCHER2 project.


Download the GSL library source code
------------------------------------

```bash
mkdir -p ${PRFX}/${GSL_LABEL}
cd ${PRFX}/${GSL_LABEL}

rm -rf ${GSL_NAME}
wget http://mirror.koddos.net/gnu/${GSL_LABEL}/${GSL_NAME}.tar.gz
tar -xzf ${GSL_NAME}.tar.gz
rm ${GSL_NAME}.tar.gz
cd ${GSL_NAME}
```


Build the GSL library for all three ARCHER2 programming environments
--------------------------------------------------------------------

```bash
PE_RELEASE=22.12


module -q restore
module -q load cpe/${PE_RELEASE}
module -q load PrgEnv-cray

PE_NAME=${PE_MPICH_FIXED_PRGENV}
PE_VERSION=$(eval echo "\${PE_MPICH_GENCOMPILERS_${PE_NAME}}")

./configure CC=cc --prefix=${PRFX}/${GSL_LABEL}/${GSL_VERSION}/${PE_NAME}/${PE_VERSION}

make
make check
make install
make clean


module -q restore
module -q load cpe/${PE_RELEASE}
module -q load PrgEnv-gnu

PE_NAME=${PE_MPICH_FIXED_PRGENV}
PE_VERSION=$(eval echo "\${PE_MPICH_GENCOMPILERS_${PE_NAME}}")

./configure CC=cc CFLAGS="-ansi -pedantic -fshort-enums -fno-common -g -O4" --prefix=${PRFX}/${GSL_LABEL}/${GSL_VERSION}/${PE_NAME}/${PE_VERSION}

make
make check
make install
make clean


module -q restore
module -q load cpe/${PE_RELEASE}
module -q load PrgEnv-aocc

PE_NAME=${PE_MPICH_FIXED_PRGENV}
PE_VERSION=$(eval echo "\${PE_MPICH_GENCOMPILERS_${PE_NAME}}")

./configure CC=cc --prefix=${PRFX}/${GSL_LABEL}/${GSL_VERSION}/${PE_NAME}/${PE_VERSION}

make
make check
make install
make clean
```
