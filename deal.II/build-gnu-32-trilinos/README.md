# deal.II

Version 8.5.1, with Gnu compilers, 32 bit indices and the following
optional packages:
* HDF5
* LAPACK
* METIS
* MPI
* p4est
* Trilinos

The short version:
1. If you need to, download the source tarballs using the `download.sh` script
1. Edit `env.sh` as follows:
   - Name your configuration by setting `$config_name`.  This one is called `gnu-32-trilinos`.
   - Choose the installation directory by setting `install_dir` (at least change `A99/A99/username`)
1. Change `A99-xacc` to your account name in the job scripts `build.pbs` and `test.pbs`
1. Change the `Installed on` string in `package.sh`
1. Run `master.sh`, which sources the other scripts in turn and submits a job to do the build.
1. Once deal.II is built (check the logs), run the tests using `qsub test.pbs`
1. If the tests pass (one will fail - that is normal), run `package.sh` to create a module to make using the library easier.  The modulefile is in the `build/modulefiles/deal_II` directory.

## download.sh
Downloads deal.II and p4est.

## unpack.sh
Unpacks deal.II.

## change.sh
Modifies some deal.II CMake files to build on Archer.

## env.sh
This sets up some varibles with paths and exports
`CRAYPE_LINK_TYPE=dynamic`.

## modules.sh
Loads required modules

## build_p4est.sh
Builds the p4est library.

## configure.sh
This sets all the various CMake variables needed. Note it uses a tmp
dir as bash doesn't have an associative array type (like e.g. python
dicts).  Then this calls cmake - this is quite slow.

## build.pbs
`make install`

## test.pbs
Runs the deal.II quick tests.  The affinity test will fail - this
is expected on Archer.

## package.sh
Create a modulefile for deal_II.  If run as the cse user, will sudo
install the modulefile.
