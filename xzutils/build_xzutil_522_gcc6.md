Instructions for compiling XZ Utils 5.* with GCC Compilers 
==========================================================

These instructions are known to work successfully for XZ Utils 5.2.2 with
Intel Compilers 2016 on [Cirrus](http://www.epcc.ed.ac.uk/cirrus) (a
SGI ICE XA system).

Download and unpack bzip2
-------------------------

```bash
wget http://tukaani.org/xz/xz-5.2.2.tar.gz
tar -xvf xz-5.2.2.tar.gz
```

Create install directory and setup environment
----------------------------------------------

Move to the source directory and create an install directory:

```bash
cd xz-5.5.2
mkdir ../5.5.2-gcc6
```

Load the GCC compilers module:

```bash
module load gcc
```

Configure, Build, and Install
------------------------

```bash
./configure --prefx=/lustre/sw/xzutil/5.2.2-gcc6
make -j8
make -j8 install
```

