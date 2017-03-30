FC=gfortran
FCFLAGS=-g -O2 -I../ -J../ -L.. -lcore -ffree-form --free-line-length-none -L${CONDA_PREFIX} -lopenblas

#MKLROOT=${CONDA_PREFIX}
#FCFLAGS=-g -O2 -I../ -J../ -L.. -lcore -ffree-form --free-line-length-none \
#	 -L${MKLROOT}/lib -Wl,-rpath,${MKLROOT}/lib -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -lpthread -lm -ldl \
#         -m64 -I${MKLROOT}/include

all:
	$(FC) main.F90 $(FCFLAGS) 

clean:
	/bin/rm -f *.o *.mod *.a a.out
