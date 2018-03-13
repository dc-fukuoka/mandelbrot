Mandelbrot set by OpenMP.
====
  
* how to run:  
~~~bash
make
vi fort.11 # adjust the parameters
./a.out
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
