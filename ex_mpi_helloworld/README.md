Our first MPI program in Fortran with MPI libraries provided by conda.

Install `openmpi` from the `conda-forge` channel with:

    $ conda install openmpi

Remember to add the channel with:

    $ conda config --add channels conda-force   # Will change your ~/.condarc file

Use 

    $ ls ${CONDA_PREFIX}/lib/libmpi*

to list the MPI libraries. Do you have the `mpi.mod` Fortran module?

At this point, the `mpicc` and `mpif90` wrapper should be in your path:

    $ which mpif90

and:

    $ mpif90 --show-me

shows that we are wrapping gfortran

The conda channel also provides `mpich`, an alternative implementation of the MPI specifications.
You can use either `opempi` or `mpich` but don't try to mix libraries that have been compiled
with different MPI implementations.

Compile the code with `make`. Note the following options:

    FC=mpif90
    FCFLAGS=-g -O2 -I../ -J../ -L.. -lcore -ffree-form --free-line-length-none -L${CONDA_PREFIX} -lmpi

Run your first MPI code with 1 core with:

    $ mpirun -n 1 ./a.out

The code will ask you to enter the number of points to compute pi. 
Enter `n = 10000`. You should get something like:

    Enter number of points for integration, input n <= 0 to skip.
    1000
    With n: 1000 Pi is approximately: 3.1415927369231227 Error is: 0.0000000833333296

Now run with two cores with:

    $ mpirun -n 2 ./a.out

The code will abort with the following error message:

    Something wrong in pi value on rank:1
    This error is expected when nprocs > 1. Please fix the code

Can you explain why?
