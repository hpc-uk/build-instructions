# Installing ASPECT 3.0.0 on ARCHER2

These instructions describe how to install ASPECT on ARCHER2. You will need to install deal.II beforehand, as described [here](../deal.II/archer2/deal-ii-9.5-archer2.md). The instructions assume that both will be installed to the same directory tree, which should, as always on ARCHER2, be in your `/work` directory to ensure that the installation can be accessed from the compute nodes.

## Preparation

These commands prepare the environment for the installation of ASPECT. Note that they are identical to what was used when building deal.II. If you logged out part way through the process (for example, after installing deal.II but before installing ASPECT), you will need to re-run them.

Begin by preparing the build environment. We'll use the GCC compilers and need to tell any build scripts along the way to use the Cray compiler wrappers.

```bash
module swap PrgEnv-cray PrgEnv-gnu 
export CC=cc
export CXX=CC
export FC=ftn
export FF=ftn
export CRAYPE_LINK_TYPE=dynamic
```

Then set the install location using the `PREFIX` environment variable which will be referenced by the commands below. Here we assume that you `PREFIX` is the same that you used when installing deal.II.

```bash
export PREFIX=/work/path/to/your/chosen/directory
```

As mentioned above, deal.II must be installed before ASPECT. If you have not yet done so, please [install deal.II now](../deal.II/archer2/deal-ii-9.5-archer2.md) and then return here to continue with the installation of ASPECT.

## Installing ASPECT

Download the ASPECT source code:

```bash
git clone https://github.com/geodynamics/aspect.git
```

Check out the branch or commit you wish to build. These instruction were tested with the `v3.0.0` tagged commit:

```bash
git checkout v3.0.0
```

We will need to replace `MPI_CXX_BOOL` with `MPI_C_BOOL` in the source, just as the deal.II headers required. Open the file `aspect/source/utilities.cc` and at line 80 find the function

```c++
inline MPI_Datatype
mpi_type_id(const bool *)
{
    return MPI_CXX_BOOL;
}
```

where we need to change `MPI_CXX_BOOL` to `MPI_C_BOOL`:

```c++
inline MPI_Datatype
mpi_type_id(const bool *)
{
    return MPI_C_BOOL;
}
```

Now `cd` into the main `aspect` directory, make and go into a `build` directory, then compile and install ASPECT. By default this is a `DebugRelease` build which compiles both debug and release versions. If you would like to build only one, run either `make release` or `make debug` immediately after the `cmake` step.

```bash
cd aspect
mkdir build
cd build
cmake .. -DDEAL_II_DIR=$PREFIX -DCMAKE_INSTALL_PREFIX=$PREFIX/aspect-3.0.0
make -j 8
make install
```

This will build ASPECT and install it into a directory called `aspect-3.0.0` alongside your deal.II installation. You will find the executables `aspect-release` and `aspect-debug` in `$PREFIX/aspect-3.0.0/bin`. Please note that `aspect` is a symbolic link to `aspect-debug`. Use the release build for production work, and the debug build if you run into errors.
