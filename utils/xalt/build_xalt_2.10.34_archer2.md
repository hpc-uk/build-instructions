Instructions for building XALT 2.10.34 on ARCHER2
================================================

These instructions are for building XALT 2.10.34 on the ARCHER2 full system (HPE Cray EX, AMD Zen2 7742) using GCC 11.


Setup initial environment
-------------------------

```bash
PRFX=/path/to/work
XALT_LABEL=xalt
XALT_VERSION=2.10.34
XALT_NAME=${XALT_LABEL}-${XALT_VERSION}
XALT_ROOT=${PRFX}/${XALT_LABEL}
XALT_INSTALL=${XALT_ROOT}/${XALT_VERSION}
XALT_ETC=${XALT_INSTALL}/etc
XALT_CONFIG=${XALT_ROOT}/${XALT_NAME}/Config
XALT_TACC_CONFIG=${XALT_CONFIG}/TACC_config.py
XALT_ARCHER2_CONFIG=${XALT_CONFIG}/ARCHER2_config.py
XALT_REVMAP_SCRIPT=${XALT_ROOT}/${XALT_NAME}/contrib/build_reverseMapT_cray/cray_build_rmapT.sh
UUID_INSTALL=/work/y07/shared/libs/core/libuuid/1.0.3
```

Remember to change the setting for `PRFX` to a path appropriate for your ARCHER2 project.


Download source code
--------------------

```bash
mkdir -p ${XALT_ROOT}
cd ${XALT_ROOT}

wget https://github.com/${XALT_LABEL}/${XALT_LABEL}/archive/refs/tags/${XALT_NAME}.tar.gz

tar -xvzf ${XALT_NAME}.tar.gz
rm ${XALT_NAME}.tar.gz
mv ${XALT_LABEL}-${XALT_NAME} ${XALT_NAME}
cd ${XALT_NAME}
```


Load modules
------------

```bash
module -q restore
module -q load cpe/21.09
module -q load PrgEnv-gnu
module -q load cray-python

export LD_LIBRARY_PATH=${CRAY_LD_LIBRARY_PATH}:${LD_LIBRARY_PATH}
```


Amend XALT config files
-----------------------

```bash
cp ${XALT_TACC_CONFIG} ${XALT_ARCHER2_CONFIG}

# add hostname patterns for the data visualisation and compute nodes
sed -i "s:c\[0-9\]\[0-9\]\[0-9\]-\[0-9\]\[0-9\]\[0-9\]\\\.\.\*:dvn0\[1-2\]:g" ${XALT_ARCHER2_CONFIG}
sed -i "s:nid\[0-9\]\[0-9\]\[0-9\]\[0-9\]\[0-9\]\.\*:nid\[0-9\]\[0-9\]\[0-9\]\[0-9\]\[0-9\]\[0-9\]:g" ${XALT_ARCHER2_CONFIG}

# ignore compiler wrappers and Slurm job launcher
sed -i "110 i \    ['SKIP',  r'^\\\/opt\\\/cray\\\/pe\\\/craype\\\/default\\\/bin\\\/cc']," ${XALT_ARCHER2_CONFIG}
sed -i "111 i \    ['SKIP',  r'^\\\/opt\\\/cray\\\/pe\\\/craype\\\/default\\\/bin\\\/CC']," ${XALT_ARCHER2_CONFIG}
sed -i "112 i \    ['SKIP',  r'^\\\/opt\\\/cray\\\/pe\\\/craype\\\/default\\\/bin\\\/ftn']," ${XALT_ARCHER2_CONFIG}
sed -i "113 i \    ['SKIP',  r'^\\\/usr\\\/bin\\\/srun']," ${XALT_ARCHER2_CONFIG}

# edit reverse map generation script
sed -i "s:PrgEnvA=(\"PrgEnv-cray\" \"PrgEnv-gnu\" \"PrgEnv-intel\" \"PrgEnv-pgi\"):PrgEnvA=(\"PrgEnv-cray\" \"PrgEnv-gnu\" \"PrgEnv-aocc\"):g" ${XALT_REVMAP_SCRIPT}
sed -i -e '38,39d' ${XALT_REVMAP_SCRIPT}
sed -i "38 i \  GCC_Vers=\$(module spider gcc 2>&1 | grep \"\\\  gcc\/\" | xargs)" ${XALT_REVMAP_SCRIPT}
sed -i "s:PATH=\$SCRIPT_DIR\:\$LMOD_DIR/lmod/lmod/libexec\:\$PATH:PATH=\$SCRIPT_DIR\:\$LMOD_DIR\:\$PATH:g" ${XALT_REVMAP_SCRIPT}
sed -i "s:module unload:module -q unload:g" ${XALT_REVMAP_SCRIPT}
sed -i "s:module load:module -q load:g" ${XALT_REVMAP_SCRIPT}
sed -i "s:module swap:module -q swap:g" ${XALT_REVMAP_SCRIPT}

# generate reverse maps used for function tracking
${XALT_REVMAP_SCRIPT} ${XALT_ETC}
cp ${XALT_ETC}/reverseMapD/jsonReverseMapT.json ${XALT_ETC}/reverseMapD/xalt_rmapT.json
```


Configure and build XALT
------------------------

```bash
./configure CC=cc CXX=CC \
            CFLAGS="-I${UUID_INSTALL}/include" LDFLAGS="-L${UUID_INSTALL}/lib" \
            --with-syshostConfig=hardcode:archer2 \
            --with-config=Config/ARCHER2_config.py \
            --with-systemPath=/usr/bin:/bin:${XALT_INSTALL} \
            --with-cmdlineRecord=no \
            --with-transmission=file \
            --with-MySQL=no \
            --with-functionTracking=no \
            --with-siteControlledPrefix=yes \
            --prefix=${XALT_INSTALL}

sed -i "29 i CFLAGS            := -I${UUID_INSTALL}/include -fPIC" ./makefile
sed -i '178 i \                CFLAGS=\"$(CFLAGS)\" \\' ./makefile

make install
make clean
```


Setup XALT environment script
-----------------------------

```bash
echo -e "export XALT_DIR=${XALT_INSTALL}" > ${XALT_INSTALL}/env.sh
echo -e "export XALT_ETC_DIR=\${XALT_DIR}/etc\n" >> ${XALT_INSTALL}/env.sh
echo -e "export XALT_EXECUTABLE_TRACKING=yes\n" >> ${XALT_INSTALL}/env.sh
echo -e "# uncomment this to track GPU usage" >> ${XALT_INSTALL}/env.sh
echo -e "#export XALT_GPU_TRACKING=yes\n" >> ${XALT_INSTALL}/env.sh
echo -e "export PATH=\${XALT_DIR}/bin:\${PATH}" >> ${XALT_INSTALL}/env.sh
echo -e "export LD_PRELOAD=\${XALT_DIR}/lib64/libxalt_init.so" >> ${XALT_INSTALL}/env.sh
echo -e "export COMPILER_PATH=\${XALT_DIR}/bin:\${COMPILER_PATH}\n" >> ${XALT_INSTALL}/env.sh
echo -e "# Uncomment this to use XALT inside Singularity containers" >> ${XALT_INSTALL}/env.sh
echo -e "#export SINGULARITYENV_LD_PRELOAD=\${XALT_DIR}/lib64/libxalt_init.so" >> ${XALT_INSTALL}/env.sh
echo -e "#export SINGULARITY_BINDPATH=\${XALT_DIR}:\${SINGULARITY_BINDPATH}\n" >> ${XALT_INSTALL}/env.sh
echo -e "# Only set this in production not for testing!!!" >> ${XALT_INSTALL}/env.sh
echo -e "#export XALT_SAMPLING=yes" >> ${XALT_INSTALL}/env.sh
```