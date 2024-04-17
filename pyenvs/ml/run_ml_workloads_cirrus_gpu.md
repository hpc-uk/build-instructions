Instructions for running machine learning (ML) workload on Cirrus (GPU)
=======================================================================

These instructions are for running ML workloads on the Cirrus GPU nodes (Cascade Lake, NVIDIA Tesla V100-SXM2-16GB).

Horovod 0.28.1 is made available by loading ML modules such as `pytorch/1.13.1-gpu` or `tensorflow/2.13.0-gpu`.
Loading either of those modules starts a Miniconda3 environment containing Horovod 0.28.1 and mpi4py 3.1.5
(built against Open MPI 4.1.6 and CUDA 11.6).

Horovod is a key component as it allows the TensorFlow/PyTorch workload to be distributed over multiple GPU nodes,
see [https://horovod.readthedocs.io/en/stable/mpi_include.html](https://horovod.readthedocs.io/en/stable/mpi_include.html).

However, with PyTorch, multi-node ML workloads can also be run using the NVIDIA Collective Communications Library (NCCL)
via the `torch.distributed` module.

The submission scripts linked below show how to run TensorFlow/PyTorch over multiple GPU nodes for two
popular ML benchmarks, MNIST and ImageNet.


* [MNIST Cirrus Run Instructions (GPU)](run_mnist_cirrus_gpu.md)
* [ImageNet Cirrus Run Instructions (GPU)](run_imagenet_cirrus_gpu.md)


Please note, if you are running the benchmark on a single GPU node you can check the performance by
logging in to the node (e.g., `ssh r2i7n7`) and running `watch -n0.1 nvidia-smi`.

The `nvidia-smi` output shows how well the different GPUs are being utilized. You can also follow
the memory usage in order to determine the optimum value for the batch size.
