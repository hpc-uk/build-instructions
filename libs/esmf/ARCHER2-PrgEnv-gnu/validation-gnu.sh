#!/usr/bin/env bash

#SBATCH --partition=standard
#SBATCH --qos=standard

#SBATCH --time=02:00:00

#SBATCH --export=none
#SBATCH --exclusive

set -e

printf "Start at: %s\n" "$(date)"

version=8.6.1

module use $(pwd)/modulefiles
module load ESMF/${version}
module list

# For validation, a fresh copy of the source directory is required.
# But we need to copy the build_rules.mk file again.

rules=$(pwd)/Unicos.gfortran.default.build_rules.mk

rm -rf esmf-${version}
tar xf v${version}.tar.gz

cd esmf-${version}
export ESMF_DIR=$(pwd)

cp ${rules} build_config/Unicos.gfortran.default/build_rules.mk

export ESMF_TESTESMFMKFILE=ON
export ESMF_TESTEXHAUSTIVE=ON
printf "ESMFMKFILE:            %s\n" "${ESMFMKFILE}"
printf "ESMF_TESTESMFMKFILE:   %s\n" "${ESMF_TESTESMFMKFILE}"

make unit_tests_uni
make unit_tests

make system_tests_uni
make system_tests

make examples

module list

printf "Start at: %s\n" "$(date)"
