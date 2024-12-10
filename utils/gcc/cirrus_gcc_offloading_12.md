# Building GCC 12.2 with GPU offloading on Cirrus

## Installing `nvptx-tools`

GCC will be built for the `nvptx-none` target. We need to install `nvptx-tools` to replace binutils for this target.

### Set up the environment to build `nvptx-tools`

Run the following commands to prepare the environment. Set `BUILD_DIR` and `INSTALL_DIR` to what is appropriate for you; both should both be located within the Cirrus `work` file system.

```bash
module load gcc/8.2.0
module load nvidia/nvhpc-byo-compiler/22.11
module load zlib/1.3.1
export CUDA_DIR=/mnt/lustre/indy2lfs/sw/nvidia/hpcsdk-2211/Linux_x86_64/22.11/cuda
export BUILD_DIR=/work/y07/y07/cse/gcc-offload-build
export INSTALL_DIR=/mnt/lustre/indy2lfs/sw/gcc/12.2.0-gpu-offload
```

### Build and install `nvptx-tools`

Move to the build directory, then clone the `nvptx-tools` source code from GitHub. Move into the source directory, configure, then build it.

```bash
cd $BUILD_DIR
git clone https://github.com/MentorEmbedded/nvptx-tools
./configure --with-cuda-driver-include=$CUDA_DIR/include --with-cuda-driver-lib=$CUDA_DIR/lib64 --prefix=$INSTALL_DIR
make -j 4
make install
```

## Installing GCC

We need to download the GCC source, prepare download `nvptx-newlib` and its other dependencies, then create build directories ready for the GPU and host builds.

### Download and prepare the GCC source code and dependencies

Move back to the parent build directory. We'll firstly clone `nvptx-newlib` from GitHub.

```bash
cd $BUILD_DIR
git clone https://github.com/MentorEmbedded/nvptx-newlib
```

Now we'll download GCC, download the prerequisites and symlink `nvptx-newlib` into it.

```bash
curl -JLO https://mirrorservice.org/sites/sourceware.org/pub/gcc/releases/gcc-12.2.0/gcc-12.2.0.tar.gz
tar -xvf gcc-12.2.0.tar.gz
cd gcc-12.2.0
./contrib/download_prerequisites
ln -s ../nvptx-newlib/newlib .
```

Back up a directory and create the build directories for the GPU and host.

```bash
cd ..
mkdir gcc-12.2.0-build-gpu
mkdir gcc-12.2.0-build-host
```

### Build and install the GPU compiler

The build itself may take some time so we will run it as a job on the GPU nodes. This is also necessary to make the GPU drivers available. The job script must load the same modules and set the same environment variables that used above. Create this script in `$BUILD_DIR`.

```bash
#!/bin/bash

# Slurm job options (name, compute nodes, job time)
#SBATCH --job-name=gcc-gpu-build
#SBATCH --time=6:00:0

#SBATCH --account=z04
#SBATCH --partition=gpu
#SBATCH --qos=gpu
#SBATCH --gres=gpu:1

# Change to the GPU build directory in the submission directory
cd $SLURM_SUBMIT_DIR/gcc-12.2.0-build-gpu

# Enforce threading to 1 in case underlying libraries are threaded
export OMP_NUM_THREADS=1

# Load modules and set env vars.
module load gcc/8.2.0
module load nvidia/nvhpc-byo-compiler/22.11
export CUDA_DIR=/mnt/lustre/indy2lfs/sw/nvidia/hpcsdk-2211/Linux_x86_64/22.11/cuda
export INSTALL_DIR=/mnt/lustre/indy2lfs/sw/gcc/12.2.0-gpu-offload

../gcc-12.2.0/configure --prefix=$INSTALL_DIR --with-system-zlib --enable-languages=c,c++,fortran,lto --target=nvptx-none --enable-as-accelerator-for=x86_64-pc-linux-gnu --with-build-time-tools=$INSTALL_DIR/nvptx-none/bin --disable-sjlj-exceptions --enable-newlib-io-long-long

srun --cpu-bind=cores make -j 8
srun --cpu-bind=cores make -j 1 install
```

Submit the job script. When it's ended, check the Slurm output to make sure there were no errors during the build.

### Build and install the host compiler

Firstly, go into the GCC source directory and delete the symlink to `newlib`.

```bash
cd $BUILD_DIR/gcc-12.2.0
rm newlib
```

`cd` back to `$BUILD_DIR`. Create the following new job script so we can build the host compiler in a job script on the GPU compute nodes (the build still needs access to the NVIDIA drivers which are only on the GPU nodes).

```bash
#!/bin/bash

# Slurm job options (name, compute nodes, job time)
#SBATCH --job-name=gcc-host-build
#SBATCH --time=6:00:0

#SBATCH --account=z04
#SBATCH --partition=gpu
#SBATCH --qos=gpu
#SBATCH --gres=gpu:1

# Change to the host build directory in the submission directory
cd $SLURM_SUBMIT_DIR/gcc-12.2.0-build-host

# Load modules and set env vars.
module load gcc/8.2.0
module load nvidia/nvhpc-byo-compiler/22.11
export CUDA_DIR=/mnt/lustre/indy2lfs/sw/nvidia/hpcsdk-2211/Linux_x86_64/22.11/cuda
export INSTALL_DIR=/mnt/lustre/indy2lfs/sw/gcc/12.2.0-gpu-offload

../gcc-12.2.0/configure --prefix=$INSTALL_DIR --build=x86_64-pc-linux-gnu --host=x86_64-pc-linux-gnu --target=x86_64-pc-linux-gnu --enable-offload-targets=nvptx-none=$INSTALL_DIR/nvptx-none --with-cuda-driver-include=$CUDA_DIR/include --with-cuda-driver-lib=$CUDA_DIR/lib64 --disable-multilib --with-system-zlib --enable-languages=c,c++,fortran,lto

srun --cpu-bind=cores make -j 8
srun --cpu-bind=cores make -j 1 install
```

## How to build for OpenMP offloading

Compile with the `-fopenmp -ftarget-offload=nvptx-none` flags.
