This example shows the importance of accessing contiguous elements 
in the innermost loops and the effect of the optimization level `-On`.
It also allows us to test whether your conda environment is properly configured.

Compile the code with:

    $ make

Note that, by default, `Makefile` compiles `main.F90` with `-O0`.

Use:

    $ ldd ./a.out

on Linux or
    
    $ otool -L ./a.out

on MacOSx to list the dynamic libraries used by our executable and the corresponding paths.
In principle, we should install our binaries in the conda environment but since we are 
working in developmental mode we have to set our `LD_LIBRARY_PATH` with

    $ export LD_LIBRARY_PATH=$CONDA_PREFIX/lib

on Unix or with:

    $ export DYLD_LIBRARY_PATH=$CONDA_PREFIX/lib

on MacOsx.
Note that this usage of `LD_LIBRARY_PATH` is highly non-standard and should be
avoided when you are using a conda environment for production.

At this point, we can run the code and plot the results with the `plot.py` script
(you will need `matplotlib` and `numpy`).

Install the python packages with: 

    $ conda install numpy matplotlib 

Why do we have such a large difference in the performance of the loops?

Change the `Makefile` to compile the code with `-O2` and rerun the program. 
You should see that now `slow` and `fast` have similar `cpu_time`. Why?

Note that in this oversimplified example, we have two simple do loops that can be 
exchanged without modifying the final results.
In other more complicated cases, the compiler won't be able to "fix" your code so 
try to design your data-structures so that the most CPU-critical sections always
access contiguous portions.

The next example is in `ex_zgemm`
