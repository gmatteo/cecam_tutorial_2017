FC=gfortran
FCFLAGS=-g -O2 -I../ -J../ -L.. -lcore -ffree-form --free-line-length-none 
LIBS=-L${CONDA_PREFIX} -lopenblas

# https://software.intel.com/en-us/articles/intel-mkl-link-line-advisor
#MKLROOT=${CONDA_PREFIX}
#LIBS=-g -O2 -I../ -J../ -L.. -lcore -ffree-form --free-line-length-none \
#	 -L${MKLROOT}/lib -Wl,-rpath,${MKLROOT}/lib -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -lpthread -lm -ldl \
#         -m64 -I${MKLROOT}/include

all:
	$(FC) main.F90 $(FCFLAGS) $(LIBS)

clean:
	/bin/rm -f *.o *.mod *.a a.out
