
# Build fftw-3.3.10 on Cirrus with Intel 20.4 and MPT 2.25

Download and untar source code
```
wget http://www.fftw.org/fftw-3.3.10.tar.gz
tar -xvf fftw-3.3.10.tar.gz
cd fftw-3.3.10/
```

Set-up module environment
```
module load intel-20.4/compilers
module load mpt/2.25
```

Configure and build
```
./configure --prefix=/work/y07/shared/cirrus-software/fftw/3.3.10-intel20.4-mpt2.25 \
--enable-mpi --enable-openmp --enable-threads --enable-shared \
LDFLAGS=-L/opt/hpe/hpc/mpt/mpt-2.25/lib:$LD_LIBRARY_PATH CPPFLAGS=-I/opt/hpe/hpc/mpt/mpt-2.25/include CC=icc

make
make check
make install
```
