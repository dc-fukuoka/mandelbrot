#!/usr/bin/env python3

# ref: http://pradhanphy.blogspot.jp/2015/01/pm3d-map-of-gnuplot-in-matplotlib.html
# ref: https://matplotlib.org/examples/showcase/mandelbrot.html

import f90nml
import numpy as np
import matplotlib
import matplotlib.pyplot as plt
from matplotlib import colors
from scipy.interpolate import griddata

nml   = f90nml.read("fort.11")
x_min = nml["params"]["x_min"]
x_max = nml["params"]["x_max"]
y_min = nml["params"]["y_min"]
y_max = nml["params"]["y_max"]
dx    = nml["params"]["dx"]
dy    = nml["params"]["dy"]
tol   = nml["params"]["tol"]

x = np.arange(x_min, x_max+dx, dx)
y = np.arange(y_min, y_max+dy, dy)

imax = x.shape[0]
jmax = y.shape[0]

print("imax, jamx:", imax, jmax)

with open("out", "rb") as fp:
    z = np.fromfile(fp, np.float64, -1).reshape((imax, jmax), order='f').transpose()

plt.imshow(z, origin="lower", vmin=0.0, vmax=tol, cmap="hot", aspect="equal", extent=[x_min,x_max,y_min,y_max])

plt.xlabel("real(c)")
plt.ylabel("imag(c)")
plt.title("mandelbrot_mpi")
plt.colorbar()
plt.savefig("mandelbrot_mpi.png")
