Instructions for compiling Mesa 23.3.3 on ARCHER2
=================================================

These instructions are for compiling Mesa 23.3.3 on ARCHER2 (HPE Cray EX, AMD Zen2 7742) using the GCC 11 compilers.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., PRFX=/work/y07/shared/libs/core
MESA_LABEL=mesa
MESA_VERSION=23.3.3
MESA_NAME=${MESA_LABEL}-${MESA_VERSION}
MESA_ROOT=${PRFX}/${MESA_LABEL}
MESA_INSTALL=${MESA_ROOT}/${MESA_VERSION}

mkdir -p ${MESA_ROOT}
cd ${MESA_ROOT}

module -q load PrgEnv-gnu
module -q load cray-python
module -q load cmake
```


Install LLVM
------------

```bash
LLVM_LABEL=llvm
LLVM_VERSION=16.0.0
LLVM_NAME=${LLVM_LABEL}-${LLVM_VERSION}

cd ${MESA_ROOT}
mkdir -p ${LLVM_LABEL}
cd ${LLVM_LABEL}

wget https://github.com/llvm/llvm-project/releases/download/llvmorg-$LLVM_VERSION/cmake-${LLVM_VERSION}.src.tar.xz
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
      -DCMAKE_INSTALL_PREFIX=${MESA_INSTALL}/llvm   \
      -DLLVM_BUILD_LLVM_DYLIB=ON                    \
      -DLLVM_ENABLE_RTTI=ON                         \
      -DLLVM_INSTALL_UTILS=ON                       \
      -DLLVM_TARGETS_TO_BUILD=X86                   \
      -DLLVM_INCLUDE_BENCHMARKS=OFF \      
      ../

make -j 8 install
```


Setup Python environment for Mesa build
---------------------------------------

```bash
cd ${MESA_ROOT}

export PYTHONUSERBASE="$(MESA_ROOT)/.local"
export PATH=${PYTHONUSERBASE}/bin:${PATH}

pip install --user meson
pip install --user ninja
pip install --user mako
```


Install Mesa
------------

```bash
cd ${MESA_ROOT}

wget https://archive.mesa3d.org/${MESA_NAME}.tar.xz
tar vxf ${MESA_NAME}.tar.xz
rm ${MESA_NAME}.tar.xz

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MESA_INSTALL}/llvm/lib
export PATH=${PATH}:${MESA_INSTALL}/llvm/bin

cd ${MESA_NAME}

CC=cc CXX=CC meson build -Dprefix="${MESA_INSTALL}" \
        -Degl=disabled \
        -Dopengl=true \
        -Dgles1=disabled \
        -Dgles2=disabled \
        -Dgallium-va=disabled \
        -Dgallium-vdpau=disabled \
        -Dshared-glapi=enabled \
        -Dllvm=enabled \
        -Dshared-llvm=enabled \
        -Dgallium-drivers=swrast \
        -Ddri3=disabled \
        -Dgbm=disabled \
        -Dglx=disabled \
        -Dosmesa=true \
        -Dvulkan-drivers='' \
        -Dplatforms=x11

ninja -j 8 -C build
ninja -C build install
```
