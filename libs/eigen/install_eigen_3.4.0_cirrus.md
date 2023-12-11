Instructions for installing Eigen 3.4.0 on Cirrus
=================================================

These instructions show how to install Eigen 3.4.0 for use on Cirrus.


Setup initial environment
-------------------------

```
PRFX=/path/to/work # e.g., /mnt/lustre/indy2lfs/sw

EIGEN_LABEL=eigrn
EIGEN_VERSION=3.4.0
EIGEN_NAME=${EIGEN_LABEL}-${EIGEN_VERSION}
EIGEN_ROOT=${PRFX}/${EIGEN_LABEL}
```

Remember to change the setting for `PRFX` to a path appropriate for your project.


Download the Eigen headers
--------------------------

```
mkdir -p ${EIGEN_ROOT}
cd ${EIGEN_ROOT}

wget https://gitlab.com/libeigen/${EIGEN_LABEL}/-/archive/${EIGEN_VERSION}/${EIGEN_NAME}.tar.gz
tar -xzf ${EIGEN_NAME}.tar.gz
rm ${EIGEN_NAME}.tar.gz
```
