Login, make and enter installation folder
-----------------------------------------

```bash
su cse

mkdir /home/y07/y07/cse/sionlib/1.7.1
cd /home/y07/y07/cse/sionlib/1.7.1
```

Download and unpack SIONlib archive
-----------------------------------

Download SIONlib v1.7.1 source from [SIONlib Releases](http://www.fz-juelich.de/ias/jsc/EN/Expertise/Support/Software/SIONlib/sionlib-download_node.html) and then unpack
```bash
tar -xvf sionlib-1.7.1.tar
mv sionlib 1.7.1
rm sionlib-1.7.1.tar
```

Build and install SIONlib for GNU programming environment
---------------------------------------------------------

```bash
module swap PrgEnv-cray PrgEnv-gnu
./configure --prefix=$HOME/sionlib/1.7.1/install/gnu

cd build-crayxt-gnu

make 2>&1 | tee make.log
make install
```

Build and install Position Independent Code (PIC) variant
---------------------------------------------------------

```bash
cd ..
cp -r build-crayxt-gnu build-crayxt-gnu-pic
cd build-crayxt-gnu-pic
```

For all PREFIX definitions within Makefile.defs.fe, Makefile.defs.be
and configure.log append "-pic".

Append "-fPIC" to the OPTFLAGS definitions in Makefile.defs.fe and
Makefile.defs.be.

```bash
make clean
make 2>&1 | tee make.log
make install
```

Build and install CrayPAT-compatible version of PIC variant
-----------------------------------------------------------

```bash
cd ..
cp -r build-crayxt-gnu-pic build-crayxt-gnu-pic-pat
cd build-crayxt-gnu-pic-pat

module load perftools-base/7.0.0
module load perftools/7.0.0
```

For all PREFIX definitions within Makefile.defs.fe, Makefile.defs.be
and configure.log append "-pat".

```bash
make clean
make 2>&1 | tee make.log
make install

module unload perftools
module unload perftools-base
```

Repeat build and install steps for Intel programming environment
----------------------------------------------------------------

```bash
module swap PrgEnv-gnu PrgEnv-intel
```

Repeat instructions replacing "gnu" with "intel."

Repeat build and install steps for Cray programming environment
---------------------------------------------------------------

```bash
module swap PrgEnv-intel PrgEnv-cray
```

Repeat instructions replacing "intel" with "cray", however
"crayxt-intel" is instead replaced with "crayxt-cce".
