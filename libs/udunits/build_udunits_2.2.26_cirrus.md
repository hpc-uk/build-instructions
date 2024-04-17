Instructions for installing UDUNITS 2.2.26 on Cirrus
====================================================

These instructions show how to install UDUNITS 2.2.26 for use on Cirrus (SGI ICE XA, Intel Xeon E5-2695).


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., PRFX=/work/y07/shared/cirrus-software
UDUNITS_LABEL=udunits
UDUNITS_VERSION=2.2.26
UDUNITS_NAME=${UDUNITS_LABEL}-${UDUNITS_VERSION}
UDUNITS_ARCHIVE=${UDUNITS_NAME}.tar.gz
UDUNITS_INSTALL=${PRFX}/${UDUNITS_LABEL}/${UDUNITS_VERSION}

mkdir -p ${PRFX}/${UDUNITS_LABEL}
cd ${PRFX}/${UDUNITS_LABEL}
```

Remember to change the setting for `PRFX` to a path appropriate for your Cirrus project.


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

module load gcc/10.2.0

./configure --prefix=${UDUNITS_INSTALL}

make
make install
make clean
```
