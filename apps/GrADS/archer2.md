# GrADS build instructions

Dependencies:
 - GNU compilers. 

## Build GrADS
Execute `grads.sh`. The software will be installed in `$HOME/grads`. Please note that the aforementioned script does not install all dependencies. Should you require any other dependencies, please install them by following these instructions:
http://cola.gmu.edu/grads/gadoc/supplibs2.html

Once the installation finishes, you can remove `$HOME/tarfiles` directory.

Update the following env variable:
```
export LD_LIBRARY_PATH=$HOME/grads/supplibs/lib:$LD_LIBRARY_PATH
```

Then, you need to create the [User-Defined Plug-in Table (UDPT)](http://cola.gmu.edu/grads/gadoc/udpt.html).
