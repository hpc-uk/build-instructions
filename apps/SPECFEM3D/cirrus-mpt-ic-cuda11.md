# SPECFEM3D build instructions

Dependencies:
 - HPE MPT
 - Intel compilers
 - CUDA 11.2

## Build SPECFEM3D

```
git clone --recursive https://github.com/geodynamics/specfem3d.git
cd specfem3d
module load mpt
module load intel-compilers-19
module load nvidia/cuda-11.2
export MPICC_CC=icc
export MPICXX_CXX=icpc
export I_MPI_F90=ifort
CC=icc CXX=icpc FC=ifort ./configure --with-cuda=cuda9
make
```

Please note that `cuda9` refers to the CUDA architecture (V100), not the CUDA
driver. Available options can be found in `Makefile.in`.

## Test SPECFEM3D

Test case adapted from [the NVIDIA website](https://www.nvidia.com/es-la/data-center/gpu-accelerated-applications/specfem3d-cartesian/).

Mesh size = 288x256.
The test case can be executed in 36 CPUs, 1 GPU, 2 GPUs, and 4 GPUs.
Submission script files can be found in `testcase` folder.

