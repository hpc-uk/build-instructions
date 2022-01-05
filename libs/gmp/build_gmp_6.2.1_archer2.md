Instructions for installing GMP 6.2.1 on ARCHER2
================================================

These instructions show how to install GMP 6.2.1 for use on ARCHER2 (HPE Cray EX, AMD Zen2 7742).


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work
GMP_LABEL=gmp
GMP_VERSION=6.2.1
GMP_NAME=${GMP_LABEL}-${GMP_VERSION}
```

Remember to change the setting for `PRFX` to a path appropriate for your ARCHER2 project.


Download the GMP library source code
------------------------------------

```bash
mkdir -p ${PRFX}/${GMP_LABEL}
cd ${PRFX}/${GMP_LABEL}

rm -rf ${GMP_NAME}
wget http://mirror.koddos.net/gnu/${GMP_LABEL}/${GMP_NAME}.tar.bz2
tar -xf ${GMP_NAME}.tar.bz2
rm ${GMP_NAME}.tar.gz
cd ${GMP_NAME}
```


Build the GMP library for all three ARCHER2 programming environments
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

  ./configure CC=cc --prefix=${PRFX}/${GMP_LABEL}/${GMP_VERSION}/${PE_NAME}/${PE_VERSION}
  make
  make check
  make install
  make clean
done
```
