program main
    use MPI
    implicit none

    integer :: ierr
    integer :: i

    call MPI_Init(ierr)

    do i = 1,5
        write(*,*) 'Iteration ', i, 'started'
        call manager(2, 10)
        write(*,*) 'Iteration ', i, 'ended'
        
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
    integer, dimension(:), allocatable :: counts, displs, payload, recvbuf

    allocate(counts(nprocs))
    allocate(displs(nprocs))
    allocate(payload(5))
    payload = [1,1,2,3,5]
    do i = 1, nprocs
        counts(i) = (ntasks/nprocs)
        displs(i) = (i-1)*(ntasks/nprocs)
    end do   
    counts(nprocs) = ntasks - (nprocs-1)*(ntasks/nprocs)  

    write(*,*) 'Manager will spawn ', nprocs, ' workers'
    call MPI_COMM_SPAWN('./worker', MPI_ARGV_NULL, nprocs, MPI_INFO_NULL, 0, MPI_COMM_WORLD, intercomm, errcodes, ierr)
    

    call MPI_BCAST(ntasks, 1, MPI_INTEGER, MPI_ROOT, intercomm, ierr)
    call MPI_BCAST(payload, 5, MPI_INTEGER, MPI_ROOT, intercomm, ierr)    

    allocate(recvbuf(5*ntasks))
    
    call MPI_GATHERV(MPI_IN_PLACE,0,MPI_DATATYPE_NULL,recvbuf,counts*5,displs*5,MPI_INTEGER,MPI_ROOT,intercomm,ierr)
    print *, recvbuf
    deallocate(counts, displs, payload, recvbuf)
    call MPI_COMM_DISCONNECT(intercomm, ierr)

    return    
end subroutine manager

