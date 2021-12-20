Instructions for installing GSL 2.7.0 on ARCHER2
================================================

These instructions show how to install GSL 2.7.0 for use on ARCHER2 (HPE Cray EX, AMD Zen2 7742).


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work
GSL_LABEL=gsl
GSL_VERSION=2.7
GSL_NAME=${GSL_LABEL}-${GSL_VERSION}
```

Remember to change the setting for `PRFX` to a path appropriate for your ARCHER2 project.


Download the GSL library source code
------------------------------------

```bash
mkdir -p ${PRFX}/${GSL_LABEL}
cd ${PRFX}/${GSL_LABEL}

rm -rf ${GSL_NAME}
wget http://mirror.koddos.net/gnu/${GSL_LABEL}/${GSL_NAME}.tar.gz
tar -xzf ${GSL_NAME}.tar.gz
rm ${GSL_NAME}.tar.gz
cd ${GSL_NAME}
```


Build the GSL library for all three ARCHER2 programming environments
--------------------------------------------------------------------

```bash
PE_RELEASE=21.09
declare -a PE_LABEL=("cray" "gnu" "aocc")

for pel in "${PE_LABEL[@]}"; do
  module -q restore
  module -q load cpe/${PE_RELEASE}
  module -q load PrgEnv-${pel}

  export LD_LIBRARY_PATH=${CRAY_LD_LIBRARY_PATH}:${LD_LIBRARY_PATH}

  PE_NAME=${PE_MPICH_FIXED_PRGENV}
  PE_VERSION=$(eval echo "\${PE_MPICH_GENCOMPILERS_${PE_NAME}}")

  ./configure CC=cc --prefix=${PRFX}/${GSL_LABEL}/${GSL_VERSION}/${PE_NAME}/${PE_VERSION}
  make
  make check
  make install
  make clean
done
```
