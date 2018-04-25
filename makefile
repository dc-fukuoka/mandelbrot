fc          = $(shell printenv FC)
mpifc       = $(shell printenv MPIFC)
fcflags     = -g -O3 -mavx -fopenmp
fcflags_acc = -O4 -Mvect=simd:256 -Mfma -acc -ta=tesla:cc60 -Minfo=accel
src         = mandelbrot.F90
src_mpi     = mandelbrot_mpi.F90
src_acc     = mandelbrot_mpi_acc.F90
bin         = a.out
bin_mpi     = a.out.mpi
bin_acc     = a.out.mpi.acc

# $(bin_acc) requires PGI compiler
all: $(bin) $(bin_mpi)

$(bin): $(src)
	$(fc) $(fcflags) $^ -o $@

$(bin_mpi): $(src_mpi)
	$(mpifc) $(fcflags) $^ -o $@

$(bin_acc): $(src_acc)
	$(mpifc) $(fcflags_acc) $^ -o $@

clean:
	rm -f $(bin) $(bin_mpi) $(bin_acc) *.mod *~ out
