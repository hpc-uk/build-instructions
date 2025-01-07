# Earth System Modelling Framework (ESMF)

See e.g., https://github.com/esmf-org/esmf

Select an appropriate location on /work and arrange the accompanying
scripts and makefile fragments in this location.

## Download

Download an appropriate tar for the version required and place it
the same location. E.g., here we have
```
$ wget https://github.com/esmf-org/esmf/archive/refs/tags/v8.6.1.tar.gz
$ ls
build-esmf-gnu.sh  Unicos.gfortran.default.build_rules.mk  validation-gnu.sh
modulefiles        v8.6.1.tar.gz
```

## Build, test, and install

As the tests must run in the batch system, it is convenient to express
the installation process as a slurm script `build-esmf-gnu.sh`.

Review the script, and check the version is consistent with the tar
file(s) available
```
version=8.6.1
```
The script will automatically copy the makefile fragment
`Unicos.gfortran.default.build_rules.mk` to the appropriate location.

Note that the "Unicos" is something of an anachronism, but the settings
should be appropriate. If a "Linux" version is wanted, it should be
possible to make an analogous copy.

Reiview the installation prefix, which is set as
```
prefix="$(pwd)/ESMF/${version}"
```

Submit the script
```
$ sbatch build-esmf-gnu.sh
```
This should take around 90 minutes. It should report:
```
Found 12425 exhaustive single processor unit tests, 12425 passed and 0 failed.
Found 14093 exhaustive multi-processor unit tests, 14093 passed and 0 failed.
Found 8 single processor system tests, 8 passed and 0 failed.
Found 49 multi-processor system tests, 49 passed and 0 failed.
Found 81 multi-processor examples, 81 passed and 0 failed.
```
(`grep failed` might be useful).

The installation should be available in subdirectory `ESMF`.

## Module file

An example module file is provided in `modulefiles/ESMF/8.6.1.lua`. This
must be updated to be consistent with the appropriate install location
and the current version. The relevant lines are
```
local INSTALL_ROOT        = "/path/to/install"
local VERSION             = "8.6.1"
local COMPAT_VERSION      = "8.6"
```
This is required for the validation step, which expects to find the
`modulefiles` directory in the current working directory.

## Validation

Validation requires a clean build directory so, e.g.,
```
$ rm -rf esmf-8.6.1
$ tar xf v8.6.1.tar.gz
```
(actually performed in the `validation-gnu.sh` script).

Review the validation slurm script `validation-gnu.sh` to check the
version and the Makefile fragment:
```
version=8.6.1
rules=$(pwd)/Unicos.gfortran.default.build_rules.mk
```

Submit the validation script
```
$ sbatch validation-gnu.sh
```
which should compile and run the tests against the installed version
under `ESMF` and report the same results as seen above.
