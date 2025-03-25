## Using f2py to compile a fortran project using mpi
- use fortran to do the heavylifting
- use MPI to accelerate even more
- use MPI_SPAWN_COMM to seperate the main process and subprocesses. Besides importing mpi4py, python user doesn't have to know anything about the backend parallelization. This also makes it easier for integration with jupyter notebook.
 
