Instructions for compiling GCC 8.* on Tesseract
===============================================

These instructions are for compiling GCC 8.1.0 on Tesseract (DiRAC Extreme Scaling, HPE SGI Apollo 8600).

**Note:** This GCC build from source takes quite a long time!

Download and unpack GCC
-----------------------

```bash
wget ftp://ftp.mirrorservice.org/sites/sourceware.org/pub/gcc/releases/gcc-8.1.0/gcc-8.1.0.tar.gz
```
```bash
tar -xvf gcc-8.1.0.tar.gz
```

Download Dependencies
---------------------

```bash
cd gcc-8.1.0
./contrib/download_prerequisites
```

Create Install Directory and Configure
---------------------------------------

```bash
cd ..
mkdir -p gcc/8.1.0
cd gcc/8.1.0
../../gcc-8.1.0/configure --prefix=/home/y07/y07/rse/gcc/8.1.0 --disable-multilib --with-system-zlib --enable-languages=c,c++,fortran
```

Build and Install
-----------------

```bash
make -j 8
make -j 8 check
make -j 8 install
```

