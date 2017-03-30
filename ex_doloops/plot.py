#!/usr/bin/env python
import numpy as np

with open("slow.dat", "rt") as fh:
    slow_data = np.array([l.split() for i, l in enumerate(fh) if i > 0])
    # n, cputime, walltime, gflops
    slow_data = slow_data.T

with open("fast.dat", "rt") as fh:
    fast_data = np.array([l.split() for i, l in enumerate(fh) if i > 0])
    fast_data = fast_data.T

# Plot data.
import matplotlib.pyplot as plt

# Change the graphical backend e.g. TkAgg, Qt4Agg, WXAgg ...)
# (see also ~matplotlib/.matplotlibrc)
#import matplotlib
#matplotlib.use("TkAgg")

fig, ax = plt.subplots()

ax.plot(slow_data[0], slow_data[1], label="slow")
ax.plot(fast_data[0], fast_data[1], label="fast")
ax.legend(loc="best")
ax.set_xlabel("n")
ax.set_ylabel("Time [s]")

plt.show()
