Instructions for compiling NWChem 6.8.1 for Cirrus
====================================================

These instructions are for compiling NWChem on Cirrus (SGI ICE XA, Broadwell) using the GCC 6.3.0 compilers. Intel MKL 17 library, and HPE MPT 2.16 MPI library.

Download NWChem
---------------

```bash
wget https://github.com/nwchemgit/nwchem/releases/download/6.8.1-release/nwchem-6.8.1-release.revision-v6.8-133-ge032219-src.2018-06-14.tar.bz2
```

Unpack and build
----------------

Run the [build.bash](build.bash) script.  Optionally, modify the scipt to replace `nwchem-6.8.1/QA/runtests.mpi.unix` with a [modified runtests.mpi.unix](runtests.mpi.unix)

Run the QA tests
----------------

Change the account code in the [QA job script](QA.pbs) and submit the script.
The tests take about 4 hours to run.  Many tests have 'rounding'
errors, some tests have old validation results that don't match newer
versions of NWChem, some tests have too little memory specified in the
input file, some tests give incorrect results, some tests fail and
NWChem reports this, and some tests just fail.
