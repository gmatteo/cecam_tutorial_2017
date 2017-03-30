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

Remember that Fortran files are record-based: each record is enclosed between 
two markers (usually 4-byte integers) with the size of the record.
Once the sequential version works, change the implementation to MPI-distribute the A matrix 
along the second dimension.
Then use collective MPI-IO calls so that each MPI process reads its own portion from file.
