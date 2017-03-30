# How to download the examples

Clone the github repository with:

    $ git clone https://github.com/gmatteo/cecam_tutorial_2017

If you don't have `git` on your machine, install `conda` following the instructions
reported in the next sections and then:

    $ conda install git

Organization of the package:

`common.h`:

Include file providing CPP macros 

`m_core.F90`:

Low-level modules with constants and helper functions used in the other examples.

Each example is contained in a separated directory.
Each directory contains a `main.F90` source code, a `Makefile` to compile it, 
a `README.md` file and, optionally, a python script to analyze the results.

To compile the examples, we will use the `gcc` compiler and other external libraries 
provided by conda. Follow the instructions reported in the next section to install `conda` on your machine.

# Install conda

If you are a Linux user, download and install ``miniconda`` on your local machine with:

    $ wget https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh
    $ bash Miniconda2-latest-Linux-x86_64.sh

while for MacOSx use:

    $ wget https://repo.continuum.io/miniconda/Miniconda2-latest-MacOSX-x86_64.sh
    $ bash Miniconda2-latest-MacOSX-x86_64.sh

Answer ``yes`` to the question:

    Do you wish the installer to prepend the Miniconda2 install location
    to PATH in your /home/gmatteo/.bashrc ? [yes|no]
    [no] >>> yes

Source your ``.bashrc`` file to activate the changes done by ``miniconda`` to your ``$PATH``:

    $ source ~/.bashrc

Add ``conda-forge`` to the conda channels:

    $ conda config --add channels conda-forge

Create a new environment based on python2.7 with:

    $ conda create -n myenv python=2.7

and activate the new env with:

    source activate myenv

Install the gcc compiler:

    $ conda install gcc

Use the command:

    $ which gcc

to show the location of the `gcc` compiler.

Now we are ready to start but before proceeding with the examples we have to run:

    $ make

in the top-level directory to compile a tiny library (`libcore.a`) we are gonna use 
in the different examples.
After this step, we are ready for the the first example in the `ex_doloops` directory.
