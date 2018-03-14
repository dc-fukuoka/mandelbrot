fc      = $(shell printenv FC)
mpifc   = $(shell printenv MPIFC)
fcflags = -g -O3 -mavx -fopenmp
src     = mandelbrot.F90
src_mpi = mandelbrot_mpi.F90
bin     = a.out
bin_mpi = a.out.mpi

all: $(bin) $(bin_mpi)

$(bin): $(src)
	$(fc) $(fcflags) $^ -o $@

$(bin_mpi): $(src_mpi)
	$(mpifc) $(fcflags) $^ -o $@

clean:
	rm -f $(bin) $(bin_mpi) *.mod *~ out
