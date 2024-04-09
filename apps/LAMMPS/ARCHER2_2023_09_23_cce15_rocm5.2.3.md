Building LAMMPS for GPU on ARCHER2 (CPE 22.12)
================================================

Instructions for building LAMMPS version 23Sep2023, also known as 2Aug2023 update 1, for the ARCHER2 GPU System (4x AMD Instinct MI210 accelerator per GPU compute node with 1x AMD EPYC 7534P (Milan) processor, 32 core, 2.8 GHz). Using the Cray clang compilers 15.0.0 with Cray-MPICH 8.1.23, this build enables GPU support using ROCM 5.2.3 with Kokkos and HIP.   

Download LAMMPS
---------------

Clone the latest stable version of LAMMPS from the GitHub repository:

```bash
git clone --depth 1 --branch stable_2Aug2023_update2 https://github.com/lammps/lammps.git lammps-2023-09-23
```

Setup your environment
----------------------

Load the correct modules:

```bash
module load PrgEnv-cray
module load craype-x86-milan
module load craype-accel-amd-gfx90a
module load rocm

export MPICH_GPU_SUPPORT_ENABLED=1
export LAMMPS_INSTALL=/path/to/install/location
```

Kokkoc + HIP build 
-----------

Make and go into a build directory:

```bash
cd lammps-2023-09-23 && mkdir build_kokkos_gpu && cd build_kokkos_gpu
```

Build using:

```bash

cmake \
       -DBUILD_MPI=on \
       -DCMAKE_INSTALL_PREFIX=${LAMMPS_INSTALL} \
       -DMPI_CXX_COMPILER=${ROCM_PATH}/hip/bin/hipcc \
       -DCMAKE_CXX_COMPILER=${ROCM_PATH}/hip/bin/hipcc \
       -DCMAKE_BUILD_TYPE=RelWithDebInfo \
       -DPKG_KOKKOS=on \
       -DPKG_REAXFF=off \
       -D Kokkos_ARCH_HOSTARCH=yes \
       -D Kokkos_ARCH_GPUARCH=yes \
       -D Kokkos_ENABLE_HIP=yes \
       -D Kokkos_ENABLE_OPENMP=off \
       -D PKG_ASPHERE=yes -D PKG_BODY=yes -D PKG_CLASS2=yes        \
       -D PKG_COLLOID=yes -D PKG_COMPRESS=yes -D PKG_CORESHELL=yes \
       -D PKG_DIPOLE=yes -D PKG_GRANULAR=yes -D PKG_MC=yes         \
       -D PKG_MISC=yes -D PKG_KSPACE=yes -D PKG_MANYBODY=yes       \
       -D PKG_MOLECULE=yes -D PKG_MPIIO=yes -D PKG_OPT=yes         \
       -D PKG_PERI=yes -D PKG_QEQ=yes -D PKG_SHOCK=yes             \
       -D PKG_SRD=yes -D PKG_RIGID=yes \
       -DKokkos_ENABLE_HIP=on \
       -DKokkos_ENABLE_HIP_MULTIPLE_KERNEL_INSTANTIATIONS=ON \
       -DKokkos_ENABLE_SERIAL=on \
       -DCMAKE_CXX_STANDARD=14 \
       -DKokkos_ARCH_VEGA90A=ON \
       -DKokkos_ENABLE_HWLOC=on \
       -DLAMMPS_SIZES=bigbig \
       -DCMAKE_CXX_FLAGS="-I${CRAY_MPICH_DIR}/include " \
       -DCMAKE_EXE_LINKER_FLAGS="-L${CRAY_MPICH_DIR}/lib ${PE_MPICH_GTL_DIR_amd_gfx90a} -lmpi ${PE_MPICH_GTL_LIBS_amd_gfx90a} -fopenmp" \
       -DLAMMPS_MACHINE=${LMPMACH} \
       -D HIP_PATH=/opt/rocm/hip \
       ../cmake

make -j 8
make install
```

