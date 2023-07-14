#!/bin/bash
# Build and install paraview 5.11.1
# 14.07.2023
# s.lemaire@epcc.ed.ac.uk

set -e

module load PrgEnv-gnu
module load cray-python
module load cmake

export PARAVIEW_VERSION=5.11.1

export LLVM_VERSION=16.0.0
export MESA_VERSION=23.0.1
export OSPRAY_VERSION=2.11.0
export EMBREE_VERSION=4.0.1

export PV_BUILD_PATH=$(pwd)/paraview-build-${PARAVIEW_VERSION}
export PV_INSTALL=/work/y07/shared/utils/core/paraview/${PARAVIEW_VERSION}

mkdir -p $PV_BUILD_PATH
mkdir -p $PV_INSTALL

export PYTHONUSERBASE=$PV_BUILD_PATH/.local
export PATH=$PYTHONUSERBASE/bin:$PATH

export LLVM_INSTALL_PREFIX=${PV_INSTALL}/llvm #/$LLVM_VERSION
export MESA_INSTALL_PREFIX=${PV_INSTALL}/mesa #/$MESA_VERSION
export OSPRAY_INSTALL_PREFIX=${PV_INSTALL}/ospray #/$OSPRAY_VERSION
export PARAVIEW_INSTALL_PREFIX=${PV_INSTALL}/paraview #/$PARAVIEW_VERSION

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$LLVM_INSTALL_PREFIX/lib
export PATH=$PATH:$LLVM_INSTALL_PREFIX/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$MESA_INSTALL_PREFIX/lib64

build_llvm () {

    cd ${PV_BUILD_PATH}
    wget https://github.com/llvm/llvm-project/releases/download/llvmorg-$LLVM_VERSION/llvm-$LLVM_VERSION.src.tar.xz
    tar xvf llvm-$LLVM_VERSION.src.tar.xz

    # see https://github.com/llvm/llvm-project/issues/53281
    wget https://github.com/llvm/llvm-project/releases/download/llvmorg-$LLVM_VERSION/cmake-$LLVM_VERSION.src.tar.xz
    tar xvf cmake-$LLVM_VERSION.src.tar.xz
    mv cmake-$LLVM_VERSION.src cmake

    wget https://github.com/llvm/llvm-project/releases/download/llvmorg-$LLVM_VERSION/third-party-$LLVM_VERSION.src.tar.xz
    tar xvf third-party-$LLVM_VERSION.src.tar.xz
    mv third-party-$LLVM_VERSION.src third-party

    cd llvm-$LLVM_VERSION.src
    mkdir build
    cd build
    cmake                                           \
      -DCMAKE_BUILD_TYPE=Release                    \
      -DCMAKE_INSTALL_PREFIX=$LLVM_INSTALL_PREFIX   \
      -DLLVM_BUILD_LLVM_DYLIB=ON                    \
      -DLLVM_ENABLE_RTTI=ON                         \
      -DLLVM_INSTALL_UTILS=ON                       \
      -DLLVM_INCLUDE_BENCHMARKS=OFF                 \
      ../
    make -j 8 install

}

install_meson_ninja_mako () {
    pip install --user meson
    pip install --user ninja
    pip install --user mako
}

build_mesa () {

    cd ${PV_BUILD_PATH}
    wget https://archive.mesa3d.org/mesa-$MESA_VERSION.tar.xz
    tar xvf mesa-$MESA_VERSION.tar.xz
    cd mesa-$MESA_VERSION/
    CC=cc CXX=CC meson build -Dprefix="$MESA_INSTALL_PREFIX" \
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
        -Ddri-drivers='' \
        -Dgbm=disabled \
        -Dglx=disabled \
        -Dosmesa=true \
        -Dvulkan-drivers='' \
        -Dplatforms=x11

    ninja -j 8 -C build
    ninja -C build install
}

build_OSPRay () {

    cd ${PV_BUILD_PATH}

    wget https://github.com/ospray/ospray/archive/refs/tags/v$OSPRAY_VERSION.tar.gz
    mv v$OSPRAY_VERSION.tar.gz ospray-v$OSPRAY_VERSION.tar.gz
    tar xf ospray-v$OSPRAY_VERSION.tar.gz
    cd ospray-$OSPRAY_VERSION/
    mkdir build
    cd build
    cmake -DCMAKE_INSTALL_PREFIX=$OSPRAY_INSTALL_PREFIX \
        -DEMBREE_VERSION=$EMBREE_VERSION ../scripts/superbuild
    make -j 8
    make -j 8 install
}

build_paraview () {

    cd ${PV_BUILD_PATH}

    git clone --depth 1 --branch v${PARAVIEW_VERSION} https://gitlab.kitware.com/paraview/paraview.git
    cd paraview
    git submodule update --init --recursive

    mkdir -p "build"
    cd "build"

    cmake -DPARAVIEW_USE_QT=OFF -DPARAVIEW_USE_MPI=on     \
        -DOSMESA_INCLUDE_DIR=$MESA_INSTALL_PREFIX/include \
        -DOSMESA_LIBRARY=$MESA_INSTALL_PREFIX/lib64/libOSMesa.so \
        -DVTK_OPENGL_HAS_OSMESA=ON \
        -DVTK_USE_X=OFF \
        -DPARAVIEW_ENABLE_RAYTRACING=on \
        -DPARAVIEW_USE_VTKM=off \
        -DPARAVIEW_USE_PYTHON=ON -DCMAKE_SHARED_LINKER_FLAGS=-lpthread \
        -Dospray_DIR=$OSPRAY_INSTALL_PREFIX/ospray/lib64/cmake/ospray-$OSPRAY_VERSION    \
        -Dembree_DIR=$OSPRAY_INSTALL_PREFIX/embree/lib64/cmake/embree-$EMBREE_VERSION    \
        -DCMAKE_INSTALL_PREFIX=${PARAVIEW_INSTALL_PREFIX}  \
        ..
        #-DTBB_INCLUDE_DIR=$OSPRAY_INSTALL_PREFIX/tbb/include/tbb  \
        #-DTBB_LIBRARY_MALLOC=$OSPRAY_INSTALL_PREFIX/tbb/lib/intel64/gcc4.8/libtbbmalloc.so \
        #-DTBB_LIBRARY=$OSPRAY_INSTALL_PREFIX/tbb/lib/intel64/gcc4.8/libtbb.so \
        #-Dopenvkl_DIR=$OSPRAY_INSTALL_PREFIX/openvkl/lib64/cmake/openvkl-1.3.2 \
        #-Dospcommon_DIR=$OSPRAY_INSTALL_PREFIX/ospcommon/lib64/cmake/ospcommon-1.3.0\
        #-DOSPCOMMON_TBB_ROOT=$OSPRAY_INSTALL_PREFIX/tbb \
    make -j 8
    make install
}

export_variables () {

    echo "
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PARAVIEW_INSTALL_PREFIX/lib64
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$OSPRAY_INSTALL_PREFIX/ospray/lib64
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$OSPRAY_INSTALL_PREFIX/openvkl/lib64
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$OSPRAY_INSTALL_PREFIX/embree/lib64
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$LLVM_INSTALL_PREFIX/lib
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$MESA_INSTALL_PREFIX/lib64
    export PATH=$PATH:$PARAVIEW_INSTALL_PREFIX/bin
    export PYTHONPATH=$PYTHONPATH:$PARAVIEW_INSTALL_PREFIX/lib64/python3.8/site-packages
"
}

if [ "$1" == "export" ] then
    export_variables
else
    install_meson_ninja_mako
    build_llvm
    build_mesa
    build_OSPRay

    build_paraview
fi
