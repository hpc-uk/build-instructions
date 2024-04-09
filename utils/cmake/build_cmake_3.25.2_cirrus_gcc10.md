Instructions for building CMake 3.25.2 on Cirrus
================================================

These instructions are for building CMake 3.25.2 on Cirrus (Intel Xeon E5-2695, Broadwell) using GCC 10.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., /work/y07/shared/cirrus-software

CMAKE_LABEL=cmake
CMAKE_VERSION=3.25.2
CMAKE_NAME=${CMAKE_LABEL}-${CMAKE_VERSION}

mkdir -p ${PRFX}/${CMAKE_LABEL}
cd ${PRFX}/${CMAKE_LABEL}

module load gcc/10.2.0
export OPENSSL_ROOT_DIR=/work/y07/shared/cirrus-software/openssl/3.2.1
```

Remember to change the setting for `PRFX` to a path appropriate for your Cirrus project.


Download source code
--------------------

```bash
wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/${CMAKE_NAME}.tar.gz

tar -xzf ${CMAKE_NAME}.tar.gz

rm ${CMAKE_NAME}.tar.gz
cd ${CMAKE_NAME}
```


Configure and build CMake
-------------------------

```bash
./configure CC=gcc CXX=g++ --prefix=${PRFX}/${CMAKE_LABEL}/${CMAKE_VERSION}

gmake
gmake install
gmake clean
```
