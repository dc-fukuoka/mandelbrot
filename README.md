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

to view the graph
====
`$ display mandelbrot.png`  
![Alt text](./mandelbrot.png?raw=true "Mandelbrot set")
  
or  
  
~~~
$ gnuplot
gnuplot> set pm3d map
gnuplot> splot "fort.100"
~~~
MPI version can not use gnuplot because the output is a binary.

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

performance comparison
====
CPU: Intel(R) Xeon(R) CPU E5-2450 0 @ 2.10GHz, 8 cores/socket, 2 sockets, 8 nodes  
interconnect: 4xFDR infiniband, fat tree  
compiler: intel compiler 2018u0  
MPI: intel MPI 2018u0
* input:
~~~
&params
iter_max = 200
dx       = 2.0d-4
dy       = 2.0d-4
x_min    = -2.25d0
x_max    = 0.75d0
y_min    = -1.25d0
y_max    = 1.25d0
tol      = 1.0d2
/
~~~
* serial(1 core)
~~~
$ OMP_NUM_THREADS=1 KMP_AFFINITY=compact srun --mpi=pmi2 -N1 -n1 -c1 --cpu_bind=cores -m block:block ./a.out
 maximum iteration:         200
 imax:       15001 jmax:       12501
 time[s]:   104.264600000000
~~~
* OpenMP(1 node, 16 cores)
~~~
$ OMP_NUM_THREADS=16 KMP_AFFINITY=compact srun -n1 -c16 --cpu_bind=cores -m block:block ./a.out
srun: Warning: can't run 1 processes on 8 nodes, setting nnodes to 1
 maximum iteration:         200
 imax:       15001 jmax:       12501
 time[s]:   15.1660000000000
~~~
* flat MPI(1 node, 16 cores, np_i=4, np_j=4, 1 thread/process)
~~~
$ I_MPI_EXTRA_FILESYSTEM=1 I_MPI_EXTRA_FILESYSTEM_LIST=lustre OMP_NUM_THREADS=1 KMP_AFFINITY=compact srun --mpi=pmi2 -N1 -n16 -c1 --cpu_bind=
cores -m block:block ./a.out.mpi
 maximum iteration:         200
 imax:       15001 jmax:       12501
 time[s]:   23.8055260181427
~~~
* hybrid(1 node, 16 cores, np_i=1, np_j=2, 8 threads/process)
~~~
$ I_MPI_EXTRA_FILESYSTEM=1 I_MPI_EXTRA_FILESYSTEM_LIST=lustre OMP_NUM_THREADS=8 KMP_AFFINITY=compact srun --mpi=pmi2 -N1 -n2 -c8 --cpu_bind=c
ores -m block:block ./a.out.mpi
 maximum iteration:         200
 imax:       15001 jmax:       12501
 time[s]:   15.0692129135132
~~~
* flat MPI(8 nodes, 128 cores, np_i=8, np_j=16, 1 thread/process)
~~~
$ I_MPI_EXTRA_FILESYSTEM=1 I_MPI_EXTRA_FILESYSTEM_LIST=lustre OMP_NUM_THREADS=1 KMP_AFFINITY=compact srun --mpi=pmi2 -N8 -n128 -c1 --cpu_bind
=cores -m block:block ./a.out.mpi
 maximum iteration:         200
 imax:       15001 jmax:       12501
 time[s]:   3.35678577423096
~~~
* hybrid(8 nodes, 128 cores, np_i=4, np_j=4, 8 threads/process)
~~~
$ I_MPI_EXTRA_FILESYSTEM=1 I_MPI_EXTRA_FILESYSTEM_LIST=lustre OMP_NUM_THREADS=8 KMP_AFFINITY=compact srun --mpi=pmi2 -N8 -n16 -c8 --cpu_bind=
cores -m block:block ./a.out.mpi
 maximum iteration:         200
 imax:       15001 jmax:       12501
 time[s]:   3.36353015899658
~~~
