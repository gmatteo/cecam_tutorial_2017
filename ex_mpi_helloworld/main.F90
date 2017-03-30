#include "common.h"

program hello_mpi

    use m_core
    use mpi  ! MPI2

    implicit none

! Include the header (MPI1)
!#include "mpif.h"

    integer :: ierr, my_rank, nprocs, irank, tag, comm, namelen, nn, ii, unt
    integer,parameter :: master=0
    character(len=msg_len) :: msg
    character(len=MPI_MAX_PROCESSOR_NAME) processor_name
    integer :: mpistatus(MPI_STATUS_SIZE)
    real(dp) ::  mypi, pi, pi_from_file, h, partial_sum, x, f, a

    real(dp),parameter :: PI25DT = 3.141592653589793238462643_dp

    ! Initialize MPI
    call MPI_INIT(ierr)

    ! Find out my rank in the global communicator MPI_COMM_WORLD
    comm = MPI_COMM_WORLD
    call MPI_COMM_RANK(comm, my_rank, ierr)
    call MPI_GET_PROCESSOR_NAME(processor_name, namelen, ierr)
    ! Find out the size of the global communicator comm
    call MPI_COMM_SIZE(comm, nprocs, ierr)
    write(stdout, "(2(a,i0),a,a)")"Process ", my_rank, " of ", nprocs, " on ", trim(processor_name)

    ! ====================
    ! Send-receive section
    ! ====================
    tag = 42
    if (my_rank == master) then
        ! If the process is the master, send a "Hello,World!" message, in characters, to each of the workers.
        msg = 'Hello World!'
        do irank=1,nprocs-1
          call MPI_SEND(msg, 12, MPI_CHARACTER, irank, tag, comm, ierr)
        end do
    else
        ! If the process is a worker, then receive the "Hello,World!" message and print it out.
        call MPI_RECV(msg, 12, MPI_CHARACTER, master, tag, comm, mpistatus, ierr)
        write(stdout, "(a,i0,2a)") 'Process: ',my_rank, ' received string: ',trim(msg)
    end if

    ! Compute pi
    !nn = 10000
    if (my_rank == master) then
      write(stdout, "(a)")trim(" Enter number of points for integration, input n <= 0 to skip.")
      read(stdin, *) nn
      !call MPI_ABORT(my_comm,my_errorcode,ierr)
    end if

    call MPI_BCAST(nn, 1, MPI_INTEGER, master, comm,ierr)
    ! Consistency check.
    ! Q: Why are we checking nn here and not immediately after `read(stdout, *) nn`?
    if (nn <= 0) goto 10
    ! OK GOTO is BAD but there are cases in which its use is permitted
    ! This is an MPI application and we should call MPI_FINALIZE, don't use stop

    ! Calculate the interval size
    h = one / nn
    partial_sum  = zero
    do ii = my_rank + 1, nn, nprocs
       x = h * (dble(ii) - 0.5d0)
       partial_sum = partial_sum + four / (one + x*x)
    end do
    mypi = h * partial_sum

    ! Collect all the partial sums on master
    call MPI_REDUCE(mypi, pi, 1, MPI_DOUBLE_PRECISION, MPI_SUM, master, comm, ierr)

    ! Master node prints the answer and write result to file
    if (my_rank == master) then
       write(stdout, "(a,i0,2(a,f18.16))")"With n: ",nn," Pi is approximately: ", pi," Error is: ", abs(pi - PI25DT)
       open(newunit=unt, file="pi.dat", form="formatted", action="write", status="unknown", iomsg=msg, iostat=ierr)
       CHECK_IERR_MSG(ierr, msg)
       write(unt, *) pi
       close(unt)
    end if

    ! All processors re-read pi value from file and check it everything is ok
    ! This is sequential IO: ALL procs are reading.
    ! Why are we using MPI_BARRIER here?
    call MPI_BARRIER(comm, ierr)

    open(newunit=unt, file="pi.dat", form="formatted", action="read", status="unknown", iomsg=msg, iostat=ierr)
    CHECK_IERR_MSG(ierr, msg)
    read(unt, *) pi_from_file
    close(unt)

    ! MPI codes should call MPI_ABORT when a critical event occurs.
    if (abs(pi - pi_from_file) > 1e-6) then
      write(stderr, "(a, i0)")"Something wrong in pi value on rank:", my_rank
      write(stderr, "(a)")"This error is expected when nprocs > 1. Please fix the code"
      write(stderr, "(a)")"Calling MPI_ABORT with MPI_ERR_UNKNOWN"
      ! Terminates MPI execution environment.
      call MPI_ABORT(comm, MPI_ERR_UNKNOWN, ierr)
      !call exit(1)
    end if

    ! Finalize MPI
10  call MPI_FINALIZE(ierr)

end program hello_mpi
