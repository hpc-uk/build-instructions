Instructions for compiling NAMD 2.12 for ARCHER XC30
====================================================

These instructions are for compiling NAMD 2.12 on ARCHER XC30 (Xeon) using the Intel compilers.

These instructions are based on those produced by the BlueWaters team: https://bluewaters.ncsa.illinois.edu/namd

Download and unpack NAMD
------------------------

First download the NAMD source from: http://www.ks.uiuc.edu/Development/Download/download.cgi?PackageName=NAMD
and transfer to the ARCHER system.

Unpack the source

```bash
tar -xvf NAMD_2.12_Source.tar.gz
```

Setup modified TCL
------------------

Download, unpack and link:

```bash
cd NAMD_2.12_Source
wget http://www.ks.uiuc.edu/Research/namd/libraries/tcl8.5.9-crayxe-threaded.tar.gz
tar -xvf tcl8.5.9-crayxe-threaded.tar.gz
ln -s tcl8.5.9-crayxe-threaded ./tcl
```

Setup correct modules
---------------------

```bash
module swap PrgEnv-cray PrgEnv-intel
module load fftw
module load rca
module load craype-hugepages8M
```

Extract and Build Charm++
--------------------------

```bash
tar -xvf charm-6.7.1.tar
cd charm-6.7.1
./build charm++ gni-crayxe smp persistent -j4 --with-production
cd ..
```


Build NAMD
----------

```bash
./config CRAY-XC-intel --with-fftw --with-fftw3 --fftw-prefix $FFTW_DIR/.. --charm-arch gni-crayxe-persistent-smp
cd CRAY-XC-intel/
gmake -j4
```

This will create the executable `namd2` in the CRAY-XC-intel directory.

