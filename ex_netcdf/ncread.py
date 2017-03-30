#!/usr/bin/env python
from __future__ import print_function
import numpy as np
import netCDF4

dataset = netCDF4.Dataset("data.nc", mode="r")
for dimname in dataset.dimensions:
    print("dimname", dimname, dataset.dimensions[dimname])
print(dataset.variables)

vector = dataset.variables["vector"]

# Close the file.
dataset.close()

# Plot data.
import matplotlib.pyplot as plt

fig, ax = plt.subplots()

ax.plot(vector, label="slow")
ax.legend(loc="best")
#ax.set_xlabel("n")
#ax.set_ylabel("Time [s]")
plt.show()
