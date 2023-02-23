Test files
==========

This folder contains the required input file, data file, and slurm scripts to test LAMMPS on Cirrus (both CPU and GPU versions).
The system is an ethanol mixture, build using LAMMPS `create_box` command, allowing for easily scalable simulations with minimal changes to the input file.

To scale the simulation to, for example, benchmark a system, change the variables `X_LENGTH`, `Y_LENGTH`, and `Z_LENGTH`.

Running the tests
-----------------

To test a CPU-only version of LAMMPS, run:

```
srun lmp -in in.ethanol_optimized
```

To test a GPU-accelerated version of LAMMPS, run:

```
srun lmp -sf gpu -pk gpu <number> -in in.ethanol_optimized
```
