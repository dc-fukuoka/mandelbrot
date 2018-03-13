fc      = $(shell printenv FC)
fcflags = -g -O3 -mavx -fopenmp
src     = mandelbrot.F90
bin     = a.out

$(bin): $(src)
	$(fc) $(fcflags) $^ -o $@

all: $(bin)

clean:
	rm -f $(bin) *.mod *~
