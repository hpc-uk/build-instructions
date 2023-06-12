```bash
module load PrgEnv-gnu/8.3.3
module load cray-python/3.9.13.1
module load cmake/3.21.3

export MESA_VERSION=21.0.1
export MESA_INSTALL=/work/y07/shared/libs/core/mesa/${MESA_VERSION}
export LLVM_VERSION=12.0.1
```

# LLVM is required to build mesa.
# This appears to be version 12 because that was the version when first
# attempted. I haven't tried v13 or later... and I haven't confirmed
# the above statement, which is historical.
# tried v16, didn't compile -- new requirements/dependencies?


```bash
wget https://github.com/llvm/llvm-project/releases/download/llvmorg-${LLVM_VERSION}/llvm-${LLVM_VERSION}.src.tar.xz
tar -xf llvm-${LLVM_VERSION}.src.tar.xz

cd llvm-${LLVM_VERSION}.src

mkdir _build
cd _build

cmake                                         \
-DCMAKE_BUILD_TYPE=Release                    \
-DCMAKE_INSTALL_PREFIX=${MESA_INSTALL}/llvm   \
-DLLVM_BUILD_LLVM_DYLIB=ON                    \
-DLLVM_ENABLE_RTTI=ON                         \
-DLLVM_INSTALL_UTILS=ON                       \
-DLLVM_TARGETS_TO_BUILD=X86                   \
../
make -j 8 install
```

```bash
# For build ...
export PYTHONUSERBASE="$(pwd)/.local"
export PATH=${PYTHONUSERBASE}/bin:$PATH
pip install --user meson
pip install --user ninja
pip install --user mako

wget https://archive.mesa3d.org//mesa-${MESA_VERSION}.tar.xz
rm -rf mesa-${MESA_VERSION}
tar xf mesa-${MESA_VERSION}.tar.xz

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${MESA_INSTALL}/llvm/lib
export PATH=$PATH:${MESA_INSTALL}/llvm/bin

cd mesa-${MESA_VERSION}

CC=cc CXX=CC meson build -Dprefix="${MESA_INSTALL}/mesa" \
  -Degl=disabled -Dopengl=true -Dgles1=disabled -Dgles2=disabled \
  -Dgallium-va=disabled -Dgallium-xvmc=disabled -Dgallium-vdpau=disabled \
  -Dshared-glapi=enabled -Dllvm=enabled -Dshared-llvm=enabled \
  -Dgallium-drivers=swrast,swr -Ddri3=disabled -Ddri-drivers='' \
  -Dgbm=disabled -Dglx=disabled -Dosmesa=true -Dvulkan-drivers='' \
  -Dplatforms=x11

ninja -j 8 -C build
ninja -C build install
```

