
# Build fftw-3.3.10 Cirrus Intel 20.4

Set PRFX to current directory
```
PRFX=$(pwd)
cd $PRFX
```

Download and untar source code
```
wget http://www.fftw.org/fftw-3.3.10.tar.gz
tar -xvf fftw-3.3.10.tar.gz
cd fftw-3.3.10/
```

Set-up module environment
```
module load intel-20.4/compilers
module load intel-20.4/mpi
```

Configure and build
```
./configure --prefix=$PRFX --enable-mpi --enable-openmp --enable-threads --enable-shared LDFLAGS=-L${I_MPI_ROOT}/intel64/lib:$LD_LIBRARY_PATH CPPFLAGS=-I${I_MPI_ROOT}/intel64/include

make
make check
make install
```
