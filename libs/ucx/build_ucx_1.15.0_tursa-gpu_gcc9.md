Instructions for building UCX 1.15.0 on Tursa (GPU nodes)
=========================================================

These instructions are for building UCX 1.15.0 on [Tursa](https://epcced.github.io/dirac-docs/tursa-user-guide/) using gcc 9.3.0
and CUDA 12.3.

Setup initial environment
-------------------------

```bash
module load gcc

```

Build and install UCX for GPU (CUDA 12.3)
-----------------------------------------

Remember to change the `--prefix` option to point to a location where you want
to install UCX and where you have write permissions.

```bash
./configure \
    --build=x86_64-redhat-linux-gnu --host=x86_64-redhat-linux-gnu --disable-dependency-tracking \
    --prefix=/mnt/lustre/tursafs1/apps/basestack/cuda-12.3/ucx/1.15.0-cuda12.3 \
    --enable-devel-headers --enable-examples --enable-optimizations \
    --with-gdrcopy=/mnt/lustre/tursafs1/apps/gdrcopy/2.5.1/bin/ \
    —-with-verbs --disable-logging --disable-debug --disable-assertions --enable-mt --enable-cma \
    --with-knem=/opt/knem-1.1.4.90mlnx2/ --with-rdmacm --without-rocm --without-ugni --without-java \
    --enable-compiler-opt=3 --with-cuda=/mnt/lustre/tursafs1/apps/cuda/12.3 --without-cm \
    --with-rc --with-ud --with-dc --with-mlx5-dv --with-dm

make -j 8 clean
make -j 8
make -j 8 install
```



