Building OpenFOAM 4.1 on Cirrus using GCC 6.x
=============================================

These instructions cover the building of OpenFOAM on [Cirrus](http://www.cirrus.ac.uk).
Cirrus is a SGI ICE XA system with Intel Xeon "Broadwell" processors.

These instructions cover using GCC 6.x to compile OpenFOAM.

Setup your environment
----------------------

Load the required modules:

    module load gcc/6.2.0
    module load mpt/2.14
    module load zlib-1.2.8-gcc-6.2.0-epathtp
    module load gmp-6.1.2-gcc-6.2.0-2skcnwh
    module load mpfr-3.1.4-gcc-6.2.0-thlrxaq 
    module load flex-2.6.1-gcc-6.2.0-sywhrx4
    module load cmake-3.7.1-gcc-6.2.0-75ivp2c 


Download and extract source code
--------------------------------

Setup the top level directory:

    mkdir OpenFOAM
    cd OpenFOAM

Download main OpenFOAM software:

    wget http://dl.openfoam.org/source/4-1 -O OpenFOAM-4.1.tgz
    wget http://dl.openfoam.org/third-party/4-1 -O ThirdParty-4.1.tgz

Unpack mail OpenFOAM software:

    tar -xzf OpenFOAM-4.1.tgz &
    tar -xzf ThirdParty-4.1.tgz
    mv OpenFOAM-4.x-version-4.1 OpenFOAM-4.1
    mv ThirdParty-4.x-version-4.1 ThirdParty-4.1

Download and unpack third party components

    cd ThirdParty-4.1
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

    ln -s /opt/sgi/mpt/mpt-2.14/bin/mpicc  OpenFOAM-4.1/bin/mpicc
    ln -s /opt/sgi/mpt/mpt-2.14/bin/mpicxx OpenFOAM-4.1/bin/mpixx
    ln -s /opt/sgi/mpt/mpt-2.14/bin/mpirun OpenFOAM-4.1/bin/mpirun

Configure scripts
-----------------

Modify the configure scripts with the third party software locations:

    sed -i -e 's/\(boost_version=\)boost-system/\1boost_1_55_0/' OpenFOAM-4.1/etc/config.sh/CGAL
    sed -i -e 's/\(cgal_version=\)cgal-system/\1CGAL-4.8/' OpenFOAM-4.1/etc/config.sh/CGAL
    sed -i -e 's=\-lmpfr=-lmpfr -lboost_thread=' OpenFOAM-4.1/wmake/rules/General/CGAL

Edit OpenFOAM-4.1/etc/bashrc:

* Add `export WM_NCOMPPROCS=24`
* Modify `FOAM_INST_DIR=/path/to/your/top/level/OpenFOAM/directory`
* Modify `WM_MPLIB=SGIMPI`

Compile within an interactive job
---------------------------------

Submit an interactive job

    qsub -IX -N OpenFOAM_4.1 -l walltime=24:0:0 -l select=1 -A [your budget code]

Load the required modules:

    module load gcc/6.2.0
    module load mpt/2.14
    module load zlib-1.2.8-gcc-6.2.0-epathtp
    module load gmp-6.1.2-gcc-6.2.0-2skcnwh
    module load mpfr-3.1.4-gcc-6.2.0-thlrxaq 
    module load flex-2.6.1-gcc-6.2.0-sywhrx4 cmake-3.7.1-gcc-6.2.0-75ivp2c 

Build Third Party software:

    cd OpenFOAM
    source OpenFOAM-4.1/etc/bashrc
    cd $WM_THIRD_PARTY_DIR
    export QT_SELECT=qt4
    ./Allwmake -j 24 > log.make 2>&1
    wmRefresh

Build OpenFOAM 4.1

    cd $WM_PROJECT_DIR
    ./Allwmake -j 24 > log.make 2>&1
    wmRefresh

Test build
----------

Submit an interactive job

    qsub -IX -N OpenFOAM_4.1 -l walltime=24:0:0 -l select=1 -A [your budget code]

Load the required modules:

    module load gcc/6.2.0
    module load mpt/2.14
    module load zlib-1.2.8-gcc-6.2.0-epathtp
    module load gmp-6.1.2-gcc-6.2.0-2skcnwh
    module load mpfr-3.1.4-gcc-6.2.0-thlrxaq 
    module load flex-2.6.1-gcc-6.2.0-sywhrx4 cmake-3.7.1-gcc-6.2.0-75ivp2c 

Run the test program:

    icoFoam -help

