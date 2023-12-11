Instructions for installing MPFR 4.2.1 on Cirrus
================================================

These instructions show how to install MPFR 4.2.1 for use on Cirrus.


Setup initial environment
-------------------------

```
PRFX=/path/to/work # e.g., /mnt/lustre/indy2lfs/sw

MPFR_LABEL=mpfr
MPFR_VERSION=4.2.1
MPFR_NAME=${MPFR_LABEL}-${MPFR_VERSION}
MPFR_ROOT=${PRFX}/${MPFR_LABEL}
```

Remember to change the setting for `PRFX` to a path appropriate for your project.


Download the GMP library source code
------------------------------------

```
mkdir -p ${MPFR_ROOT}
cd ${MPFR_ROOT}

wget https://www.mpfr.org/${MPFR_LABEL}-current/${MPFR_NAME}.tar.gz
tar -xvzf ${MPFR_NAME}.tar.gz
rm ${MPFR_NAME}.tar.gz

cd ${MPFR_NAME}
```


Build the GMP library using GNU compiler
----------------------------------------

```
module load gcc/8.2.0
module load gmp/6.3.0-gcc

CC=gcc CXX=g++ FC=gfortran ./configure --prefix=${MPFR_ROOT}/${MPFR_VERSION}-gcc

make -j 8
make -j 8 install
make -j 8 clean

module unload gmp/6.3.0-gcc
module unload gcc/8.2.0
```


Build the GMP library using Intel compiler
------------------------------------------

```
module load intel-20.4/compilers
module load gmp/6.3.0-intel

CC=icc CXX=icpc FC=ifort ./configure --prefix=${MPFR_ROOT}/${MPFR_VERSION}-intel

make -j 8
make -j 8 install
make -j 8 clean

module unload gmp/6.3.0-intel
module unload intel-20.4/compilers
```
