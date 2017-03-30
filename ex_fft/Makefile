FC=gfortran
CONDA_PREFIX=/Users/gmatteo/anaconda2/envs/myenv
#FCFLAGS=-g -O3 -I../ -J../ -L.. -lcore -ffree-form --free-line-length-none -L${CONDA_PREFIX} -lopenblas

MKLROOT=${CONDA_PREFIX}
FCFLAGS=-g -O3 -I../ -J../ -L.. -lcore -ffree-form --free-line-length-none \
	 -L${MKLROOT}/lib -Wl,-rpath,${MKLROOT}/lib -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -lpthread -lm -ldl \
         -m64 -I${MKLROOT}/include

all:
	$(FC) main.F90 $(FCFLAGS) 

clean:
	rm *.o a.out
