Instructions to install SWAN on Cirrus
Gavin Pringle <gavin@epcc.ed.ac.uk>
18 Jan 2017

There is a file called INSTALL.README in the swan 4091 folder which
gives the basis of compiling the code.

The swan code can be downloaded from here: http://www.swan.tudelft.nl 

You will need to edit the platform.pl to point to the MPI compiler. For
Cirrus, use mpif90 which is reflected in the following line in
platform.pl: print OUTFILE "F90_MPI = mpif90\n";

After that is should be just a simple compile operation:
    module load mpt
    module load intel-compilers-16
	make clean
	make config
	make mpi

The executable will be named swan.exe if you use default naming.

On Cirrus, the following error message may appear "Severe error : All
free units used". The solution is to change "highest file
ref. number" in swaninit from 99 to 999

