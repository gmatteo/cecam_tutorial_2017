#!/usr/bin/env python

import numpy as np
from scipy.fftpack import fft

def do_fft():
    # http://scipy.github.io/devdocs/tutorial/fftpack.html#one-dimensional-discrete-fourier-transforms

    # Number of sample points
    N = 600
    # sample spacing
    T = 1.0 / 800.0
    x = np.linspace(0.0, N*T, N)
    y = np.sin(50.0 * 2.0*np.pi*x) + 0.5*np.sin(80.0 * 2.0*np.pi*x)
    yf = fft(y)
    xf = np.linspace(0.0, 1.0/(2.0*T), N//2)

    with open("func.dat", "wt") as fh:
        fh.write("%s %s\n" % (N, T))
        for xv, yv, yfv in zip(xf, y, yf):
            fh.write("%s %s %s\n" % (xv, yv, yfv))


def read_xyf():
    with open("func.dat", "wt") as fh:
	xf, y, yf = [], [], []
	for i, line in enumerate(fh):
	    if i == 0:
		N, T = tuple(map(float, line.split()))
		N = int(N)
	    else:
		xv, yv, yfv = tuple(map(float, l.split()))
		xf.append(xv)
		y.append(yv)
		yf.append(yfv)

    return N, T, xf, y, yf

    #import matplotlib.pyplot as plt
    #plt.plot(xf, 2.0/N * np.abs(yf[0:N//2]))
    #plt.grid()
    #plt.show()

if __name__ == "__main__":
    do_fft()

