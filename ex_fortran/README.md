In this example, we discuss Fortran array descriptors and how to pass arguments by `assumed shape`.

We also show a typical case in which passing array descriptors to F77 legacy code
leads to performance degradation due to copy-in copy-out.
For a more detailed discussion on this topic, please read
[Using Arrays Efficiently](http://astroa.physics.metu.edu.tr/MANUALS/intel_ifc/mergedProjects/optaps_for/fortran/optaps_prg_arrs_f.htm)

The code in `zgemm_with_real_arrays` shows how to use the `iso_c_binding` module to associate 
a real pointer to a complex array and pass it to `ZGEMM` when we have an explicit interface.
This trick allows us to by-pass the type-checking performed by the Fortran compiler and 
avoid extra-copies in sections of code in which performance is critical.

The next example is in `ex_openmp_base`
