Instructions for compiling Tcl and Tk 8.6.13 on the ARCHER2
===========================================================

These instructions are for compiling Tcl and Tk 8.6.13 on ARCHER2 (HPE Cray EX, AMD Zen2 7742) using the Cray compilers.


Download the source files
-------------------------

Files can be downloaded from [the tcl/tk website.](https://www.tcl.tk/software/tcltk/download.html)

Extract with

```bash
tar -xzvf tcl8.6.13-src.tar.gz
tar -xzvf tk8.6.13-src.tar.gz
```

Configure and Install
---------------------

Tcl:

```bash
cd tcl8.6.13/unix/
export CC=cc
export TCL_DIR=/work/y07/shared/utils/core/tcl/8.6.13
exoirt TCL_SRC=$(pwd)
./configure --disable-threads --prefix=$TCL_DIR
make
make test
make install
```

Tk (continued from tcl above):

```bash
cd tk8.6.13/unix
export CC=cc
export TK_DIR=/work/y07/shared/utils/core/tk/8.6.13
./configure --with-tcl=$TCL_SRC --prefix=$TK_DIR
make
make test
make install
```
