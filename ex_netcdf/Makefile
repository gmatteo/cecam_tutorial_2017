FC=mpif90
FCFLAGS=-g -O2 -I../ -J../ -L.. -lcore -ffree-form --free-line-length-none 

LIBS = -L${CONDA_PREFIX} -lnetcdff -lnetcdf -lhdf5_hl -lhdf5
# If you have support for MPI-IO in HDF5 ...
LIBS += -L${CONDA_PREFIX} -lmpi

all:
	$(FC) $(LIBS) main.F90 $(FCFLAGS) 

clean:
	/bin/rm -f *.o *.mod *.a a.out
