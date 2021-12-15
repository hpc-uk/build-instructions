# Build instructions for Pararview 5.9.1 offscreen version with raytracing using OSPRay on ARCHER2

The instructions below assume you're building and installing on the same filesystem. If this is not the case you may need to define two `PV_` environment variable, one for the build path, and one for the install path.

## Set up the environment

```
module restore PrgEnv-gnu
module load cmake
mkdir paraview-build
cd paraview-build
export PV_PATH=`pwd`
```

## Build llvm

* Required for mesa

```
wget https://github.com/llvm/llvm-project/releases/download/llvmorg-12.0.1/llvm-12.0.1.src.tar.xz
tar xvf llvm-12.0.1.src.tar.xz
cd llvm-12.0.1.src
mkdir build
cd build
cmake                                           \
  -DCMAKE_BUILD_TYPE=Release                    \
  -DCMAKE_INSTALL_PREFIX=${PV_PATH}/llvm        \
  -DLLVM_BUILD_LLVM_DYLIB=ON                    \
  -DLLVM_ENABLE_RTTI=ON                         \
  -DLLVM_INSTALL_UTILS=ON                       \
  ../
make -j 8 install

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${PV_PATH}/llvm/lib
export PATH=$PATH:${PV_PATH}/llvm/bin
```

## Install meson, ninja and mako 

* Required for build mesa
* Installed via pip
* Note, you need to change PYTHNOUSERBASE to point to somewhere sensible in the command below

```
module load cray-python
export PYTHONUSERBASE=/work/group/group/user/.local/
export PATH=$PYTHONUSERBASE/bin:$PATH
pip install --user meson
pip install --user ninja
pip install --user mako
```

## Build mesa

```
cd ${PV_PATH}
wget https://archive.mesa3d.org//mesa-21.0.1.tar.xz
tar xvf mesa-21.0.1.tar.xz
cd mesa-21.0.1/
CC=cc CXX=CC meson build -Dprefix="${PWD}/build/install" -Degl=disabled -Dopengl=true -Dgles1=disabled -Dgles2=disabled -Dgallium-va=disabled -Dgallium-xvmc=disabled -Dgallium-vdpau=disabled -Dshared-glapi=enabled -Dllvm=enabled -Dshared-llvm=enabled -Dgallium-drivers=swrast,swr -Ddri3=disabled -Ddri-drivers='' -Dgbm=disabled -Dglx=disabled -Dosmesa=true -Dvulkan-drivers='' -Dplatforms=x11
ninja -j 8 -C build
ninja -C build install


export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${PV_PATH}/mesa-21.0.1/build/install/lib64
export MESA_INSTALL_PREFIX=${PV_PATH}/mesa-21.0.1/build/install/
```

## Build OSPRay
```
cd ${PV_PATH}
wget https://github.com/ospray/ospray/archive/refs/tags/v2.1.0.tar.gz
mv v2.1.0.tar.gz ospray-v2.1.0.tar.gz
tar xf ospray-v2.1.0.tar.gz
cd ospray-2.1.0/
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=${PV_PATH}/ospray/2.1.0 ../scripts/superbuild
make -j 8
make -j 8 install
```

## Build Paraview

```
cd ${PV_PATH}
git clone https://gitlab.kitware.com/paraview/paraview.git
cd paraview
git checkout v5.9.1
git submodule update --init --recursive
module load cray-hdf5
mkdir build
cd build
cmake  -DPARAVIEW_USE_QT=OFF -DPARAVIEW_USE_MPI=on                          \
        -DVTK_USE_X=OFF -DOSMESA_INCLUDE_DIR=${MESA_INSTALL_PREFIX}/include  \
        -DOSMESA_LIBRARY=${MESA_INSTALL_PREFIX}/lib64/libOSMesa.so           \
        -DVTK_OPENGL_HAS_OSMESA=ON -DPARAVIEW_USE_VTKM=off                   \
        -DCMAKE_INSTALL_PREFIX=${PV_PATH}/paraview/build/install             \
        -DPARAVIEW_USE_PYTHON=ON .. -DCMAKE_SHARED_LINKER_FLAGS=-lpthread    \
	-Dospray_DIR=/work/y07/shared/utils/core/paraview/5.9.1/ospray/2.1.0/ospray/lib64/cmake/ospray-2.1.0 \
	-Dembree_DIR=/work/y07/shared/utils/core/paraview/5.9.1/ospray/2.1.0/embree/lib64/cmake/embree-3.9.0 \
	-Dospcommon_DIR=/work/y07/shared/utils/core/paraview/5.9.1/ospray/2.1.0/ospcommon/lib64/cmake/ospcommon-1.3.0 \
	-DOSPCOMMON_TBB_ROOT=/work/y07/shared/utils/core/paraview/5.9.1/ospray/2.1.0/tbb/cmake \
	-DTBB_INCLUDE_DIR=/work/y07/shared/utils/core/paraview/5.9.1/ospray/2.1.0/tbb/include \
	-DTBB_LIBRARY_MALLOC=/work/y07/shared/utils/core/paraview/5.9.1/ospray/2.1.0/tbb/lib/intel64/gcc4.8/libtbbmalloc.so \
	-DTBB_LIBRARY=${PV_PATH}/ospray/2.1.0/tbb/lib/intel64/gcc4.8/libtbb.so \
	-Dopenvkl_DIR=${PV_PATH}/ospray/2.1.0/openvkl/lib64/cmake/openvkl-0.9.0 	
make -j 8
make install
```

### Set up the environment
* Note, if the python version changes then you will need to modify `python3.8` to be something appropriate to your python install 


```
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$(PV_PATH)/paraview/build/install/lib64
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$(PV_PATH)/ospray/2.1.0/ospray/lib64
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$(PV_PATH)/ospray/2.1.0/openvkl/lib64
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$(PV_PATH)/ospray/2.1.0/embree/lib64
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$(PV_PATH)/llvm/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$(PV_PATH)/mesa/21.0.1/lib64
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$(PV_PATH)/paraview/build/install/lib64
export PATH=$PATH:${PV_PATH}/paraview/build/install/bin
export PYTHONPATH=$PYTHONPATH:${{PV_PATH}/paraview/build/install/lib64/python3.8/site-packages
```