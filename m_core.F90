#include "common.h"

module m_core

    use ISO_FORTRAN_ENV, only : input_unit, output_unit, error_unit

    public :: cwtime
    public :: handle_error

    !number of bytes related to default double-precision real/complex subtypes
    !(= 8 for many machine architectures)
    integer, public, parameter :: dp=kind(1.0d0)

    ! new line char.
    character(len=1), parameter :: ch10 = char(10)

    integer, parameter :: stdin = input_unit      ! 5
    integer, parameter :: stdout = output_unit    ! 6
    integer, parameter :: stderr = error_unit     ! 0

    ! Used to dimension message strings (Avoid magic numbers)
    integer, parameter :: msg_len = 1024

    !Real constants
    real(dp), parameter :: zero=0._dp
    real(dp), parameter :: one=1._dp
    real(dp), parameter :: two=2._dp
    real(dp), parameter :: three=3._dp
    real(dp), parameter :: four=4._dp
    real(dp), parameter :: five=5._dp
    real(dp), parameter :: six=6._dp
    real(dp), parameter :: seven=7._dp
    real(dp), parameter :: eight=8._dp
    real(dp), parameter :: nine=9._dp
    real(dp), parameter :: ten=10._dp

    complex(dp) :: cone=1.0_dp, czero=0.0_dp

contains

!!****f* m_core/cwtime
!! NAME
!!  cwtime
!!
!! FUNCTION
!!  Timing routine. Returns cpu and wall clock time in seconds.
!!
!! INPUTS
!!  start_or_stop=
!!    "start" to start the timers
!!    "stop" to stop the timers and return the final cpu_time and wall_time
!!
!! OUTPUT
!!  cpu= cpu time in seconds
!!  wall= wall clock time in seconds
!!  gflops = Gigaflops
!!
!! NOTES
!!  Example:
!!  ! Init cpu and wall
!!  call cwtime(cpu,wall,gflops,"start")
!!
!!  do_stuff()
!!
!!  ! stop the counters, return cpu- and wall-time spent in do_stuff()
!!  call cwtime(cpu,wall,gflops,"stop")
!!
!! PARENTS
!!
!! CHILDREN
!!
!! SOURCE

!impure
subroutine cwtime(cpu,wall,gflops,start_or_stop)

!Arguments ------------------------------------
!scalars
 real(dp),intent(inout) :: cpu,wall
 real(dp),intent(out) :: gflops
 character(len=*),intent(in) :: start_or_stop

!Local variables-------------------------------
#ifdef HAVE_PAPI
 integer(C_INT)  :: check
 integer(C_LONG_LONG) :: flops
 real(C_FLOAT) :: real_time,proc_time,mflops
#endif

! *************************************************************************

 SELECT CASE (start_or_stop)
 CASE ("start")
#ifdef HAVE_PAPI
   call xpapi_flops(real_time,proc_time,flops,mflops,check)
   cpu = proc_time; wall = real_time; gflops = mflops / 1000
#else
   cpu = my_cpu_time(); wall = my_wtime(); gflops = -one
#endif

 CASE ("stop")
#ifdef HAVE_PAPI
   call xpapi_flops(real_time,proc_time,flops,mflops,check)
   cpu = proc_time - cpu; wall = real_time - wall; gflops = mflops / 1000
#else
   cpu = my_cpu_time() - cpu; wall = my_wtime() - wall; gflops = -one
#endif

 CASE DEFAULT
   MSG_ERROR("Wrong option for start_or_stop: "//trim(start_or_stop))
 END SELECT

end subroutine cwtime
!!***

!!****f* m_core/handle_error
!! NAME
!!  handle_error
!!
!! FUNCTION
!!  Basic error handler. This routine is usually interfaced through some macro defined in common.h
!!
!! INPUTS
!!  message=string containing additional information on the nature of the problem
!!  file=name of the f90 file containing the caller
!!  line=line number of the file where problem occurred
!!
!! SOURCE

subroutine handle_error(message, file, line)

!Arguments ------------------------------------
 integer,optional,intent(in) :: line
 character(len=*),intent(in) :: message
 character(len=*),optional,intent(in) :: file

!Local variables-------------------------------
 integer :: f90line,ierr
 character(len=10) :: lnum
 character(len=500) :: f90name
 character(len=LEN(message)) :: my_msg
 character(len=MAX(4*LEN(message),2000)) :: sbuf ! Increase size and keep fingers crossed!

! *********************************************************************

 if (PRESENT(line)) then
   f90line=line
 else
   f90line=0
 end if
 write(lnum,"(i0)")f90line

 if (PRESENT(file)) then
   !f90name = basename(file)
   f90name = file
 else
   f90name='Subroutine Unknown'
 end if

 write(stdout,'(5a,i0,3a)')ch10,&
   "src_file: ",trim(f90name),ch10,&
   "src_line: ",f90line,ch10,&
   "message: ",TRIM(message)

#ifdef HAVE_MPI
 call MPI_ABORT(MPI_COMM_WORLD, MPI_ERR_UNKNOWN, ierr)
#endif
 stop

end subroutine handle_error
!!***

!----------------------------------------------------------------------

!!****f* m_core/my_cpu_time
!! NAME
!!  my_cpu_time
!!
!! FUNCTION
!!  Timing routine. Returns cpu time in seconds since some arbitrary start.
!!
!! INPUTS
!!  (no inputs)
!!
!! OUTPUT
!!  cpu_time= cpu time in seconds

function my_cpu_time() result(cpu)

!Arguments ------------------------------------
 real(dp) :: cpu

!Local variables-------------------------------
 integer :: count_now,count_max,count_rate

! *************************************************************************

!Machine-dependent timers
!This is the Fortran90 standard subroutine, might not always be sufficiently accurate
 !call system_clock(count_now,count_rate,count_max)
 !cpu=dble(count_now)/dble(count_rate)

 call cpu_time(cpu)

end function my_cpu_time
!!***

!----------------------------------------------------------------------

!!****f* m_core/my_wtime
!! NAME
!!  my_wtime
!!
!! FUNCTION
!!  Return wall clock time in seconds since some arbitrary start.
!!  Call the F90 intrinsic date_and_time .
!!
!! INPUTS
!!  (no inputs)
!!
!! OUTPUT
!!  wall= wall clock time in seconds
!!
!! PARENTS
!!
!! CHILDREN
!!
!! SOURCE

function my_wtime() result(wall)

!Arguments ------------------------------------
!scalars
 real(dp) :: wall

!Local variables-------------------------------
!scalars
#ifndef HAVE_MPI
 integer,parameter :: nday(24)=(/31,28,31,30,31,30,31,31,30,31,30,31,&
&                                31,28,31,30,31,30,31,31,30,31,30,31/)
 integer,save :: month_init,month_now,start=1,year_init
 integer :: months
 character(len=8)   :: date
 character(len=10)  :: time
 character(len=5)   :: zone
 character(len=500) :: msg
!arrays
 integer :: values(8)
#endif

! *************************************************************************

#ifndef HAVE_MPI
!The following section of code is standard F90, but it is useful only if the intrinsics
!date_and_time is accurate at the 0.01 sec level, which is not the case for a P6 with the pghpf compiler ...
!Year and month initialisation
 if(start==1)then
   start=0
   call date_and_time(date,time,zone,values)
   year_init=values(1)
   month_init=values(2)
 end if

!Uses intrinsic F90 subroutine Date_and_time for
!wall clock (not correct when a change of year happen)
 call date_and_time(date,time,zone,values)

!Compute first the number of seconds from the beginning of the month
 wall=(values(3)*24.0d0+values(5))*3600.0d0+values(6)*60.0d0+values(7)+values(8)*0.001d0

!If the month has changed, compute the number of seconds
!to be added. This fails if the program ran one year !!
 month_now=values(2)
 if(month_now/=month_init)then
   if(year_init+1==values(1))then
     month_now=month_now+12
   end if
   if(month_now<=month_init)then
     msg = 'Problem with month and year numbers.'
     MSG_BUG(msg)
   end if
   do months=month_init,month_now-1
     wall=wall+86400.0d0*nday(months)
   end do
 end if

!Now take into account bissextile years (I think 2000 is bissextile, but I am not sure ...)
 if(mod(year_init,4)==0 .and. month_init<=2 .and. month_now>2)   wall=wall+3600.0d0
 if(mod(values(1),4)==0 .and. month_init<=14 .and. month_now>14) wall=wall+3600.0d0

#else
!Use the timer provided by MPI1.
 wall = MPI_WTIME()
#endif

end function my_wtime
!!***

!----------------------------------------------------------------------

!!****f* m_core/distrib_tasks
!! NAME
!!  distrib_tasks
!!
!! FUNCTION
!!  Splits a number of tasks, ntasks, among nprocs processors.
!!  The output arrays istart(1:nprocs) and istop(1:nprocs)
!!  report the starting and final task index for each CPU.
!!  Namely CPU with rank ii has to perform all the tasks between
!!  istart(ii+1) and istop(ii+1). Note the Fortran convention of using
!!  1 as first index of the array.
!!  Note, moreover, that if a proc has rank>ntasks then :
!!   istart(rank+1)=ntasks+1
!!   istop(rank+1)=ntask
!!
!!  In this particular case, loops of the form
!!
!!      do ii=istart(rank),istop(rank)
!!              ...
!!      end do
!!
!!  are not executed. Moreover allocation such as foo(istart(rank):istop(rank))
!!  will generate a zero-sized array
!!
!! INPUTS
!!  ntasks= number of tasks
!!  nprocs=Number of processors.
!!
!! OUTPUT
!!  istart(nprocs),istop(nprocs)= indices defining the initial and final task for each processor

subroutine distrib_tasks(ntasks,nprocs,istart,istop)

!Arguments ------------------------------------
 integer,intent(in)  :: ntasks,nprocs
 integer,intent(inout) :: istart(nprocs),istop(nprocs)

!Local variables-------------------------------
 integer :: res,irank,block,block_tmp

! *************************************************************************

 block_tmp = ntasks/nprocs
 res       = MOD(ntasks,nprocs)
 block     = block_tmp+1

 do irank=0,nprocs-1
   if (irank<res) then
     istart(irank+1) = irank    *block+1
     istop (irank+1) = (irank+1)*block
   else
     istart(irank+1) = res*block + (irank-res  )*block_tmp+1
     istop (irank+1) = res*block + (irank-res+1)*block_tmp
   end if
 end do

end subroutine distrib_tasks
!!***

end module m_core
