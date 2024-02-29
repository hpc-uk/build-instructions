Instructions for building METIS 5.1.0 on Cirrus
===============================================

These instructions are for building METIS 5.1.0 on Cirrus (SGI ICE XA, Intel Xeon Broadwell (CPU) and Cascade Lake (GPU)) using gcc 10.2.0.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work  # e.g., PRFX=/work/y07/shared/cirrus-software
METIS_LABEL=metis
METIS_VERSION=5.1.0
METIS_NAME=${METIS_LABEL}-${METIS_VERSION}

cd ${PRFX}
mkdir -p ${METIS_LABEL}
cd ${METIS_LABEL}

wget http://glaros.dtc.umn.edu/gkhome/fetch/sw/${METIS_LABEL}/${METIS_NAME}.tar.gz
tar -xzf ${METIS_NAME}.tar.gz
rm ${METIS_NAME}.tar.gz

cd ${METIS_NAME}
```

Remember to change the setting for `PRFX` to a path appropriate for your Cirrus project.


Build and install METIS
-----------------------

```bash
module load gcc/10.2.0
module load cmake/3.25.2

sed -i 's:IDXTYPEWIDTH 32:IDXTYPEWIDTH 64:g' ${PRFX}/${METIS_LABEL}/${METIS_NAME}/include/metis.h

make config prefix=${PRFX}/${METIS_LABEL}/${METIS_VERSION}
make install
make clean

make config shared=1 prefix=${PRFX}/${METIS_LABEL}/${METIS_VERSION}
make install
make clean
```
