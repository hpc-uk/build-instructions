Instructions for installing ERT 1.1.0 on ARCHER2
================================================

These instructions are for installing the Empirical Roofline Tool 1.1.0 on the ARCHER2 full system (HPE Cray EX, AMD Zen2 7742).


Clone the Berkeley Lab CS Roofline Toolkit
------------------------------------------

```bash
git clone https://bitbucket.org/berkeleylab/cs-roofline-toolkit.git
```


Move to the ERT folder
----------------------

```bash
cd ./cs-roofline-toolkit/Empirical_Roofline_Tool-1.1.0
```


Add ARCHER2 configuration file
------------------------------

Create a file at `./Config/config.archer2.epcc.ed.ac.uk` and add the content
shown below.

```bash
# HPE Cray EX nodes - 2 x AMD EPYC 7742 'Rome' 64-core processors

ERT_RESULTS Results.archer2.epcc.ed.ac.uk

# theoretical maximum bandwidth and computation rate
# ERT_SPEC_GBYTES_L1 ? (GBytes/sec)
# ERT_SPEC_GBYTES_L2 ? (GBytes/sec)
# ERT_SPEC_GBYTES_L3 ? (GBytes/sec)
# ERT_SPEC_GBYTES_DRAM ? (GBytes/sec)
# ERT_SPEC_GFLOPS ? (GFLOPs/sec)

ERT_DRIVER  driver1
ERT_KERNEL  kernel1

ERT_MPI         True
ERT_MPI_CFLAGS
ERT_MPI_LDFLAGS

ERT_OPENMP         True
ERT_OPENMP_CFLAGS  -fopenmp
ERT_OPENMP_LDFLAGS -fopenmp

ERT_GPU          False
ERT_GPU_CFLAGS
ERT_GPU_LDFLAGS

ERT_FLOPS   1,2,4,8,16,32,64
ERT_ALIGN   128

ERT_CC      CC
ERT_CFLAGS  -O3 -fstrict-aliasing -march=znver2

ERT_LD      CC
ERT_LDFLAGS
ERT_LDLIBS

ERT_PRECISION FP64

ERT_RUN     export OMP_NUM_THREADS=ERT_OPENMP_THREADS; export OMP_PLACES=cores; export OMP_PROC_BIND=close; srun -n ERT_MPI_PROCS --cpu-bind=cores --cpus-per-task `expr 128 / ERT_MPI_PROCS` ./ERT_CODE

ERT_PROCS_THREADS  128
ERT_MPI_PROCS      8,16,32,64,128
ERT_OPENMP_THREADS 1,2,4,8,16

ERT_NUM_EXPERIMENTS 10

ERT_MEMORY_MAX 1073741824

ERT_WORKING_SET_MIN 1

ERT_TRIALS_MIN 1

ERT_GNUPLOT gnuplot
```

Explanations for all the configuration fields can be found in the ERT User's Manual, which should be in the cloned
repo folder at `./cs-roofline-toolkit/Docs/ERT/Users_Manual/ERT_Users_Manual.pdf`.

The `config.archer2.epcc.ed.ac.uk` file gives a series of FLOP counts per computational element, where an element
is an 8 byte double precision floating point number, see the `ERT_FLOPS` field. For each FLOP count, a set of tests
involving different combinations of MPI tasks and OpenMP threads is run. For example, the `ERT_MPI_PROCS` field
gives the various MPI task counts, and for each of those, the number of OpenMP threads is chosen such that the
number of tasks multiplied by the number of threads is equal to 128 (`ERT_PROCS_THREADS`).

All of these tests are repeated 10 times as indicated by `ERT_NUM_EXPERIMENTS`. The `ERT_MEMORY_MAX` field, set
to a value of 1 MiB, is the maximum number of bytes allocated for the entire run; these are divided up across
the MPI tasks and OpenMP threads.

Note that the setting for the `ERT_CFLAGS` field implies that the ERT kernels will be built using the GNU compilers;
this is confirmed by the submission script that is shown here, [./run_ert_1.1.0_archer2.md](./run_ert_1.1.0_archer2.md).
