# OpenMPI 5.0.0 on Cirrus

Compilation is best done on the `/home` filesystem.
On `\work` the timestamps can become inconsistent because Lustre is a network filesystem. OpenMPI requires both `ucx` and `libevent` to be installed. However the versions already present on Cirrus will work and do not need to be reinstalled.

1. Set up 

Modify the `setup.sh` file in order to setup the proper paths where you want to install openmpi and its dependencies.

1. Install hwloc

```bash 
cd hwloc && bash ./install.sh && cd ..
```

2. Install pmix

```bash 
cd pmix && bash ./install.sh && cd ..
```

3. Install openmpi

```bash 
cd openmpi && bash ./install.sh && cd ..
```