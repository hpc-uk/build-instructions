1. Load the following modules.

module load nvidia/cuda-10.2
module load nvidia/mathlibs-10.2
module load gcc/6.3.0
module load mpt
module load cmake


2. Download & untar new edition of GROMACS.


3. From the GROMACS directory, run the following.

cmake ../ -DGMX_MPI=ON -DGMX_OPENMP=ON -DGMX_X11=OFF \
          -DGMX_DOUBLE=OFF -DGMX_BUILD_MDRUN_ONLY=ON -DGMX_BUILD_OWN_FFTW=ON \
          -DGMX_GPU=on -DCMAKE_INSTALL_PREFIX=/path/to/gromacs/install/dir \
          -DCUDA_cufft_LIBRARY=/lustre/sw/nvidia/hpcsdk/Linux_x86_64/20.5/math_libs/10.2/lib64/libcufftw.so.10

make
make check
make install
