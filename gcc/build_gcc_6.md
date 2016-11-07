Instructions for compiling GCC 6.*
==================================

Download and unpack GCC
-----------------------

```bash
wget ...
```
```bash
tar -xvf ...
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
../../gcc-6.2.0/configure --with-prefix=   ...
```

Build and Install
-----------------

```bash
make
make install
```

