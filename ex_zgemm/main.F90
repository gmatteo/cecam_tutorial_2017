#include "common.h"

program main

    use m_core

    implicit none

    integer,parameter :: start=200, stop=1400, step=200

    ! Profil matrix-matrix multiplication
    call profile_matmul(start, stop, step, "slow.dat")
    call profile_matmul(start, stop, step, "fast.dat")

contains

subroutine profile_matmul(start, stop, step, what)

    integer,intent(in) :: start, stop, step
    character(len=*),intent(in) :: what
    complex(dp),allocatable :: amat(:,:), bmat(:,:), cmat(:,:)

    integer :: ii, jj, unt, n, ierr
    real(dp) :: cputime, walltime, gflops
    character(len=msg_len) :: msg
    real(dp),allocatable :: a(:,:)

    ! open file and **test** exit status!
    open(unit=unt, file=what, form="formatted", status="unknown", iomsg=msg, iostat=ierr)
    CHECK_IERR(ierr)
    write(unt,*)"# n, cputime, walltime, gflops"

    do n=start,stop,step

        allocate(amat(n,n), bmat(n,n), cmat(n,n))
        ! Init A and B with fake values to avoid numerical exceptions (will slowdown the code!)
        amat = cone; bmat = cone
        !cmat = one

        call cwtime(cputime, walltime, gflops, "start")

        ! Matrix-matrix multiplication:
        select case (what)
        case ("slow.dat")
            ! Inefficient loop with poor cache use
            cmat = MATMUL(amat, bmat)

        case ("fast.dat")
            ! BLAS version. More complicated API but it will repay!
            call ZGEMM("N","N", n, n, n, cone, amat, n, bmat, n, czero, cmat, n)

        case default
           MSG_ERROR("Wrong what:"//trim(what))
        end select

        call cwtime(cputime, walltime, gflops, "stop")
        write(stdout, "(2a,i0,2(a,f8.2))")trim(what)," n: ", n," cpu-time: ",cputime,", wall-time: ",walltime
        write(unt,*)n, cputime, walltime, gflops

        deallocate(amat, bmat, cmat)
    end do

    close(unt)

end subroutine profile_matmul

end program main
