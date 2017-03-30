This example shows how to use the netcdf API to write a simple file in Fortran. 
We then re-read the data in a python script. 

First of all install the netcdf software stack with

    conda install netcdf-fortran

This command will install the C-layer (hdf5, netcdf-C) and the Fortran bindings.

Use:

    nc-config  --all

to get the configuration flags used to build the library.
Look, in particular, at the value of ``--libs``.
Note that the MPI-IO interface is not activated in the `hdf5` library provided by conda
so we cannot perform parallel IO with this configuration.

Compile the code and execute it with:

    make && ./a.out

Use:

    ncdump -h data.nc

to show header information only and 

    ncdump data.nc | less

to get the full output.

Reading ncdata from python
--------------------------

Install the python bindings with:

    $ conda install netcdf4

and look at the code in `ncread.py` to understand how to read netcd file in python
See also the official `documentation <http://unidata.github.io/netcdf4-python>`_

Optional exercise
------------------

Write a Fortran routine to read the netcdf file and 
use the `start`, `count`, `stride` arguments to select a slice of the full array.
