ICON-AES
========

This folder contains files and documentation for building ICON-AES.

History
-------

Date | Person | Version | Notes
---- | -------|---------|------
2019-01-29 | Mark Filipiak | f16283966 | With Gnu compiler, netCDF, dynamic linking.

Build Instructions
------------------

1. git clone the ICON-AES repository and checkout a new branch `archer`.
1. Review `config/mh-linux` and the Archer-specific `mh-linux` provided here, modify the Archer `mh-linux` and copy that to `config/mh-linux'.
1. Copy `modules.bash`, `compile.bash`, `run.pbs` to the ICON-AES directory.
1. Run `compile.bash` and check all the `.out` files.
1. Edit your `.run` file, or generate one, edit `run.pbs` to use this `.run` file and set the PBS parameters.
1. Run using `qsub run.pbs`

If you make changes that would update these instructions, please fork
this repository on GitHub, update the instructions and send a pull
request to incorporate them into this repository.  Or email the Archer
helpdesk support@archer.ac.uk with the changes.

Notes
-----


