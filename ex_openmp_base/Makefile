FC=gfortran
FCFLAGS=-g -O2 -fopenmp -I../ -J../ -L.. -lcore -ffree-form --free-line-length-none
LIBS=-L${CONDA_PREFIX} -lopenblas

all:
	$(FC) main.F90 $(FCFLAGS) $(LIBS)

clean:
	/bin/rm -f *.o *.mod *.a a.out
