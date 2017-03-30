#include "common.h"

program main

    use m_core

    implicit none

    integer,parameter :: start=10**2, stop=10**4, step=500

    call profile(start, stop, step, "slow.dat")
    call profile(start, stop, step, "fast.dat")

contains

subroutine profile(start, stop, step, what)

    integer,intent(in) :: start, stop, step
    character(len=*),intent(in) :: what

    integer :: ii,jj,unt,n,ierr
    real(dp) :: res
    real(dp) :: cputime,walltime,gflops
    character(len=msg_len) :: msg
    real(dp),allocatable :: a(:,:)

    !allocate(a(stop, stop))
    open(unit=unt, file=what, form="formatted", status="unknown", iomsg=msg, iostat=ierr)
    CHECK_IERR(ierr)
    write(unt,*)"# n, cputime, walltime, gflops"

    do n=start,stop,step
        allocate(a(n,n))
        call random_number(a)
        call cwtime(cputime, walltime, gflops, "start")

        ! Inefficient loop with poor cache use
        select case (what)
        case ("slow.dat")

            res = zero
            do ii=1,n
              do jj=1,n
                 res = res + a(ii,jj)
              end do
            end do

        case ("fast.dat")

            ! More efficient loop with cache reuse
            res = zero
            do jj=1,n
              do ii=1,n
                 res = res + a(ii,jj)
              end do
            end do

        case default
           MSG_ERROR("Wrong what:"//trim(what))
        end select

        ! Write benchmark results
        call cwtime(cputime, walltime, gflops, "stop")
        write(stdout, "(2a,i0,2(a,f8.2))")trim(what)," n: ", n," cpu-time: ",cputime,", wall-time: ",walltime
        write(unt, *) n, cputime, walltime, gflops
        deallocate(a)
    end do

    !deallocate(a)
    close(unt)

end subroutine profile

end program main
