# Installing deal.II 9.5.1 on ARCHER2

These instructions describe how to install deal.II on ARCHER2. deal.II is a dependency of the ASPECT code.

## Preparation

These commands prepare the environment for the installation of deal.II. If you will later on be building ASPECT as well, the same commands are used then.

Begin by preparing the build environment. We'll use the GCC compilers and need to tell any build scripts along the way to use the Cray compiler wrappers. The link type should be dynamic even without `CRAYPE_LINK_TYPE` but setting it here prevents warnings from candi.

```bash
module swap PrgEnv-cray PrgEnv-gnu 
export CC=cc
export CXX=CC
export FC=ftn
export FF=ftn
export CRAYPE_LINK_TYPE=dynamic
```

Then set the install location using the `PREFIX` environment variable which will be referenced by the commands below.

```bash
export PREFIX=/work/path/to/your/chosen/directory
```

The `PREFIX` should be in your `/work` directory; remember that the `/home` file system cannot be accessed from the ARCHER2 compute nodes.

## Installing deal.II using candi

These instructions detail how to build deal.II 9.5.1 on ARCHER2 using the candi build script.

Move into a directory within your work directory. This is a build directory and should be distinct from the final install location. We clone the 9.5 branch of the candi installer only. At the time of writing, this is at the 9.5.1 release.

```bash
git clone -b dealii-9.5 --single-branch https://github.com/dealii/candi.git
```

Now move into the `candi` directory and edit the Cray config file to make sure it doesn't try to link against a C++ MPICH library which doesn't exist on ARCHER2. I use `vim` here but you can use whichever text editor is your preference.

```bash
cd candi
vim deal.II-toolchain/platforms/contributed/cray.platform
```

Add `once:sundials` to `PACKAGES` to ensure that candi builds a version of deal.II which supports SUNDIALS, which is needed by ASPECT. This line should now read:

```bash
PACKAGES="load:dealii-prepare once:cmake once:p4est once:trilinos once:parmetis once:petsc once:sundials dealii"
```

Then edit the `DEAL_II_CONFOPTS`. We need to make three changes and two additions. Both `DEAL_II_WITH_LAPACK` and `DEAL_II_WITH_BLAS` should be set to `ON`, and `${MPICH_DIR}/lib/libmpichcxx.so` needs to be removed from `MPI_CXX_LIBRARIES`. The addition are two new options, `LAPACK_LIBRARIES` and `BLAS_LIBRARIES`, which should both be set to `libsci_gnu_mpi.so`. When this is done, the `DEAL_II_CONFOPTS` should be read as follows:

```bash
DEAL_II_CONFOPTS="\
  -D DEAL_II_COMPILER_HAS_FUSE_LD_GOLD:BOOL=OFF \
  -D DEAL_II_WITH_LAPACK:BOOL=ON \
  -D LAPACK_LIBRARIES=libsci_gnu_mpi.so \
  -D DEAL_II_WITH_BLAS:BOOL=ON \
  -D BLAS_LIBRARIES=libsci_gnu_mpi.so \
  -D DEAL_II_WITH_GSL:BOOL=OFF \
  -D DEAL_II_WITH_BZIP2:BOOL=OFF \
  -D DEAL_II_FORCE_BUNDLED_BOOST:BOOL=ON \
  -D DEAL_II_WITH_UMFPACK:BOOL=OFF \
  -D MPI_INCLUDE_PATH=${MPICH_DIR}/include \
  -D MPI_CXX_LIBRARIES=\"${MPICH_DIR}/lib/libmpich.so\" "
```

When this is done, you can save and close the file. Then, in the main `candi` directory, run it with the command:

```bash
./candi.sh --prefix=$PREFIX --platform=./deal.II-toolchain/platforms/contributed/cray.platform -j 8
```

Press enter for all options when prompted. candi will take quite a long time to build and install deal.II and its dependencies, potentially ~an hour or more.

## Post-install: fix MPI bool types in C++ for ARCHER2

MPICH on ARCHER2 does not define an `MPI_CXX_BOOL` type, but deal.II uses it. After installing deal.II, open `$PREFIX/deal.II-v9.5.1/include/base/mpi.h`. At line 1565 is the function:

```c++
inline MPI_Datatype
mpi_type_id(const bool *)
{
    return MPI_CXX_BOOL;
}
```

Change the return type from `MPI_CXX_BOOL` to `MPI_C_BOOL`:

```c++
    inline MPI_Datatype
    mpi_type_id(const bool *)
    {
        return MPI_C_BOOL;
    }
```

This ensures that code such as ASPECT built against deal.II will be able to use bool types in MPI. Without this change, the code will run into 'Invalid datatype' MPI errors.
