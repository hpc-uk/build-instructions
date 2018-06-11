Instructions for compiling libmatheval 1.1.11 for Cirrus using GCC 6 compilers
==========================================================================

These instructions are for compiling libmatheval on Cirrus
(http://www.cirrus.ac.uk) using the GCC 6 compilers, and **without any
tests, i.e. without Guile.**

libmatheval is used for PLUMED 2.4 and earlier
(http://www.plumed.org).  PLUMED 2.5 (released in 2018) and later do
not need libmatheval.

libmatheval is a small library with few dependencies but it uses Guile
(a large package with many dependencies) for its tests, and uses an
old version of Guile.  The old versions of Guile do not build on
Cirrus using spack (the usual method for installing software centrally
on Cirrus), and even the current version appears to not set its
pkgconfig file correctly.  Because of these problems, it is
recommended that libmatheval is installed without Guile.  This has
been described in a [plumed-users
post](https://groups.google.com/forum/#!topic/plumed-users/Zr21oQULcY0)
and in a [GitHub
page](https://github.com/UWPRG/Plumed/blob/master/compile_plumed_gromacs_matheval.md)
(which also contains information on using libmatheval with PLUMED) and
modified here.

libmatheval also uses yywrap (in libfl) which is not installed on
Cirrus), so remove that also.


Download and unpack the libmatheval source code
-------------------------------------------

Download and unpack the source

```bash
wget https://ftp.gnu.org/gnu/libmatheval/libmatheval-1.1.11.tar.gz
tar xf libmatheval-1.1.11.tar.gz
```

Change directory
----------------

```bash
cd libmatheval-1.1.11
```

Remove Guile
------------

```bash
sed -i -e '/^GUILE_FLAGS/ d; /^dnl Additional Guile feature checks./,+4 d' configure.in
sed -i -e '/^noinst_PROGRAMS/ d; /^matheval_SOURCES/ d; /^matheval_CFLAGS/ d; /^matheval_LDADD/ d; /^matheval_LDFLAGS/ d' tests/Makefile.am
autoreconf -fi # there will be several warnings
```

Remove yywrap
-------------

```bash
rm -f lib/scanner.c
sed -i -e '1 i%option noyywrap' lib/scanner.l
```

Setup correct modules
---------------------

```bash
module load gcc/6.3.0 
```

Configure and build
-------------------

```bash
./configure --prefix=/path/to/libmatheval_installation_directory
make
make install
```
