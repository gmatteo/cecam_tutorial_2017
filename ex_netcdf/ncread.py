#!/usr/bin/env python
from __future__ import print_function
import numpy as np
import netCDF4

dataset = netCDF4.Dataset("data.nc", mode="r")

print(" Netcdf dimensions")
for dimname in dataset.dimensions:
    print("dimname", dimname, dataset.dimensions[dimname])

print("Found %d variables" % len(dataset.variables))
for var in dataset.variables.values():
    print("Variable name: %s, shape: %s" % (var.name, var.shape))

# Read variables.
xvals = dataset.variables["xvals"][:]
yvals = dataset.variables["yvals"][:]

# Close the file.
dataset.close()

# Plot data.
import matplotlib.pyplot as plt

fig, ax = plt.subplots()

ax.plot(xvals, yvals)
ax.set_xlabel("x")
ax.set_ylabel(r"$\sin(x)$")
ax.grid(True)
plt.show()
