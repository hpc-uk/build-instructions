
# Build fftw-3.3.10 on Cirrus with GCC 10.2 and Intel MPI 20.4

Download and untar source code
```
wget http://www.fftw.org/fftw-3.3.10.tar.gz
tar -xvf fftw-3.3.10.tar.gz
cd fftw-3.3.10/
```

Set-up module environment
```
module load gcc/10.2.0
module load intel-20.4/mpi
```

Configure and build
```
export LD_LIBRARY_PATH={I_MPI_ROOT}/intel64/libfabric/lib:${LD_LIBRARY_PATH}

./configure CC=gcc CXX=g++ FC=gfortran \
            CPPFLAGS="-I${I_MPI_ROOT}/intel64/include" \
            LDFLAGS="-L${I_MPI_ROOT}/intel64/lib/release" \
            MPILIBS=-lmpi \
            --prefix=/work/y07/shared/cirrus-software/fftw/3.3.10-gcc10.2-impi20.4 \
            --enable-mpi --enable-openmp --enable-threads \
            --enable-float
make -j 8
make -j 8 install
make -j 8 clean

./configure CC=gcc CXX=g++ FC=gfortran \
            CPPFLAGS="-I${I_MPI_ROOT}/intel64/include" \
            LDFLAGS="-L${I_MPI_ROOT}/intel64/lib/release" \
            MPILIBS=-lmpi \
            --prefix=/work/y07/shared/cirrus-software/fftw/3.3.10-gcc10.2-impi20.4 \
            --enable-mpi --enable-openmp --enable-threads \
            --enable-float --enable-shared
make -j 8
make -j 8 install
make -j 8 clean
```
