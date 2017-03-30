Our first MPI program in Fortran with the openmpi library provided by conda-forge.

First of all, install `openmpi` from the `conda-forge` channel with:

    $ conda install openmpi

Remember to add the channel with:

    $ conda config --add channels conda-force   # Will change your ~/.condarc file

Use 

    $ ls ${CONDA_PREFIX}/lib/libmpi*

to list the MPI libraries. 
Do you have the `mpi.mod` Fortran module in lib?

At this point, the `mpicc` and `mpif90` wrapper should be in your path:

    $ which mpif90

and:

    $ mpif90 --show-me

should show that we are using `gfortran`.

The conda channel also provides `mpich`, an alternative implementation of the MPI specifications.
You can use either `opempi` or `mpich` but don't try to mix libraries compiled
with different MPI implementations.

Compile the code with `make`. Note the following options:

    FC=mpif90
    LIBS=-L${CONDA_PREFIX} -lmpi

Run your first MPI code with 1 core with:

    $ mpirun -n 1 ./a.out

The code will ask for the number of points to compute pi. 
Enter `n = 10000`. You should get in output:

    Enter number of points for integration, input n <= 0 to skip.
    1000
    With n: 1000 Pi is approximately: 3.1415927369231227 Error is: 0.0000000833333296

Now run with two cores with the command:

    $ mpirun -n 2 ./a.out

The code will abort with the following error message:

    Something wrong in pi value on rank:1
    This error is expected when nprocs > 1. Please fix the code

Can you explain why?

The next example is in `ex_mpi_io`.
