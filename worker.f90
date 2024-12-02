program worker
    use MPI
    implicit none

    integer :: ierr, rank, size, parentcomm
    integer :: ntask, i, init, final, j
    integer, dimension(5) :: payload
    integer, dimension(25) :: eigenvalues

    call MPI_Init(ierr)
    call MPI_COMM_SIZE(MPI_COMM_WORLD, size, ierr)
    call MPI_COMM_RANK(MPI_COMM_WORLD, rank, ierr)
    call MPI_COMM_GET_PARENT(parentcomm, ierr)

    

    call MPI_BCAST(ntask, 1, MPI_INTEGER, 0, parentcomm, ierr)

    ! allocate(eigenvalues(5*(final-init+1)))
    call MPI_BCAST(payload, 5, MPI_INTEGER, 0, parentcomm, ierr)

    init = ntask / size * rank + 1
    final = ntask / size * (rank + 1)  
    if (rank.eq.size-1) final = ntask

    write(*,*) 'Worker ', rank, ' of ', size, ' will compute from ', init, ' to ', final
    do i = init, final
        do j = 1, 5
            eigenvalues(j + 5*(i-init)) = payload(j)*i
        end do
    end do

    call MPI_GATHERV(eigenvalues, 5*(final-init+1), MPI_INTEGER, MPI_IN_PLACE, 0, 0, MPI_DATATYPE_NULL, 0, parentcomm, ierr)
    call MPI_Finalize(ierr)
    
end program worker