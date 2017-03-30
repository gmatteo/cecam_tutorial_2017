#include "common.h"

program main

    use m_core

    implicit none

    integer :: unt, ii, nn
    real(dp) :: T, xx
    character(len=1024) :: string
    real(dp),allocatable :: ft(:)

    open(file="func.dat", newunit=unt, form="formatted", action="read", status="old")
    read(unt, *)nn, T
    write(stdout, "(a, i0)")"npoints: ",nn, "T", T

    allocate(ft(nn))
    do ii=1,nn
      read(unt,*)xx, ft(ii)
    end do
    close(unt)

    deallocate(ft)

contains

end program main
