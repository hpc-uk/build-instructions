Instructions for installing UDUNITS 2.2.28 on ARCHER2
=====================================================

These instructions show how to install UDUNITS 2.2.28 for use on ARCHER2 (HPE Cray EX, AMD Zen2 7742).


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work
UDUNITS_LABEL=udunits
UDUNITS_VERSION=2.2.28
UDUNITS_NAME=${UDUNITS_LABEL}-${UDUNITS_VERSION}
UDUNITS_ARCHIVE=${UDUNITS_NAME}.tar.gz
UDUNITS_INSTALL=${PRFX}/${UDUNITS_LABEL}/${UDUNITS_VERSION}

mkdir -p ${PRFX}/${UDUNITS_LABEL}
cd ${PRFX}/${UDUNITS_LABEL}
```

Remember to change the setting for `PRFX` to a path appropriate for your ARCHER2 project.


Download the UDUNITS source code
--------------------------------

```bash
wget https://artifacts.unidata.ucar.edu/repository/downloads-${UDUNITS_LABEL}/${UDUNITS_ARCHIVE}
tar -xvzf ${UDUNITS_ARCHIVE}
rm ${UDUNITS_ARCHIVE}
```


Build UDUNITS
-------------

```bash
cd ${UDUNITS_NAME}

module -q restore
module -q load PrgEnv-gnu

./configure --prefix=${UDUNITS_INSTALL}

make
make install
make clean
```
