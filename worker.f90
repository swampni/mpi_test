program worker
    use MPI
    implicit none

    integer :: ierr, rank, size, parentcomm
    logical :: stop_signal
    integer :: ntask, i, init, final, j, k
    integer, dimension(:), allocatable :: payload
    integer, dimension(:), allocatable :: eigenvalues

    call MPI_Init(ierr)
    call MPI_COMM_SIZE(MPI_COMM_WORLD, size, ierr)
    call MPI_COMM_RANK(MPI_COMM_WORLD, rank, ierr)
    call MPI_COMM_GET_PARENT(parentcomm, ierr)

    allocate(eigenvalues(5*5), payload(5))

    do
        call MPI_BCAST(ntask, 1, MPI_INTEGER, 0, parentcomm, ierr)        
        call MPI_BCAST(payload, 5, MPI_INTEGER, 0, parentcomm, ierr)

        init = ntask / size * rank + 1
        final = ntask / size * (rank + 1)  
        if (rank.eq.size-1) final = ntask

        ! write(*,*) 'Worker ', rank, ' of ', size, ' will compute from ', init, ' to ', final
        do i = init, final
            do j = 1, 5
                eigenvalues(j + 5*(i-init)) = payload(j)*i
            end do
        end do
        call sleep(1)
        
        call MPI_GATHERV(eigenvalues, 5*(final-init+1), MPI_INTEGER, MPI_IN_PLACE, 0, 0, MPI_DATATYPE_NULL, 0, parentcomm, ierr)
        ! wait for the stop signal
        write(*,*) 'Worker ', rank, ' of ', size, ' is waiting for the stop signal'
        call MPI_BCAST(stop_signal, 1, MPI_LOGICAL, 0, parentcomm, ierr)
        write(*,*) 'Worker ', rank, ' of ', size, ' received', stop_signal, ierr
        if (stop_signal) exit    
    end do
    deallocate(eigenvalues, payload)
    write(*,*) 'Worker ', rank, ' of ', size, ' is done'
    call MPI_Comm_disconnect(parentcomm, ierr)
    call MPI_Finalize(ierr)
end program worker