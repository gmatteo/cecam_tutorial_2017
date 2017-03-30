FC=mpif90
FCFLAGS=-g -O2 -I../ -J../ -L.. -lcore -ffree-form --free-line-length-none 
LIBS=-L${CONDA_PREFIX} -lmpi

all:
	$(FC) main.F90 $(FCFLAGS) $(LIBS)

clean:
	/bin/rm -f *.o *.mod *.a a.out
