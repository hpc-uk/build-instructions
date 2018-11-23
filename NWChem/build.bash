#!/bin/bash

# Download, see http://www.nwchem-sw.org/index.php/Download, but get
# the bug fixed release.  Do this once

#wget https://github.com/nwchemgit/nwchem/releases/download/6.8.1-release/nwchem-6.8.1-release.revision-v6.8-133-ge032219-src.2018-06-14.tar.bz2

# Untar (or re-untar, quicker than make clean!)
rm -rf nwchem-6.8.1
tar xf nwchem-6.8.1-release.revision-v6.8-133-ge032219-src.2018-06-14.tar.bz2
cd nwchem-6.8.1

# Configure
# User guide https://github.com/nwchemgit/nwchem/wiki
# Forum http://www.nwchem-sw.org/index.php/Special:AWCforum
# Bugs https://github.com/nwchemgit/nwchem/issues
# Release notes (also in download) https://raw.githubusercontent.com/nwchemgit/nwchem/release-6-8/release.notes.6.8

# One of OpenMP or MKL caused problems.  It could also be errors in
# the NWChem documentation (how to set 4-byte vs 8-byte integers).
# MKL OK, in future might put OpenMP back (only much use for Xeon Phi
# though)?

module load gcc/6.3.0
module load intel-cmkl-17/17.0.2.174
module load mpt/2.16
module load anaconda/python2

export NWCHEM_TOP=$PWD #/lustre/home/z04/mjf/test/Q1053685/nwchem-6.8.1
export NWCHEM_TARGET=LINUX64

# MPI-PR is recommended for ARMCI (over OPENIB also?).
# ARMCI_NETWORK=MPI-PR is stable and performs well on many platforms.
export ARMCI_NETWORK=MPI-PR

# Ignore Casper http://www.mcs.anl.gov/project/casper - that is more
# for very large clusters.

export USE_MPI=y
# Other MPI settings should be automatic, since mpif90 exists

# OpenMP seems to be recommended only for Xeon Phi, so leave it out
# (e.g., how would it affect the memory estimates).
#export USE_OPENMP=1

export NWCHEM_MODULES="all python"

export USE_NOIO=TRUE # sets USE_NOFSCHECK=TRUE also

export MRCC_METHODS=TRUE

export USE_PYTHONCONFIG=Y
export PYTHONHOME=$ANACONDADIR
export LD_LIBRARY_PATH=$ANACONDADIR/lib:$LD_LIBRARY_PATH # Needed for compilation?
export PYTHONVERSION=2.7

# Use the MKL link line advisor
# https://software.intel.com/en-us/articles/intel-mkl-link-line-advisor
# to work out this link line.  Note that NWChem can use OpenMP.  If
# OpenMP is used then use the link line advisor again to get the
# correct link lines.
#
# May need to modify the compiler flags to use MKL:
# These are already set:  -fdefault-integer-8 -m64
# What about this:  -I${MKLROOT}/include
# 
# Note that these are for Fortran but NWChem includes a lot of C code.

# These shouldn't be needed but the logic is swapped for Scalapack, so
# just be sure (errors in NWChem documentation?).
export BLAS_SIZE=8
export LAPACK_SIZE=8
export SCALAPACK_SIZE=8

export BLASOPT="-L${MKLROOT}/lib/intel64 -Wl,--no-as-needed -lmkl_gf_ilp64 -lmkl_sequential -lmkl_core -lpthread -lm -ldl"
export LAPACK_LIB="$BLASOPT"
# USE_SCALAPACK does not appear to be used (errors in NWChem
# documentation?)
export USE_SCALAPACK=y
export SCALAPACK="-L${MKLROOT}/lib/intel64 -Wl,--no-as-needed -lmkl_scalapack_ilp64 -lmkl_gf_ilp64 -lmkl_sequential -lmkl_core -lmkl_blacs_sgimpt_ilp64 -lpthread -lm -ldl"

# Approximately 251.5 GB per compute node, max of 36 cores per compute
# node used.  Memory is counted in doubles.
export LIB_DEFINES=-DDFLT_TOT_MEM=937862414
# This doesn't work, does it!  LIB_DEFINES is set directly in the
# makefile, so the environment variable has no effect (error in NWChem
# documentation).

# NBO omitted.

cd $NWCHEM_TOP/src
time make nwchem_config &> make-nwchem_config.log
time make >& make.log
