This is our "hello world" example for OpenMP.
Compile the code as usual with:

    make

note the use of `-fopenmp` in `$FCFLAGS`.
This option is needed to activate the compilation of the OpenMP sections in `main.F90`
Use the command line argument `-j NUM` to set the number of threads e.g.:

    ./a.out -j 2

There are minor bugs in the code that must be fixed.

Once these problems are solved, uncomment the call to `calc_pi`
This routine computes an approximation to pi by performing a numerical 
integration with `n` points that can be specified with: 

    ./a.out -n 1000

The integration is parallelized in tow different ways.
The second method is wrong and highly inefficient. Why?

Then uncomment the call to `omp_matmul`. This example shows how 
to use the `WORKSHARE` construct, how to write a highly inefficient OMP code 
to perform several matrix-matrix multiplications and how to use nested parallelism

Optional Exercise
-----------------

Replace your version with ZGEMM from MKL (link against the threaded version)
and use the [intel mkl link line advisor](https://software.intel.com/en-us/articles/intel-mkl-link-line-advisor)
