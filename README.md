Mandelbrot set by MPI/OpenMP.
====
requirements for python:
  - numpy
  - scipy
  - matplotlib
  - f90nml
  
how to run:
---
* for OpenMP version
~~~
$ export FC=ifort
$ make a.out
$ vi fort.11 # adjust the parameters
$ ./a.out
 maximum iteration:         200
 imax:         301 jmax:         251
 time[s]:  1.210000000000000E-002
./draw.py
~~~
* for MPI version
~~~
$ export MPIFC=mpiifort
$ make a.out.mpi
$ vi fort.11 # adjust the parameters
$ mpirun -np $NP ./a.out.mpi # where $NP must equal to np_i*np_j in fort.11
 maximum iteration:         200
 imax:         301 jmax:         251
 time[s]:  7.543087005615234E-003
./draw_mpi.py
~~~
  
`$ display mandelbrot.png`  
![Alt text](./mandelbrot.png?raw=true "Mandelbrot set")
  
or  
  
~~~
$ gnuplot
gnuplot> set pm3d map
gnuplot> splot "fort.100"
~~~

* zoomed calculation
~~~
&params
iter_max = 200
dx       = 5.0d-4
dy       = 5.0d-4
x_min    = -1.2d0
x_max    = -1.1d0
y_min    = 0.2d0
y_max    = 0.3d0
tol      = 1.0d2
/
~~~
![Alt text](./mandelbrot2.png?raw=true "Mandelbrot set")
