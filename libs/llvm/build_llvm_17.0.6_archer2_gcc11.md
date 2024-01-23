Instructions for compiling LLVM 17.0.6 on ARCHER2
=================================================

These instructions are for compiling LLVM 17.0.6 on ARCHER2 (HPE Cray EX, AMD Zen2 7742) using the GCC 11 compilers.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., PRFX=/work/y07/shared/libs/core
LLVM_LABEL=llvm
LLVM_VERSION=17.0.6
LLVM_NAME=${LLVM_LABEL}-${LLVM_VERSION}
LLVM_ROOT=${PRFX}/${LLVM_LABEL}
LLVM_INSTALL=${LLVM_ROOT}/${LLVM_VERSION}

mkdir -p ${LLVM_ROOT}

module -q load PrgEnv-gnu
module -q load cray-python
module -q load cmake
```


Install LLVM
------------

```bash
cd ${LLVM_ROOT}

wget https://github.com/llvm/llvm-project/releases/download/llvmorg-${LLVM_VERSION}/cmake-${LLVM_VERSION}.src.tar.xz
tar xvf cmake-${LLVM_VERSION}.src.tar.xz
rm cmake-${LLVM_VERSION}.src.tar.xz
mv cmake-${LLVM_VERSION}.src cmake

wget https://github.com/llvm/llvm-project/releases/download/llvmorg-${LLVM_VERSION}/third-party-${LLVM_VERSION}.src.tar.xz
tar xvf third-party-${LLVM_VERSION}.src.tar.xz
rm third-party-${LLVM_VERSION}.src.tar.xz
mv third-party-${LLVM_VERSION}.src third-party

wget https://github.com/llvm/llvm-project/releases/download/llvmorg-${LLVM_VERSION}/${LLVM_NAME}.src.tar.xz
tar vxf ${LLVM_NAME}.src.tar.xz
rm ${LLVM_NAME}.src.tar.xz

mv ${LLVM_NAME}.src ${LLVM_NAME}
cd ${LLVM_NAME}

mkdir build
cd build

cmake -DCMAKE_BUILD_TYPE=Release                    \
      -DCMAKE_INSTALL_PREFIX=${LLVM_INSTALL}/llvm   \
      -DLLVM_BUILD_LLVM_DYLIB=ON                    \
      -DLLVM_ENABLE_RTTI=ON                         \
      -DLLVM_INSTALL_UTILS=ON                       \
      -DLLVM_TARGETS_TO_BUILD=X86                   \
      -DLLVM_INCLUDE_BENCHMARKS=OFF \      
      ../

make -j 8 install
make clean
```
