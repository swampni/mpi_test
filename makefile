
# Compiler
FC = mpiifx

# Compiler flags
FFLAGS = -O2 -xHost

# MPI flags
MPI_FLAGS = -lmpi

# Source files
SRC = main.f90 worker.f90

# Executables
EXE = main worker

# Default target
all: $(EXE)

# Compile main
main: main.f90
	$(FC) $(FFLAGS) $(MPI_FLAGS) -o $@ $<

# Compile worker
worker: worker.f90
	$(FC) $(FFLAGS) $(MPI_FLAGS) -o $@ $<

# Clean target
clean:
	rm -f $(EXE) *.o *.mod

.PHONY: all clean