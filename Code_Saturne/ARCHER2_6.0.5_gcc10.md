# Code_Saturne 6.0.5

Version 6.0.5 is the current production version as of the time of writing, but the latest development version 6.2.0 may be installed following the exact same procedure. [Full installation documentation may be read here.](https://www.code-saturne.org/cms/sites/default/files/docs/6.0/install.pdf)

- [Code_Saturne 6.0.5](#code_saturne-605)
  - [Installation without GUI and ParMETIS/Scotch](#installation-without-gui-and-parmetisscotch)
    - [Prepare the environment](#prepare-the-environment)
    - [Create install directory](#create-install-directory)
    - [Create source directory and download Code_Saturne source](#create-source-directory-and-download-code_saturne-source)
    - [Installing CGNS](#installing-cgns)
    - [Installing Code_Saturne](#installing-code_saturne)
    - [Post install configuration](#post-install-configuration)

## Installation without GUI and ParMETIS/Scotch

### Prepare the environment

Load GCC, HDF5 and Python and make sure that the compiler wrappers will be used.

```bash
module restore PrgEnv-gnu
module load cray-hdf5-parallel
module load cray-python
export CC=cc
export CXX=CC
export FC=ftn
export F77=ftn
export F90=ftn
```

### Create install directory

Create the directory in which Code_Saturne will be installed (here a directory
in `opt` in the user's `work` directory) and store the location in an
environment variable.

```bash
cd /work/<project>/<project>/<username>/opt
mkdir code_saturne
cd code_saturne
mkdir code_saturne-6.0.5
cd code_saturne-6.0.5
export PREFIX_DIR=$(pwd)
```

### Create source directory and download Code_Saturne source

We'll build in the user's home directory.

```bash
cd ~
mkdir code_saturne
```

### Installing CGNS

This simple installation will only have CGNS as an extra prerequisite. `cd` to
the source directory, download, extract, and create a build directory. Then run
CMake, setting the options to it via `ccmake` as doing things out of order means
it can't find HDF5.

```bash
cd ~/code-saturne
curl -LJO https://github.com/CGNS/CGNS/tarball/v4.1.1
tar xzvf CGNS-CGNS-v4.1.1-0-g3db2f22.tar.gz
cd CGNS-CGNS-3db2f22
mkdir build
cd build
cmake ..
ccmake .
```

In the `ccmake .` step set the following options. CMake seems to have trouble
finding HDF5 which is why we do this rather than providing them as options to
`cmake` -- enabling HDF5, then configuring, then enabling MPI for HDF5, then
configuring again should work.

```text
CGNS_ENABLE_64BIT:BOOL=ON
CGNS_ENABLE_FORTRAN:BOOL=ON
CGNS_ENABLE_HDF5:BOOL=ON
CGNS_ENABLE_PARALLEL:BOOL=ON
HDF5_NEED_MPI:BOOL=ON
HDF5_NEED_ZLIB:BOOL=ON
CMAKE_INSTALL_PREFIX:PATH=/work/<project>/<project>/<username>/opt/code_saturne/code_saturne-6.0.5
```

The install prefix is the same one that was used above.

Once done, build and install:

```bash
make
make install
```

### Installing Code_Saturne

`cd` to the source directory, download the Code_Saturne source, extract it, and
then move into the new directory.

```bash
cd ~/code_saturne
wget https://www.code-saturne.org/cms/sites/default/files/releases/code_saturne-6.0.5.tar.gz
tar xzvf code_saturne-6.0.5.tar.gz
cd code_saturne-6.0.5
```

ARCHER2 does not have an `/etc/issue` file. This causes an error when
Code_Saturne tries to open it, fails, then tries to `fclose()` the `NULL`
pointer. To fix it, edit `src/base/cs_system_info.c`, find the
following

```C
        else /* If no info was kept, empty string */
          issue_str[0] = '\0';
      }
    }

    fclose (fp);

  }

#endif
}
```

and move the `fclose(fp)` just inside the curly bracket above so it reads

```C
        else /* If no info was kept, empty string */
          issue_str[0] = '\0';
      }
      fclose (fp);
    }

  }

#endif
}
```

Then configure, build and install.

```bash
./configure --host=x86_64-unknown-linux-gnu --disable-gui --disable-nls --disable-rpath --enable-long-gnum --without-modules --without-salome --without-metis --without-scotch --with-mpi --with-cgns=$PREFIX_DIR --with-cgns-include=$PREFIX_DIR/include --with-cgns-lib=$PREFIX_DIR/lib --with-blas=$CRAY_LIBSCI_PREFIX_DIR --with-blas-include=$CRAY_LIBSCI_PREFIX_DIR/include --with-blas-lib=$CRAY_LIBSCI_PREFIX_DIR/lib --with-blas-libs=-lsci_gnu --prefix=$PREFIX_DIR
make
make install
```

### Post install configuration

Code_Saturne must be configured to use Slurm. Go to the install location and
copy the template configuration file.

```bash
cd $PREFIX_DIR/etc
cp code_saturne.cfg.template code_saturne.cfg
```

Find and edit the following options in `code_saturne.cfg` so that they read as
the following:

```text
batch = SLURM
mpiexec = srun
```

Edit the template sbatch file `$PREFIX_DIR/share/code_saturne/batch/batch.SLURM`.
Set `tasks-per-node` to 128 and remove the line setting the partition.
