module mpiinfo
    use MPI
    implicit none

    integer :: intercomm
    logical :: first
    
contains

subroutine mpiinfo_initializing()
    first = .true.
    
end subroutine mpiinfo_initializing

subroutine mpiinfo_despawn()
    integer :: ierr
    call MPI_BCAST(.true., 1, MPI_LOGICAL, MPI_ROOT, intercomm, ierr)
    call MPI_COMM_DISCONNECT(intercomm, ierr)

    
end subroutine mpiinfo_despawn
    
end module mpiinfo