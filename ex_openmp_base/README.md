This is our "hello world" example for OpenMP.
Compile the code as usual with:

    $ make

note the use of `-fopenmp` in `$FCFLAGS`.
This option is needed to activate the compilation of the OpenMP sections in `main.F90`
Use the command line argument `-j NUM` to set the number of threads e.g.:

    $ ./a.out -j 2

There are minor bugs in the code that must be fixed.

Once these problems are solved, uncomment the call to `calc_pi`
This routine computes an approximation to pi by performing a numerical 
integration with `n` points. 
The number of points can be specified on the command line with: 

    $ ./a.out -n 1000

The integration is parallelized in two different ways.
The second method is wrong and highly inefficient. Can you explain why?

Then uncomment the call to the `omp_matmul` subroutine. 
This example shows how to use the `WORKSHARE` construct, how to use nested parallelism
and write highly inefficient OMP code.

Optional Exercise
-----------------

Use the [intel mkl link line advisor](https://software.intel.com/en-us/articles/intel-mkl-link-line-advisor)
to link the code agains the threaded version of ZGEMM provided by MKL.
