This example shows three different approaches to perform IO in parallel codes:

    - Sequential Fortran-IO in which each MPI rank sends data to master
      and the master note writes a binary Fortran file

    - Sequential Fortran-IO with a global buffer and data gathered 
      on the master node with `MPI_REDUCE`

    - Parallel IO with collective operations and explicit offset.

Optional Exercise
-----------------

Write a matrix A of shape (M, N) to file with Fortran write
then re-read it with MPI-IO in sequential and test for equality.
Remember that Fortran files are record-based: each record is enclose between 
two markers (usually 4 bytes) with the size of the record.
Once the sequential version works, try to extend the code with MPI. 
Change the code so that the A matrix is MPI-distributed along the second dimension 
and each MPI process reads its portion from file.
What happens if you decide to distribute the rows among the processes?
