Instructions for installing GMP 6.2.1 on Cirrus
================================================

These instructions show how to install GMP 6.2.1 for use on Cirrus.


Setup initial environment
-------------------------

```
PRFX=/work/[project-code/[project-code]/[user-name]
GMP_LABEL=gmp
GMP_VERSION=6.2.1
GMP_NAME=${GMP_LABEL}-${GMP_VERSION}
```

Remember to change the setting for `PRFX` to a path appropriate for your project.


Download the GMP library source code
------------------------------------

```
mkdir -p ${PRFX}/${GMP_VERSION}-mpt
cd ${PRFX}/${GMP_VERSION}-mpt

wget http://mirror.koddos.net/gnu/${GMP_LABEL}/${GMP_NAME}.tar.bz2
tar -xf ${GMP_NAME}.tar.bz2
cd ${GMP_NAME}
```


Build the GMP library
----------------------

```
module load mpt/2.25
module load gcc/10.2.0

./configure CC=cc --prefix=${PRFX}/${GMP_VERSION}-mpt/
make
make check
make install
make clean
```
