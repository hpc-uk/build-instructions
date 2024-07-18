
# Build fftw-3.3.10 on Cirrus with GCC 10.2.0, OpenMPI 4.1.6 and CUDA 12.4

Download and untar source code
```
wget http://www.fftw.org/fftw-3.3.10.tar.gz
tar -xvf fftw-3.3.10.tar.gz
cd fftw-3.3.10/
```

Set-up module environment
```
module load gcc/10.2.0
module load nvidia/nvhpc-nompi/24.5
module load openmpi/4.1.6-cuda-12.4
```

Configure and build
```
./configure CC=gcc CXX=g++ FC=gfortran \
            CPPFLAGS="-I${MPI_HOME}/include" \
            LDFLAGS="-L${MPI_HOME}/lib" \
            MPILIBS=-lmpi \
            --prefix=/work/y07/shared/cirrus-software/fftw/3.3.10-gcc10.2-ompi4-cuda12.4 \
            --enable-mpi --enable-openmp --enable-threads \
            --enable-float
make -j 8
make -j 8 install
make -j 8 clean

./configure CC=gcc CXX=g++ FC=gfortran \
            CPPFLAGS="-I${MPI_HOME}/include" \
            LDFLAGS="-L${MPI_HOME}/lib" \
            MPILIBS=-lmpi \
            --prefix=/work/y07/shared/cirrus-software/fftw/3.3.10-gcc10.2-ompi4-cuda12.4 \
            --enable-mpi --enable-openmp --enable-threads \
            --enable-float --enable-shared
make -j 8
make -j 8 install
make -j 8 clean
```
