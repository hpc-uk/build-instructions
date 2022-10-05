Instructions for running Horovod on Cirrus (GPU)
================================================

These instructions are for running Horovod on the Cirrus GPU nodes (Cascade Lake, NVIDIA Tesla V100-SXM2-16GB).

Horovod 0.25.0 is made available by loading the `horovod/0.25.0-gpu` module; this starts a Miniconda3 environment
containing Horovod 0.25.0 and mpi4py 3.1.3 (built against Open MPI 4.1.4 and CUDA 11.6). Also included are
TensorFlow 2.9.1 and PyTorch 1.12.1.

Horovod is a key component as it allows the TensorFlow/PyTorch workload to be distributed over multiple GPU nodes,
see [https://horovod.readthedocs.io/en/stable/mpi_include.html](https://horovod.readthedocs.io/en/stable/mpi_include.html).

For clarity, two module aliases are also provided, `tensorflow/2.9.1-gpu` and `pytorch/1.12.1-gpu`. Those two modules
are aliases for the `horovod/0.25.0-gpu` module.

The submission scripts linked below show how to run TensorFlow/PyTorch over multiple GPU nodes for two
popular ML benchmarks, MNIST and ImageNet.


* [MNIST Cirrus Run Instructions (GPU)](run_mnist_cirrus_gpu.md)
* [ImageNet Cirrus Run Instructions (GPU)](run_imagenet_cirrus_gpu.md)


Please note, if you are running the benchmark on a single GPU node you can check the performance by
logging in to the node (e.g., `ssh r2i7n7`) and running `watch -n0.1 nvidia-smi`.

The `nvidia-smi` output shows how well the different GPUs are being utilized. You can also follow
the memory usage in order to determine the optimum value for the batch size.
