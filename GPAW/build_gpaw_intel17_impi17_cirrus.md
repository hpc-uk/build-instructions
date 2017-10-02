Building GPAW on Cirrus (Intel 17.0.2.174, Compilers and MPI)
===================================================

Provided by Andrew Logsdail, Cardiff University.

These instructions are for a simple build of GPAW on Cirrus (SGI/HPE ICE XA, Intel Broadwell) using the Intel 17.0.2.174 compilers. Parts of this compilation guide are taken from the [GPAW webpages](https://wiki.fysik.dtu.dk/gpaw/install.html), which are an excellent resource if you encounter problems.

Setup your environment
----------------------

Load the correct modules:

    module load intel-compilers-17
    module load intel-mpi-17/17.0.2.174
    module load anaconda/python3

It is also necessary to export the following in your runtime environment:

    export PYTHONHOME=/lustre/sw/anaconda/anaconda3/

Pre-requisite: Download and compile LibXC
-----------------------------------------

Download and install [LibXC](http://www.tddft.org/programs/octopus/wiki/index.php/Libxc) as described [here](http://www.tddft.org/programs/octopus/wiki/index.php/Libxc:download). Once on the files are uncompressed on Cirrus, the suggested configuration, compilation and installation commands are:

    ./configure --enable-shared --prefix=/lustre/home/<BUDGET>/<USERNAME>/path/to/libxc
    make
    make install

where `<BUDGET>` and `<USERNAME>` are to be replaced with the respective user's settings, and `/path/to` to be replaced with your own desired install location.

It is also necessary to export the following in your runtime environment:

    export C_INCLUDE_PATH=/lustre/home/<BUDGET>/<USERNAME>/path/to/libxc/include:$C_INCLUDE_PATH
    export LIBRARY_PATH=/lustre/home/<BUDGET>/<USERNAME>/path/to/libxc/lib:$LIBRARY_PATH
    export LD_LIBRARY_PATH=/lustre/home/<BUDGET>/<USERNAME>/libxc/lib:$LD_IBRARY_PATH

with the same thing applying with respect to `<BUDGET>`, `<USERNAME>` and `/path/to`

Compile MPI Version
-------------------

With the appropriate environment loaded, this can be simply achieved using:

    pip install --upgrade --user gpaw

This will compile and install GPAW in your `.local` directory. To check the compiled parallel features, type: 

   gpaw-python $(which gpaw) info

*Note: this compilation will not include ScaLAPACK - a customised installation seems necessary for this, though all other pre-requisites can be still installed using pip.*

Additional requirement: Download GPAW-Setups
--------------------------------------------

The PAW datasets can be automatically installed by running:

    gpaw install-data /path/to

with the newest package installed into `path/to/gpaw-setups-<version>`. Again, note that `/path/to` is to be set by the user. When prompted, answer yes (y) to register the path in the GPAW configuration file.

Alternatively, for manual installation one must download and unzip the data files into a desired directory; it is then necessary to export the following in your runtime environment:

    export GPAW_SETUP_PATH=/lustre/home/<BUDGET>/<USERNAME>/path/to/gpaw-setups

where again `<BUDGET>`, `<USERNAME>` and `/path/to` are to be altered appropriately.

*Tip: Download and store the setups in a specific folder with their version number, `e.g. gpaw-setups-0.9.20000`, and then create a static link called to a folder called `gpaw-setups`:*

    ln -s gpaw-setups-0.9.20000 gpaw-setups

Thus the setup version can be easily changed without causing confusion as to the current version being used.

Running MPI Version
-------------------

Test serial setup (exhaustively) with:

    gpaw test -j 4

Test parallel setup (quickly) with:

    mpirun -n 4 gpaw-python `which gpaw` test

Use at runtime normally with:

    mpirun -n <#PROCESSORS> gpaw-python <INPUT_SCRIPT>

where <#PROCESSORS> and <INPUT_SCRIPT> are to be replaced with the number of cores allocated and the input python file.
