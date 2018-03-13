Mandelbrot set by OpenMP.
====
  
* how to run:  
~~~
$ make
$ vi fort.11 # adjust the parameters
$ ./a.out
 maximum iteration:         200
 imax:         301 jmax:         251
 time[s]:  1.210000000000000E-002
./draw.py
~~~
  
`$ display mandelbrot.png`  
![Alt text](./mandelbrot.png?raw=true "Mandelbrot set")
  
or  
  
~~~
$ gnuplot
gnuplot> set pm3d map
gnuplot> splot "fort.100"
~~~
