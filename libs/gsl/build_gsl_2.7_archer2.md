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


Addendum: build tests
---------------------

The `make check` command performs a number of tests, all of which pass for the Cray and AMD programming environments.
However, for `PrgEnv-gnu`, two tests fail, `linalg` and `multilarge_nlinear`. The failures are due to very slight differences
between the computed and expected values (e.g., for the `multilarge_nlinear` tests the computed values start to differ
from the 8th decimal place). For this reason, these *failures* will simply be noted for now.

```bash
linalg

FAIL: cholesky_invert unscaled hilbert (  4,  4)[0,2]: (2.55795384873636067e-13 observed vs 0 expected) [28190582]
```

```bash
multilarge_nlinear

FAIL: trust-region/steihaug-toint/solver=mcholesky/scale=levenberg/linear_rank1zeros coeff sum (0.0309278346895478506 observed vs0.0309278350515463929 expected) [10927]
FAIL: trust-region/steihaug-toint/solver=mcholesky/scale=levenberg/weighted/linear_rank1zeros coeff sum (0.0309278346895478506 observed vs 0.0309278350515463929 expected) [10930]
FAIL: trust-region/steihaug-toint/solver=mcholesky/scale=levenberg/linear_rank1zeros coeff sum (0.0309278346895478506 observed vs 0.0309278350515463929 expected) [11343]
FAIL: trust-region/steihaug-toint/solver=mcholesky/scale=levenberg/weighted/linear_rank1zeros coeff sum (0.0309278346895478506 observed vs 0.0309278350515463929 expected) [11346]
FAIL: trust-region/steihaug-toint/solver=mcholesky/scale=levenberg/linear_rank1zeros coeff sum (0.0309278346895478506 observed vs 0.0309278350515463929 expected) [11435]
FAIL: trust-region/steihaug-toint/solver=mcholesky/scale=levenberg/weighted/linear_rank1zeros coeff sum (0.0309278346895478506 observed vs 0.0309278350515463929 expected) [11438]
FAIL: trust-region/steihaug-toint/solver=mcholesky/scale=levenberg/linear_rank1zeros coeff sum (0.0309278346895478506 observed vs 0.0309278350515463929 expected) [11851]
FAIL: trust-region/steihaug-toint/solver=mcholesky/scale=levenberg/weighted/linear_rank1zeros coeff sum (0.0309278346895478506 observed vs 0.0309278350515463929 expected) [11854]
FAIL: trust-region/steihaug-toint/solver=mcholesky/scale=more/linear_rank1zeros coeff sum (0.0309278346895478506 observed vs 0.0309278350515463929 expected) [11943]
FAIL: trust-region/steihaug-toint/solver=mcholesky/scale=more/weighted/linear_rank1zeros coeff sum (0.0309278346895478506 observed vs 0.0309278350515463929 expected) [11946]
FAIL: trust-region/steihaug-toint/solver=mcholesky/scale=more/linear_rank1zeros coeff sum (0.0309278346895478506 observed vs 0.0309278350515463929 expected) [12359]
FAIL: trust-region/steihaug-toint/solver=mcholesky/scale=more/weighted/linear_rank1zeros coeff sum (0.0309278346895478506 observed vs 0.0309278350515463929 expected) [12362]
FAIL: trust-region/steihaug-toint/solver=mcholesky/scale=more/linear_rank1zeros coeff sum (0.0309278346895478506 observed vs 0.0309278350515463929 expected) [12451]
FAIL: trust-region/steihaug-toint/solver=mcholesky/scale=more/weighted/linear_rank1zeros coeff sum (0.0309278346895478506 observed vs 0.0309278350515463929 expected) [12454]
FAIL: trust-region/steihaug-toint/solver=mcholesky/scale=more/linear_rank1zeros coeff sum (0.0309278346895478506 observed vs 0.0309278350515463929 expected) [12867]
FAIL: trust-region/steihaug-toint/solver=mcholesky/scale=more/weighted/linear_rank1zeros coeff sum (0.0309278346895478506 observed vs 0.0309278350515463929 expected) [12870]
```
