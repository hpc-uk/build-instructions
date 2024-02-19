Build fftw-3.3.10 on Cirrus with GCC 12.3.0 and intel-20.4 MPI
==============================================================

Download and untar source code
------------------------------

```bash
wget http://www.fftw.org/fftw-3.3.10.tar.gz
tar -xvf fftw-3.3.10.tar.gz
cd fftw-3.3.10/
```

Set-up module environment
-------------------------

```bash
module load gcc/12.3.0
module load intel-20.4/mpi
```

Configure and build
-------------------

```bash
./configure \
--enable-mpi --enable-openmp --enable-threads --enable-shared \
LDFLAGS=-L${I_MPI_ROOT}/intel64/lib:${LD_LIBRARY_PATH} \
CPPFLAGS=-I${I_MPI_ROOT}/intel64/include \
--prefix=/work/y07/shared/cirrus-software/fftw/3.3.10-gcc12.3-impi20.4

make clean # if folder was used for a different compilation
make
make check
make install
```
