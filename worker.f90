program worker
    use MPI
    implicit none

    integer :: ierr, rank, size, parentcomm
    integer :: ntask, i, init, final

    call MPI_Init(ierr)
    call MPI_COMM_SIZE(MPI_COMM_WORLD, size, ierr)
    call MPI_COMM_RANK(MPI_COMM_WORLD, rank, ierr)
    write(*,*) 'Worker ', rank, ' of ', size
    call MPI_COMM_GET_PARENT(parentcomm, ierr)

    

    call MPI_BCAST(ntask, 1, MPI_INTEGER, 0, parentcomm, ierr)

    init = ntask / size * rank + 1
    final = ntask / size * (rank + 1)  
    if (rank.eq.size-1) final = ntask

    do i = init, final
        print *, 'Task ', i
    end do

    

    call MPI_Finalize(ierr)
    
end program worker