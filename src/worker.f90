program worker
    use MPI
    implicit none

    integer :: ierr, rank, size, parentcomm, test
    PARAMETER (test = 1000)
    logical :: stop_signal
    integer :: ntask, i, init, final, j, k, mklerr
    integer, dimension(:), allocatable :: payload
    real, dimension(:, :), allocatable :: a, b
    complex, dimension(:, :), allocatable :: ugh, vector
    complex, dimension(:), allocatable :: eigenvalues

    
    external :: bloch_cgeev

    call MPI_Init(ierr)
    call MPI_COMM_SIZE(MPI_COMM_WORLD, size, ierr)
    call MPI_COMM_RANK(MPI_COMM_WORLD, rank, ierr)
    call MPI_COMM_GET_PARENT(parentcomm, ierr)

    allocate(payload(5))

    do
        call MPI_BCAST(ntask, 1, MPI_INTEGER, 0, parentcomm, ierr)        
        call MPI_BCAST(payload, 5, MPI_INTEGER, 0, parentcomm, ierr)

        init = ntask / size * rank + 1
        final = ntask / size * (rank + 1)  
        if (rank.eq.size-1) final = ntask

        ! write(*,*) 'Worker ', rank, ' of ', size, ' will compute from ', init, ' to ', final
        write(*,*) 'allocate a, b, vector, ugh, eigenvalues'
        allocate(a(test, test), b(test,test), vector(test, test), ugh(test, test), eigenvalues(test))
        call random_number(a)
        call random_number(b)
        ugh = cmplx(a, b)
        write(*,*) 'enter cgeev'
        call bloch_cgeev(test, test, ugh, eigenvalues, vector, mklerr)

        if (mklerr /= 0) then
            write(*,*) 'Error in bloch_cgeev: ', mklerr
            stop
        end if
        write(*,*) 'Worker ', rank, ' of ', size, ' computed eigenvalues: ', eigenvalues
        write(*,*) 'deallocate a, b, vector, ugh, eigenvalues'
        deallocate(a, b, vector, ugh, eigenvalues)
        
        ! call MPI_GATHERV(eigenvalues, 5*(final-init+1), MPI_INTEGER, MPI_IN_PLACE, 0, 0, MPI_DATATYPE_NULL, 0, parentcomm, ierr)
        ! wait for the stop signal
        write(*,*) 'Worker ', rank, ' of ', size, ' is waiting for the stop signal'
        call MPI_BCAST(stop_signal, 1, MPI_LOGICAL, 0, parentcomm, ierr)
        write(*,*) 'Worker ', rank, ' of ', size, ' received', stop_signal, ierr
        if (stop_signal) exit    
    end do
    deallocate(payload)
    write(*,*) 'Worker ', rank, ' of ', size, ' is done'
    
    call MPI_Finalize(ierr)
end program worker