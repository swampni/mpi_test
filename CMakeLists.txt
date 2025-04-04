cmake_minimum_required(VERSION 3.17.2...3.26)

project(mpitest
  VERSION 0.0.1
  DESCRIPTION "testing"
  LANGUAGES C Fortran
)

find_package(Python REQUIRED COMPONENTS Interpreter Development.Module NumPy)
find_package(MPI REQUIRED)
find_package(MKL REQUIRED)


# F2PY headers
execute_process(
  COMMAND "${Python_EXECUTABLE}"
  -c "import numpy.f2py; print(numpy.f2py.get_include())"
  OUTPUT_VARIABLE F2PY_INCLUDE_DIR
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

set(f2py_module_name "mpitest")
set(fortran_src_file "${CMAKE_SOURCE_DIR}/src/mpiinfo.f90")
set(f2py_module_c "${f2py_module_name}module.c")
set(f2py_wrappers "${f2py_module_name}-f2pywrappers2.f90")

add_custom_command(
  OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${f2py_module_c}"
         "${CMAKE_CURRENT_BINARY_DIR}/${f2py_wrappers}"  
  COMMAND ${PYTHON_EXECUTABLE}  -m "numpy.f2py"
                   "${CMAKE_SOURCE_DIR}/src/main.f90"
                   "${fortran_src_file}"
                   -m "mpitest"
                   --lower # Important
  DEPENDS src/mpiinfo.f90 # Fortran source
)

python_add_library(${CMAKE_PROJECT_NAME} MODULE
            "${f2py_module_name}module.c"
            "${f2py_module_name}-f2pywrappers2.f90"
            "${F2PY_INCLUDE_DIR}/fortranobject.c"
            "${CMAKE_SOURCE_DIR}/src/mpiinfo.f90"
            "${CMAKE_SOURCE_DIR}/src/main.f90"
             WITH_SOABI)

target_include_directories(${CMAKE_PROJECT_NAME} PUBLIC
                           ${F2PY_INCLUDE_DIR}
                           ${MPI_Fortran_INCLUDE_PATH}
                          )

target_link_libraries(${CMAKE_PROJECT_NAME} PUBLIC 
Python::NumPy
MPI::MPI_Fortran
)

install(TARGETS ${CMAKE_PROJECT_NAME} DESTINATION mpitest)

# Create the worker executable
add_executable(worker 
"${CMAKE_SOURCE_DIR}/src/worker.f90"
"${CMAKE_SOURCE_DIR}/src/bloch_cgeev_mkl.F90"
)

# Link against MPI Fortran libraries
target_include_directories(worker PRIVATE 
${MPI_Fortran_INCLUDE_PATH}
${MKL_INCLUDE_DIRS}
)

set(MKL_LIBRARIES "-lmkl_intel_lp64 -lmkl_core -lmkl_sequential -lpthread -ldl")
target_link_libraries(worker PRIVATE 
MPI::MPI_Fortran
${MKL_LIBRARIES}
)

# Optionally, install the worker executable
install(TARGETS worker DESTINATION mpitest)

