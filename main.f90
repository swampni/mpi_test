program main
    use MPI
    implicit none

    integer :: ierr
    integer :: i

    call MPI_Init(ierr)

    do i = 1,10 
        call manager(2, i+5)
    end do

    call MPI_Finalize(ierr)
    
end program main


subroutine manager(nprocs, ntasks)
    use MPI
    implicit none
    integer, intent(in) :: nprocs, ntasks
    integer :: i
    integer :: ierr, intercomm
    integer, dimension(4) :: errcodes
    integer, dimension(:), allocatable :: counts, displs

    allocate(counts(nprocs))
    allocate(displs(nprocs))
    do i = 1, nprocs
        counts(i) = (ntasks/nprocs)
        displs(i) = (i-1)*(ntasks/nprocs)
    end do   
    counts(nprocs) = ntasks - (nprocs-1)*(ntasks/nprocs)  

    write(*,*) nprocs
    call MPI_COMM_SPAWN('./worker', MPI_ARGV_NULL, nprocs, MPI_INFO_NULL, 0, MPI_COMM_WORLD, intercomm, errcodes, ierr)
    write(*,*) counts

    call MPI_BCAST(ntasks, 1, MPI_INTEGER, MPI_ROOT, intercomm, ierr)
    
    

    deallocate(counts, displs)
    call MPI_COMM_FREE(intercomm, ierr)

    return    
end subroutine manager

