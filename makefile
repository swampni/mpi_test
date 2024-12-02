# Compiler
FC = mpiifx

# Compiler flags
FFLAGS = -O2 -xHost

# MPI flags
MPI_FLAGS = -lmpi

# Source files
SRC = mpiinfo.f90 main.f90 worker.f90

# Object files
OBJ = $(SRC:.f90=.o)

# Executables
EXE = main worker

# Default target
all: $(EXE)

# Compile main
main: mpiinfo.o main.o
	$(FC) $(FFLAGS) $(MPI_FLAGS) -o $@ mpiinfo.o main.o

# Compile worker
worker: mpiinfo.o worker.o
	$(FC) $(FFLAGS) $(MPI_FLAGS) -o $@ mpiinfo.o worker.o

# Compile object files
%.o: %.f90
	$(FC) $(FFLAGS) $(MPI_FLAGS) -c $<

# Clean target
clean:
	rm -f $(EXE) $(OBJ) *.mod

.PHONY: all clean