FC=gfortran
FCFLAGS=-g -O2 -c -ffree-form --free-line-length-none

all:
	$(FC) $(FCFLAGS) m_core.F90
	#rm -f libcore.a
	ar rc libcore.a m_core.o

clean:
	/bin/rm -f *.o *.mod *.a a.out