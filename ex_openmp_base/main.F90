#include "common.h"

program main

    use m_core
    use omp_lib   ! OpenMP runtime library.

    implicit none

    integer :: ii, nthreads, nn, nfound
    character(len=msg_len) :: arg,msg
    integer,allocatable :: primes(:)

    ! Command line interface to set the number of OpenMP threads.
    nn = 10
    if (command_argument_count() /= 0) then
        do ii=1,command_argument_count()
            call get_command_argument(ii, arg)
            !write(*,*)trim(arg)
            if (arg == "-j" .or. arg == "--omp-num-threads") then
              call get_command_argument(ii+1, arg)
              read(arg,*)nthreads
              call omp_set_num_threads(nthreads)
            else if (arg == "-n" .or. arg == "--size") then
              call get_command_argument(ii+1, arg)
              read(arg,*)nn
            else if (arg == "-h" .or. arg == "--help") then
              write(stdout,*)"-n, --problem-size         Set n dimension"
              write(stdout,*)"-j, --omp-num-threads      Set the number of OpenMp threads."
              call exit(0)
            end if
        end do
    end if

    ! Printout of the most important OMP environment variables.
    write(stdout,'(/,a)')  "  ==== OpenMP parallelism ===="
    write(stdout,'(a,i0)') "- Max_threads:       ",omp_get_max_threads()
!$OMP PARALLEL
    write(stdout,'(a,i0)') "- Num_threads:       ",omp_get_num_threads()
!$OMP END PARALLEL
    write(stdout,'(a,i0)') "- Num_procs:         ",omp_get_num_procs()
    write(stdout,'(a,l1)') "- Dynamic:           ",omp_get_dynamic()
    write(stdout,'(a,l1)') "- Nested:            ",omp_get_nested()
    !write(stdout,'(a,i0)')"- Thread_limit:      ",omp_get_thread_limit()
    !write(stdout,'(a,i0)')"- Max_active_levels: ",omp_get_max_active_levels()
    write(stdout,*)""

!$OMP PARALLEL
!!$OMP MASTER
!!!$OMP SINGLE
  write(stdout, *)"Hello World from thread: ", omp_get_thread_num()
!!!$OMP END SINGLE
!!$OMP END MASTER
!$OMP END PARALLEL

    ! Loop parallelism
    !call calc_pi(nn)

    call omp_matmul(nn)

contains

! Compute the value of pi
subroutine calc_pi(nn)

    integer,intent(in) :: nn

    real(dp) ::  pi, h, res, x, f, a
    real(dp) :: cputime,walltime,gflops
    real(dp),parameter :: ref_pi = 3.141592653589793238462643_dp

    ! Calculate the interval size
    h = one / nn
    res  = zero
    call cwtime(cputime, walltime, gflops, "start")
    ! PRIVATE(x) is needed to avoid race conditions.
!$OMP PARALLEL DO REDUCTION(+: res) PRIVATE(x) if (nn > 100)
    do ii = 1, nn
       x = h * (dble(ii) - 0.5d0)
       res = res + four / (one + x*x)
    end do

    pi = h * res
    write(stdout, "(a,i0,2(a,f18.16))")"With n: ",nn," Pi is approximately: ", pi," Error is: ", abs(pi - ref_pi)
    call cwtime(cputime, walltime, gflops, "stop")
    ! cputime is multipled by the number of threads
    write(stdout, "(a,i0,2(a,f8.2))")"With REDUCTION: n: ", nn," cpu-time: ",cputime,", wall-time: ",walltime

    res  = zero
    call cwtime(cputime, walltime, gflops, "start")
    ! PRIVATE(x) is needed to avoid race conditions.
!$OMP PARALLEL DO if (nn > 100)
    do ii = 1, nn
       x = h * (dble(ii) - 0.5d0)
!!$OMP CRITICAL(lock_res)
       res = res + four / (one + x*x)
!!$OMP END CRITICAL(lock_res)
    end do

    pi = h * res
    write(stdout, "(a,i0,2(a,f18.16))")"With n: ",nn," Pi is approximately: ", pi," Error is: ", abs(pi - ref_pi)
    call cwtime(cputime, walltime, gflops, "stop")
    write(stdout, "(a,i0,2(a,f8.2))")"With CRITICAL: n: ", nn," cpu-time: ",cputime,", wall-time: ",walltime

end subroutine calc_pi

subroutine omp_matmul(n)

    integer,intent(in) :: n
    integer,parameter :: nmats = 2

    integer :: ii,jj,kk,imat
    real(dp) :: cputime,walltime,gflops
    complex(dp),allocatable :: amat(:,:,:), bmat(:,:,:), cmat(:,:,:)
    complex(dp) :: ctmp

    allocate(amat(n,n,nmats), bmat(n,n,nmats), cmat(n,n,nmats))

    ! Init with fake data.
!$OMP WORKSHARE
    amat = cone; bmat = two * amat
!$OMP END WORKSHARE

    call cwtime(cputime, walltime, gflops, "start")
    ! C = A * B + C
    ! Don't be greedy!
    ! The speedup is not necessarly proportional to the number of loops parallelized with OMP
!$OMP PARALLEL DO COLLAPSE(3) PRIVATE(ctmp)
    do imat=1,nmats
        do jj=1,n
            do ii=1,n
                ctmp = zero
                do kk=1,n
                    ctmp = ctmp + amat(ii, kk, imat) * bmat(kk, jj, imat)
                end do
                cmat(ii, jj, imat) = cmat(ii, jj, imat) + ctmp
            end do
        end do
    end do
    call cwtime(cputime, walltime, gflops, "stop")
    write(stdout, "(a,i0,2(a,f8.2))")"MATMUL COLLAPSE: n: ", nn," cpu-time: ",cputime,", wall-time: ",walltime

    call cwtime(cputime, walltime, gflops, "start")
    ! C = A * B + C
    ! ZGEMM is thread safe so we can call it inside an OPENMP region
!$OMP PARALLEL DO
    do imat=1,nmats
      call ZGEMM("N","N", n, n, n, cone, amat(:,:,imat), n, bmat(:,:,imat), n, cone, cmat(:,:,imat), n)
    end do
    call cwtime(cputime, walltime, gflops, "stop")
    write(stdout, "(a,i0,2(a,f8.2))")"ZGEMM: n: ", nn," cpu-time: ",cputime,", wall-time: ",walltime

    deallocate(amat, bmat, cmat)

end subroutine omp_matmul

end program main
