Quantum Espresso 6.5 with Intel 18 compilers on Cirrus
------------------------------------------------------

```
wget https://github.com/QEF/q-e/archive/qe-6.5.tar.gz
tar xf qe-6.5.tar.gz
cd q-e-qe-6.5
cd archive/
wget https://codeload.github.com/wannier-developers/wannier90/tar.gz/v3.0.0
wget https://github.com/dceresoli/qe-gipaw/archive/6.5.tar.gz
wget http://www.west-code.org/downloads/West-2.0.1.tar.gz
wget http://www.west-code.org/downloads/West-2.0.1.tar.gz
wget http://www.wannier-transport.org/files/want-latest.tar.gz
wget https://github.com/QEF/SternheimerGW/archive/v0.15_QE6.3.tar.gz
wget http://www.yambo-code.org/files/yambo-stable-latest.tar.gz
wget http://www.yambo-code.org/files/yambo-devel-latest.tar.gz

cd ../ 
 
srun --time=2:00:00 --exclusive --nodes=1 --partition=standard --qos=standard --account=z04 --pty bash
 
module load intel-compilers-18/18.05.274
module load intel-mpi-18/18.0.5.274
module load intel-cmkl-18/18.0.5.274
module load fftw/3.3.8-intel18
 
cd q-e-qe-6.5
 
export F90=mpiifort
export F77=mpiifort
export MPIF90=mpiifort
export CC=mpiicc
export CPP="icc -E"
export CFLAGS=$FCFLAGS
export AR=xiar
export BLAS_LIBS=""
export LAPACK_LIBS="-lmkl_blacs_intelmpi_lp64"
export SCALAPACK_LIBS="-lmkl_scalapack_lp64 -lmkl_blacs_intelmpi_lp64"
export FFT_LIBS="-L$MKLROOT/intel64"

srun ./configure --prefix=$(pwd)/../install --enable-openmp --enable-parallel --with-scalapack=intel LIBDIRS="/lustre/sw/fftw/3.3.8-intel18/lib/"

#make all
srun make -j36 pw ph hp pwcond neb pp pwall cp tddfpt gwl ld1 upf xspectra couple epw
srun make pw ph hp pwcond neb pp pwall cp tddfpt gwl ld1 upf xspectra couple epw
 
####make -j36 gipaw w90 want yambo yambo-devel SternheimerGW plumed d3q
####make gipaw w90 want yambo yambo-devel SternheimerGW plumed d3q
 
make install
```
