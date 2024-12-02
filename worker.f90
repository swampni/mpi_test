program worker
    use MPI
    implicit none

    integer :: ierr, rank, size
    integer :: ntask, i

    call MPI_Init(ierr)
    call MPI_COMM_SIZE(MPI_COMM_WORLD, size, ierr)
    call MPI_COMM_RANK(MPI_COMM_WORLD, rank, ierr)

    call MPI_COMM_GET_PARENT(intercomm, ierr)
    call MPI_BCAST(ntask, 1, MPI_INTEGER, MPI_ROOT, intercomm, ierr)

    init = ntask / size * rank + 1
    final = ntask / size * (rank + 1)  
    if (rank.eq.size-1) final = ntask

    do i = init, final
        print *, 'Task ', i
    end do

    

    call MPI_Finalize(ierr)
    
end program worker