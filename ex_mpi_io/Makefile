FC=mpif90
FCFLAGS=-g -O2 -I../ -J../ -L.. -lcore -ffree-form --free-line-length-none 

LIBS = -L${CONDA_PREFIX} -lmpi

all:
	$(FC) $(LIBS) main.F90 $(FCFLAGS) 

clean:
	/bin/rm -f *.o *.mod *.a a.out
