Building OpenFOAM 4.0 on Cirrus using GCC 6.x
=============================================

These instructions cover the building of OpenFOAM on [Cirrus](http://www.cirrus.ac.uk).
Cirrus is a SGI ICE XA system with Intel Xeon "Broadwell" processors.

These instructions cover using GCC 6.x to compile OpenFOAM.

Setup your environment
----------------------

Load the required modules:

    module load gcc/6.3.0
    module load mpt/2.22
    module load zlib/1.2.11
    module load gmp/6.2.0-mpt
    module load mpfr/4.0.2-mpt
    module load spack/2020
    module load flex-2.6.4-gcc-8.2.0-zlwjqca
    module load cmake/3.17.3 


Download and extract source code
--------------------------------

Setup the top level directory:

    mkdir OpenFOAM
    cd OpenFOAM

Download main OpenFOAM software:

    wget http://dl.openfoam.org/source/4-0 -O OpenFOAM-4.0.tgz
    wget http://dl.openfoam.org/third-party/4-0 -O ThirdParty-4.0.tgz

Unpack mail OpenFOAM software:

    tar -xzf OpenFOAM-4.0.tgz &
    tar -xzf ThirdParty-4.0.tgz
    mv OpenFOAM-4.x-version-4.0 OpenFOAM-4.0
    mv ThirdParty-4.x-version-4.0 ThirdParty-4.0

Download and unpack third party components

    cd ThirdParty-4.0
    mkdir download
    wget -P download https://github.com/CGAL/cgal/releases/download/releases%2FCGAL-4.8/CGAL-4.8.tar.xz
    wget -P download http://sourceforge.net/projects/boost/files/boost/1.55.0/boost_1_55_0.tar.bz2
    tar -xJf download/CGAL-4.8.tar.xz
    tar -xjf download/boost_1_55_0.tar.bz2

Move back to top-level directory:

    cd ..

MPI configuration
-----------------

Link the OpenFOAM MPI compilers to the binaries on Cirrus:

    ln -s $MPI_ROOT/bin/mpicc  OpenFOAM-4.0/bin/mpicc
    ln -s $MPI_ROOT/bin/mpicxx OpenFOAM-4.0/bin/mpixx
    ln -s $MPI_ROOT/bin/mpirun OpenFOAM-4.0/bin/mpirun

Configure scripts
-----------------

Modify the configure scripts with the third party software locations:

    sed -i -e 's/\(boost_version=\)boost-system/\1boost_1_55_0/' OpenFOAM-4.0/etc/config.sh/CGAL
    sed -i -e 's/\(cgal_version=\)cgal-system/\1CGAL-4.8/'       OpenFOAM-4.0/etc/config.sh/CGAL
    sed -i -e 's=\-lmpfr=-lmpfr -lboost_thread='                 OpenFOAM-4.0/wmake/rules/General/CGAL

Edit OpenFOAM-4.0/etc/bashrc:

    echo "export WM_NCOMPPROCS=32" >>     OpenFOAM-4.0/etc/bashrc
    sed -i -e 's/=SYSTEMOPENMPI/=SGIMPI/' OpenFOAM-4.0/etc/bashrc

Update OpenFOAM to the latest GNU C library:

    sed -i -e '/^#include <unistd.h>/a #include <sys/sysmacros.h>' OpenFOAM-4.0/src/OSspecific/POSIX/fileStat.C
    
Update SCOTCH Makefile to find a parallel environment:

    sed -i -e 's@./dummysizes@srun --ntasks=1 &@'   ThirdParty-4.0/scotch_6.0.3/src/libscotch/Makefile
    sed -i -e 's@./ptdummysizes@srun --ntasks=1 &@' ThirdParty-4.0/scotch_6.0.3/src/libscotch/Makefile

Compile within an interactive job
---------------------------------

Submit an interactive job

    srun --time=1:0:0 --exclusive --nodes=1 --partition=standard --qos=standard --account=[your budget code] --pty bash 

Build Third Party software (estimated duration 2 1/2 minutes):

    cd OpenFOAM
    source $PWD/OpenFOAM-4.0/etc/bashrc
    cd $WM_THIRD_PARTY_DIR
    export QT_SELECT=qt4
    ./Allwmake -j 32 > log.make 2>&1
    wmRefresh

Build OpenFOAM 4.0 (estimated duration 30 minutes):

    cd $WM_PROJECT_DIR
    ./Allwmake -j 32 > log.make 2>&1
    wmRefresh

Test build
----------

Submit an interactive job

    srun --time=1:0:0 --exclusive --nodes=1 --partition=standard --qos=standard --account=[your budget code] --pty bash

Load the required modules:

    module load gcc/6.2.0
    module load mpt/2.14
    module load zlib-1.2.8-gcc-6.2.0-epathtp
    module load gmp-6.1.2-gcc-6.2.0-2skcnwh
    module load mpfr-3.1.4-gcc-6.2.0-thlrxaq 
    module load flex-2.6.1-gcc-6.2.0-sywhrx4 cmake-3.7.1-gcc-6.2.0-75ivp2c 

Setup the environment:

    cd OpenFOAM
    source $PWD/OpenFOAM-4.0/etc/bashrc

Run the test program:

    srun --ntasks=1 icoFoam -help

