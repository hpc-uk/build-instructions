Build Instructions
------------------

(The current installation of Tensorflow on Archer is commit
88633a8ebbd0fada4ae73f11410939a3f0d818d8, which is between 1.2.1 and
1.3.0-rc0.  These instructions do not apply to that installation.)

No version of Tensorflow from 1.4.1 to 1.13.1 builds on Archer.
Versions later than 1.13.1 will also not build on Archer because the
glibc version is too old.

These instructions may be useful so that others can avoid trying to
install TensorFlow.  They include some information on building Bazel.

See the [build script]( build_instructions.bash).

### Help improve these instructions

If you make changes that would update these instructions, please fork
this repository on GitHub, update the instructions and send a pull
request to incorporate them into this repository.

Notes
-----
