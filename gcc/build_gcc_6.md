Instructions for compiling GCC 6.*
==================================

These instructions are for compiling GCC 6.2.0 on Cirrus.

**Note:** This GCC build from source takes quite a long time!

Download and unpack GCC
-----------------------

```bash
wget ftp://ftp.mirrorservice.org/sites/sourceware.org/pub/gcc/releases/gcc-6.2.0/gcc-6.2.0.tar.gz
```
```bash
tar -xvf gcc-6.2.0.tar.gz
```

Download Dependencies
---------------------

```bash
cd gcc-6.2.0
./contrib/download_prerequisites
```

Create Install Directory and Configure
---------------------------------------

```bash
cd ..
mkdir -p gcc/6.2.0
cd gcc/6.2.0
../../gcc-6.2.0/configure --prefix=/lustre/home/z04/aturner/software/gcc/6.2.0 --disable-multilib --with-system-zlib --enable-languages=c,c++,fortran
```

Build and Install
-----------------

```bash
make -j 8
make -j 8 install
```

