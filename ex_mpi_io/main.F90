#include "common.h"

! Write an MPI "hello World!" program using the appropriate MPI calls.
program parallel_io

    use m_core
    use mpi

    implicit none

! Include the header (MPI1)
!#include "mpif.h"

    integer :: ierr, my_rank, nprocs, ii, irnk, unt, tag, comm, fh
    integer,parameter :: master=0
    real(dp) :: cputime,walltime,gflops
    character(len=12) :: msg !, inmsg
    integer :: mpistatus(MPI_STATUS_SIZE)
    integer,parameter :: ntot = 10**5
    integer :: my_n, size_of_irk
    real(dp),allocatable :: my_vector(:),buffer(:),buffer2(:)
    integer,allocatable :: start_rank(:),stop_rank(:)
    integer(MPI_OFFSET_KIND) :: offset

    call MPI_INIT(ierr)

    ! Find out my rank in the global communicator MPI_COMM_WORLD
    comm = MPI_COMM_WORLD
    call MPI_COMM_RANK(comm, my_rank, ierr)

    ! Find out the size of the global communicator comm
    call MPI_COMM_SIZE(comm, nprocs, ierr)

    ! Splits ntot tasks among nprocs processors.
    ! Save distribution in start_rank, stop_rank arrays.
    allocate(start_rank(0:nprocs-1), stop_rank(0:nprocs-1))
    call distrib_tasks(ntot, nprocs, start_rank, stop_rank)
    my_n = stop_rank(my_rank) - start_rank(my_rank) + 1
    allocate(my_vector(my_n))  ! or allocate(my_vector(start_rank(my_rank): stop_rank(my_rank)))

    ! Compute my_vector
    do ii=1,my_n
      my_vector(ii) = start_rank(my_rank) + ii - 1
    end do

    ! ==================
    ! Write data to file
    ! ==================

    ! --------------------------------------
    ! Sequential Fortran-IO (send/recv algo)
    !   * Each proc sends data to master
    !   * master writes
    call cwtime(cputime, walltime, gflops, "start")
    if (my_rank == master) then
        open(file="master_only.data", newunit=unt, form="formatted", status="unknown")
        allocate(buffer(maxval(stop_rank - start_rank + 1)))
        do ii=1,my_n
          write(unt, *)ii, my_vector(ii)
        end do
    end if

    tag = 42
    do irnk=1, nprocs-1

      if (my_rank == irnk) then
        call MPI_SEND(my_vector, my_n, MPI_DOUBLE_PRECISION, master, tag, comm, ierr)

      else if (my_rank == master) then
        size_of_irk = stop_rank(irnk) - start_rank(irnk) + 1
        call MPI_RECV(buffer, size_of_irk, MPI_DOUBLE_PRECISION, irnk, tag, comm, mpistatus, ierr)
        do ii=1,size_of_irk
          write(unt, *) ii + start_rank(irnk) - 1, buffer(ii)
        end do
      end if

    end do

    if (my_rank == master) then
        close(unt)
        deallocate(buffer)
        call cwtime(cputime, walltime, gflops, "stop")
        write(stdout, "(2(a,f8.2))")" send_to_master: cpu-time: ",cputime,", wall-time: ",walltime
    end if

    ! --------------------------------------
    ! Sequential Fortran-IO
    !   * Allocate global array buffer (code could go out of memory here)
    !   * Collect data on master with MPI_REDUCE (more efficient than MPI_ALL_REDUCE)

    call cwtime(cputime, walltime, gflops, "start")
    allocate(buffer(ntot), stat=ierr)
    CHECK_IERR(ierr)

    buffer = zero
    buffer(start_rank(my_rank): start_rank(my_rank)) = my_vector

    allocate(buffer2(ntot))
    !                IN      OUT
    call MPI_REDUCE(buffer, buffer2, ntot, MPI_DOUBLE_PRECISION, MPI_SUM, master, comm, ierr)
    buffer = buffer2
    deallocate(buffer2)

    !call MPI_ALLREDUCE(MPI_IN_PLACE, buffer, ntot, MPI_DOUBLE_PRECISION, MPI_SUM, comm, ierr)

    !call MPI_ALLREDUCE(buffer, xsum, n1, MPI_DOUBLE_PRECISION, MPI_SUM, comm, ierr)

    if (my_rank == master) then
        open(file="master_gather.data", newunit=unt, form="formatted", status="unknown")
        do ii=1,ntot
          write(unt, *)ii, buffer(ii)
        end do
        close(unt)

       call cwtime(cputime, walltime, gflops, "stop")
       write(stdout, "(2(a,f8.2))")" reduce_master: cpu-time: ",cputime,", wall-time: ",walltime
    end if

     ! ==============
     ! MPI-IO section
     ! ==============
     call cwtime(cputime, walltime, gflops, "start")

     ! Open file
     call MPI_FILE_OPEN(comm, "mpifile", MPI_MODE_CREATE + MPI_MODE_WRONLY, MPI_INFO_NULL, fh, ierr)

     ! Blocking collective
     call MPI_FILE_WRITE_AT_ALL(fh, offset, my_vector, my_n, MPI_DOUBLE_PRECISION, mpistatus, ierr)

     call MPI_FILE_CLOSE(fh, ierr)

     if (my_rank == master) then
       call cwtime(cputime, walltime, gflops, "stop")
       write(stdout, "(2(a,f8.2))")" MPI-IO WRITE_AT_ALL: cpu-time: ",cputime,", wall-time: ",walltime
     end if

    deallocate(buffer)
    deallocate(my_vector)
    deallocate(start_rank, stop_rank)

    ! Finalize MPI
    call MPI_FINALIZE(ierr)

end program parallel_io
