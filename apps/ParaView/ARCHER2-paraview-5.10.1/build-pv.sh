#!/usr/bin/env bash
# Install paraview e.g. "bash ./build-pv.sh"
# nb. the script is not completely general in terms of versions
# of the dependencies etc.
# kevin@epcc.ed.ac.uk

set -e

module load PrgEnv-gnu
module load cray-python
module load cmake
module list

# Build path (is here)
export PV_PATH=$(pwd)

# Install path
version="5.10.1"
export PV_INSTALL=/work/y07/shared/utils/core/paraview/${version}

# See below for the main script ...

# LLVM is required to build mesa for PV.
# This appears to be version 12 because that was the version when first
# attempted. I haven't tried v13 or later... and I haven't confirmed
# the above statement, which is historical.

function llvm_install_v12 {
    
    wget https://github.com/llvm/llvm-project/releases/download/llvmorg-12.0.1/llvm-12.0.1.src.tar.xz
    tar xf llvm-12.0.1.src.tar.xz

    cd llvm-12.0.1.src

    mkdir _build
    cd _build

    cmake                                             \
	-DCMAKE_BUILD_TYPE=Release                    \
	-DCMAKE_INSTALL_PREFIX=${PV_INSTALL}/llvm     \
	-DLLVM_BUILD_LLVM_DYLIB=ON                    \
	-DLLVM_ENABLE_RTTI=ON                         \
	-DLLVM_INSTALL_UTILS=ON                       \
	../
    make -j 8 install
}

function install_mesa_v21 {

    # For build ...
    export PYTHONUSERBASE="$(pwd)/.local"
    export PATH=${PYTHONUSERBASE}/bin:$PATH
    pip install --user meson
    pip install --user ninja
    pip install --user mako

    wget https://archive.mesa3d.org//mesa-21.0.1.tar.xz
    rm -rf mesa-21.0.1
    tar xf mesa-21.0.1.tar.xz

    cd mesa-21.0.1

    CC=cc CXX=CC meson build -Dprefix="${PV_INSTALL}/mesa" \
      -Degl=disabled -Dopengl=true -Dgles1=disabled -Dgles2=disabled \
      -Dgallium-va=disabled -Dgallium-xvmc=disabled -Dgallium-vdpau=disabled \
      -Dshared-glapi=enabled -Dllvm=enabled -Dshared-llvm=enabled \
      -Dgallium-drivers=swrast,swr -Ddri3=disabled -Ddri-drivers='' \
      -Dgbm=disabled -Dglx=disabled -Dosmesa=true -Dvulkan-drivers='' \
      -Dplatforms=x11

    ninja -j 8 -C build
    ninja -C build install
}

function install_ospray_v2 {

    wget -O ospray-v2.1.0.tar.gz \
	 https://github.com/ospray/ospray/archive/refs/tags/v2.1.0.tar.gz

    rm -rf osprey-2.1.0
    tar xf ospray-v2.1.0.tar.gz
    cd ospray-2.1.0

    mkdir _build
    cd _build
    cmake -DCMAKE_INSTALL_PREFIX=${PV_INSTALL}/ospray/2.1.0 ../scripts/superbuild
    make -j 8
}

function install_pv_v5 {

    # Note the "v" in the version tag
    git clone https://gitlab.kitware.com/paraview/paraview.git
    cd paraview
    git checkout "v${version}"
    git submodule update --init --recursive

    rm -rf "_build-${version}"
    mkdir "_build-${version}"
    cd "_build-${version}"

    cmake -DPARAVIEW_USE_QT=OFF -DPARAVIEW_USE_MPI=on     \
	  -DOSMESA_INCLUDE_DIR=${MESA_PATH}/include \
	  -DOSMESA_LIBRARY=${MESA_PATH}/lib64/libOSMesa.so \
	  -DVTK_OPENGL_HAS_OSMESA=ON \
          -DVTK_USE_X=OFF \
          -DPARAVIEW_ENABLE_RAYTRACING=on \
          -DPARAVIEW_USE_VTKM=off \
	  -DPARAVIEW_USE_PYTHON=ON -DCMAKE_SHARED_LINKER_FLAGS=-lpthread \
	  -Dospray_DIR=${OSPRAY_PATH}/ospray/lib64/cmake/ospray-2.1.0    \
	  -Dembree_DIR=${OSPRAY_PATH}/embree/lib64/cmake/embree-3.9.0    \
	  -Dospcommon_DIR=${OSPRAY_PATH}/ospcommon/lib64/cmake/ospcommon-1.3.0\
	  -DOSPCOMMON_TBB_ROOT=${OSPRAY_PATH}/tbb \
	  -DTBB_INCLUDE_DIR=${OSPRAY_PATH}/tbb/include  \
	  -DTBB_LIBRARY_MALLOC=${OSPRAY_PATH}/tbb/lib/intel64/gcc4.8/libtbbmalloc.so \
	  -DTBB_LIBRARY=${OSPRAY_PATH}/tbb/lib/intel64/gcc4.8/libtbb.so \
	  -Dopenvkl_DIR=${OSPRAY_PATH}/openvkl/lib64/cmake/openvkl-0.9.0 \
	  -DCMAKE_INSTALL_PREFIX=${PV_INSTALL}/paraview       \
	  ..
    make -j 8
    make install
}

# Main script

# Install OSPray (is independent of anything else)

install_ospray_v2

# ... and LLVM (also independent of anything else)

cd ${PV_PATH}
llvm_install_v12

# Mesa

# Install mesa ...

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${PV_INSTALL}/llvm/lib
export PATH=$PATH:${PV_INSTALL}/llvm/bin

cd ${PV_PATH}
install_mesa_v21

# Paraview

export MESA_PATH=${PV_INSTALL}/mesa
export OSPRAY_PATH=${PV_INSTALL}/ospray/2.1.0

module load cray-hdf5

cd ${PV_PATH}
install_pv_v5
