#include "common.h"

program main

    use m_core

    implicit none

    integer:: nn, ii
    real(dp) :: res
    character(len=msg_len) :: arg
    real(dp),allocatable :: vec(:)

    ! Command line interface to set the number of OpenMP threads.
    nn = 5000000
    if (command_argument_count() /= 0) then
        do ii=1,command_argument_count()
            call get_command_argument(ii, arg)
            if (arg == "-n" .or. arg == "--size") then
              call get_command_argument(ii+1, arg)
              read(arg,*)nn
            else if (arg == "-h" .or. arg == "--help") then
              write(stdout,*)"-n, --problem-size         Set n dimension"
              call exit(0)
            end if
        end do
    end if

    ! Array descriptors are handy and you can decrease the number of arguments
    ! that must be passed explicitly to your routines e.g.
    allocate(vec(nn))
    vec = one

    res = assumed_shape_sum2(vec)

    ! Here we are passing an array descriptor with a non-contiguous view of the data.
    ! The caller can selects a slice of the data, we thus have an easy-to-use API and
    ! it's possible to re-use the logic implemented in assume_shape_sum but ...
    res = assumed_shape_sum2(vec(1:nn:2))
    deallocate(vec)

    ! But there's a price to pay if you have to interface your F90+ code with legacy routines.
    call copyin_copyout(nn)

contains

real(dp) function assumed_shape_sum2(arrd) result(res)

    real(dp),intent(in) :: arrd(:)   ! Array descriptor

    ! F2008 standard (not yet implemented by gcc)
    !write(stdout,*)"is_contiguous(arrd):", is_contiguous(arrd)
    res = sum(arrd ** 2)

end function assumed_shape_sum2

! ====================================================
! BE VERY CAREFUL WHEN ARRAY DESCRIPTORS ARE PASSED
! TO CODE THAT EXPECTS CONTIGOUS MEMORY
! ====================================================

! Since I don't like to pass several arguments, I introduce a small wrapper around ddot
! in which the dummy args `zx` and `zy` are **ARRAY DESCRIPTORS**.
function my_ddot(zx, zy)

  real(dp) :: my_ddot
  real(dp),intent(in) :: zx(:), zy(:)   ! Assumed shape
  integer :: n
  real(dp),external :: ddot

  n = size(zx)  ! Get dimension from array descriptor

  ! Array descriptors passed to F77.
  my_ddot = ddot(n, zx, 1, zy, 1)

end function my_ddot

subroutine zgemm_with_real_arrays()

    use iso_c_binding

    ! Explitic interface for ZGEMM.
    interface zgemm
      subroutine zgemm ( transa, transb, m, n, k, alpha, a, lda, b, ldb, beta, c, ldc )
        use m_core
        character(len=1),intent(in) :: transa, transb
        integer,intent(in) :: m, n, k, lda, ldb, ldc
        complex(dp),intent(in) :: alpha, beta
        complex(dp),intent(in) :: a( lda, * ), b( ldb, * )
        complex(dp),intent(inout) :: c( ldc, * )
      end subroutine zgemm
    end interface zgemm

    real(dp),target,allocatable  :: amat_real(:,:,:)
    complex(dp),allocatable :: bmat(:,:), cmat(:,:)
    integer,parameter :: n=100
    !complex(dp),pointer,contiguous :: amat_ptr(:,:)

    ! Allocate Matrices.
    allocate(amat_real(2, n, n))
    allocate(bmat(n,n), cmat(n,n))
    bmat = cone; cmat = one

    ! Cannot pass amam_real due to explicit interace
    ! One can remove the interface but mind possible real bugs.
    !call ZGEMM("N","N", n, n, n, cone, amat_real, n, bmat, n, czero, cmat, n)

    ! iso_c_binding allows us to bypass type-checking
    !call c_f_pointer(c_loc(amat_real), amat_ptr, [2, n, n])
    !call ZGEMM("N","N", n, n, n, cone, amat_ptr, n, bmat, n, czero, cmat, n)

    deallocate(amat_real)
    deallocate(bmat, cmat)

end subroutine zgemm_with_real_arrays

! This example shows the degradation of performance if may have when
! passing an array descriptor to e.g. F77 Blas routines.
subroutine copyin_copyout(nn)

    real(dp) :: cputime, walltime, gflops, res
    integer,intent(in) :: nn
    real(dp),external :: ddot
    !real(dp) :: vec1(2*nn), vec2(2*nn)  ! Automatic arrays put on the *stack*
    !                                    ! "allocation" is really fast but then you have to use `ulimit -s unlimited`
    !                                    ! before running the code. Use them wisely!

    real(dp),allocatable :: vec1(:), vec2(:)  ! Automatic arrays put on the *stack*

    allocate(vec1(2*nn), vec2(2*nn))
    vec1 = one; vec2 = one

    call cwtime(cputime, walltime, gflops, "start")
    res = my_ddot(vec1(1:2*nn:2), vec2(1:2*nn:2))
    call cwtime(cputime, walltime, gflops, "stop")
    write(stdout, "(a,i0,2(a,f8.2))")"my_ddot: nn: ", nn," cpu-time: ",cputime,", wall-time: ",walltime

    call cwtime(cputime, walltime, gflops, "start")
    res = ddot(nn, vec1, 2, vec2, 2)
    call cwtime(cputime, walltime, gflops, "stop")
    write(stdout, "(a,i0,2(a,f8.2))")"blas_ddot: nn: ", nn," cpu-time: ",cputime,", wall-time: ",walltime

    deallocate(vec1, vec2)

end subroutine copyin_copyout

end program main
