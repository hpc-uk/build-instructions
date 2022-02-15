Instructions for building CMake 3.17.3 on Cirrus
================================================

These instructions are for building CMake 3.17.3 on Cirrus (Intel Xeon E5-2695, Broadwell) using GCC 6.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., /lustre/sw

CMAKE_LABEL=cmake
CMAKE_VERSION=3.17.3
CMAKE_NAME=${CMAKE_LABEL}-${CMAKE_VERSION}

mkdir -p ${PRFX}/${CMAKE_LABEL}
cd ${PRFX}/${CMAKE_LABEL}

module load gcc/6.3.0
export OPENSSL_ROOT_DIR=/lustre/sw/openssl/1.1.1g
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
