Instructions for installing GMP 6.3.0 on Cirrus
================================================

These instructions show how to install GMP 6.3.0 for use on Cirrus.


Setup initial environment
-------------------------

```
PRFX=/path/to/work  # e.g., PRFX=/work/y07/shared/cirrus-software

GMP_LABEL=gmp
GMP_VERSION=6.3.0
GMP_NAME=${GMP_LABEL}-${GMP_VERSION}
GMP_ROOT=${PRFX}/${GMP_LABEL}
```

Remember to change the setting for `PRFX` to a path appropriate for your project.


Download the GMP library source code
------------------------------------

```
mkdir -p ${GMP_ROOT}
cd ${GMP_ROOT}

wget http://mirror.koddos.net/gnu/${GMP_LABEL}/${GMP_NAME}.tar.bz2
tar -xf ${GMP_NAME}.tar.bz2
rm ${GMP_NAME}.tar.bz2

cd ${GMP_NAME}
```


Build the GMP library using GNU compiler
----------------------------------------

```
module load gcc/8.2.0

CC=gcc CXX=g++ FC=gfortran ./configure --prefix=${GMP_ROOT}/${GMP_VERSION}-gcc

make -j 8
make -j 8 install
make -j 8 clean

module unload gcc/8.2.0
```


Build the GMP library using Intel compiler
------------------------------------------

```
module load intel-20.4/compilers

CC=icc CXX=icpc FC=ifort ./configure --prefix=${GMP_ROOT}/${GMP_VERSION}-intel

make -j 8
make -j 8 install
make -j 8 clean

module unload intel-20.4/compilers
```
