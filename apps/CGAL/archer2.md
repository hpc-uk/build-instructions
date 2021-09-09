# GrADS build instructions

Dependencies:
 - GNU compiler
 - Boost (dynamic libraries)
 - The GNU MP Bignum Library
 - The GNU MPFR library

The software and its dependencies will be installed in `$WORK`, an environment
variable that we would need to define beforehand.

```
# Define WORK
WORK=/work/gid/gid/uid

# Load GNU compilers
module restore -s PrgEnv-gnu
```

## Build Boost (dynamic libraries)

```
git clone https://github.com/ARCHER2-HPC/pe-scripts.git
cd pe-scripts
git checkout cse-develop
```
Edit `sh/.preamble.sh` and change line 13 with this: `make_shared=1`
```
./sh/boost.sh --prefix=$WORK/sw/boost
```

## Build MPFR
```
wget https://www.mpfr.org/mpfr-current/mpfr-4.1.0.tar.gz
tar xf mpfr-4.1.0.tar.gz
cd mpfr-4.1.0
CC=cc ./configure --prefix=$WORK/sw/mpfr
make
make install
```

## Build CGAL
```
wget https://github.com/CGAL/cgal/archive/releases/CGAL-4.12.1.tar.gz
tar xf CGAL-4.12.1.tar.gz
cd cgal-releases-CGAL-4.12.1
mkdir -p build/release
cd build/release
CC=cc CXX=CC F90=ftn cmake -DCMAKE_BUILD_TYPE=Release -DGMP_LIBRARIES=/work/y07/shared/libs/gmp/6.1.2-gcc10/lib -DGMP_INCLUDE_DIR=/work/y07/shared/libs/gmp/6.1.2-gcc10/include -DMPFR_LIBRARIES=$WORK/sw/mpfr/lib -DMPFR_INCLUDE_DIR=$HOME/sw/mpfr/include -DBOOST_ROOT=$WORK/sw/boost ../..
make
```

