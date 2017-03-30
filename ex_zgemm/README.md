This example shows the importance of optimized external libraries for linear algebra operations.
We compare the performance of the `MATMUL` Fortran intrinsic with the `ZGEMM` version
provide by openblas.

First of all, install `openblas` with:

    $ conda install openblas

Remember to:

    $ export OMP_NUM_THREADS=1

before running the code because `openblas` uses OpenMP threads and the default value is 
the number of (logical) cores available on your machine.

Open the Makefile and look at the `$FCLAGS` variable. Could you explain what's happening here?

Compile the code with:

    $ make

Use:

    ldd ./a.out

on Linux or
    
    otool -L ./a.out

on MacOsX to list the dynamic libraries.

Run the code and use the `plot.py` script to visualize the results.

The next example is in `ex_fortran`

Linking against MKL
-------------------

Install the MKL library with:

    $ conda install mkl

Use the [mkl link line advisor](https://software.intel.com/en-us/articles/intel-mkl-link-line-advisor)
to get the options to pass to the linker/compiler on your architectures.
Change `$FCFLAGS` accordingly and recompile.
Run the benchmark and compare mkl with openblas

