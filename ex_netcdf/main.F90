#include "common.h"

program netcdf_io

    use m_core
    use netcdf

    implicit none

    integer :: ix,ncid, nx_dimid, xvals_id, yvals_id, ncerr
    integer,parameter :: nx = 100
    real(dp) :: step
    real(dp),parameter :: pi = 3.141592653589793238462643_dp
    real(dp),allocatable :: xvals(:),yvals(:)

    allocate(xvals(nx))
    allocate(yvals(nx))

    ! Compute function on closed mesh.
    step = two * pi / (nx - 1)
    do ix=1,nx
      xvals(ix) = (ix - 1) * step
    end do
    yvals = sin(xvals)

    ! Open netcdf file in write mode and get `ncid` identifier.
    ! overwrite any existing datase
    ncerr = nf90_create("data.nc", ior(nf90_clobber, nf90_write), ncid)

    ! One should always test the return code.
    if (ncerr /= nf90_noerr) stop

    ! But don't repeat yourself.
#define NCF_CHECK(ncerr) if (ncerr /= nf90_noerr) MSG_ERROR(nf90_strerror(ncerr))
    NCF_CHECK(nf90_put_att(ncid, NF90_GLOBAL, "code", "my wonderful code"))

    ! Define dimension.
    NCF_CHECK(nf90_def_dim(ncid, "nx", nx, nx_dimid))

    ! yvals[nx] array of double numbers.
    NCF_CHECK(nf90_def_var(ncid, "yvals", nf90_double, nx_dimid, yvals_id))
    NCF_CHECK(nf90_def_var(ncid, "xvals", nf90_double, nx_dimid, xvals_id))

    NCF_CHECK(nf90_enddef(ncid))

    ! Write data.
    NCF_CHECK(nf90_put_var(ncid, xvals_id, xvals))
    NCF_CHECK(nf90_put_var(ncid, yvals_id, yvals))

    ! Close file.
    NCF_CHECK(nf90_close(ncid))

    deallocate(xvals, yvals)

end program netcdf_io
