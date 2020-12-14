```bash
PRFX=/lustre/sw
CMAKE_LABEL=cmake
CMAKE_VERSION=3.17.3
CMAKE_NAME=${CMAKE_LABEL}-${CMAKE_VERSION}

wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/${CMAKE_NAME}.tar.gz
tar -xzf ${CMAKE_NAME}.tar.gz
rm ${CMAKE_NAME}.tar.gz
cd ${CMAKE_NAME}

module load gcc/6.3.0
export OPENSSL_ROOT_DIR=${PRFX}/openssl/1.1.1g

./configure CC=gcc CXX=g++ --prefix=${PRFX}/${CMAKE_LABEL}/${CMAKE_VERSION}
gmake
gmake install
gmake clean
```