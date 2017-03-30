#include "common.h"

program netcdf_io

    use m_core
    use mpi
    use netcdf

    implicit none

    integer :: ierr, my_rank, nprocs, ii, irnk, comm
    integer,parameter :: master=0
    integer,parameter :: ntot = 10**5
    integer :: my_n, size_of_irk
    real(dp),allocatable :: my_vector(:)
    integer,allocatable :: start_rank(:),stop_rank(:)
    integer :: ncid, ntot_dimid, var_id, ncerr

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

    ! Open netcdf file in write mode and get `ncid` identifier.
    ! overwrite pre-existent files.
    ncerr = nf90_create("data.nc", ior(nf90_clobber, nf90_write), ncid)

    ! One should always test the return code.
    if (ncerr /= nf90_noerr) stop

    ! But don't repeat yourself.
#define NCF_CHECK(ncerr) if (ncerr /= nf90_noerr) MSG_ERROR(nf90_strerror(ncerr))
    NCF_CHECK(nf90_put_att(ncid, NF90_GLOBAL, "code", "my wonderful code"))

    ! Define dimension.
    NCF_CHECK(nf90_def_dim(ncid, "ntot", ntot, ntot_dimid))

    ! vector[ntot] array of double numbers.
    NCF_CHECK(nf90_def_var(ncid, "vector", nf90_double, ntot_dimid, var_id))
    NCF_CHECK(nf90_enddef(ncid))

    ! Write data.
    NCF_CHECK(nf90_put_var(ncid, var_id, my_vector))

    ! Close file.
    NCF_CHECK(nf90_close(ncid))

    deallocate(my_vector)
    deallocate(start_rank, stop_rank)

    ! Finalize MPI
    !call MPI_FINALIZE(ierr)

end program netcdf_io
