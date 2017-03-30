FC=gfortran
FCFLAGS=-g -O0 -I../ -J../ -L.. -lcore -ffree-form --free-line-length-none

all:
	$(FC) main.F90 $(FCFLAGS) 

clean:
	/bin/rm -f *.o *.mod *.a a.out
