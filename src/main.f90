subroutine main(niter, workdir)
    use MPI
    use mpiinfo
    implicit none

    integer :: ierr
    integer :: i, niter
    !f2py intent(in) :: niter
    character(len=256) :: workdir
    !f2py intent(in) :: workdir

    write(*,*) 'workdir = ', workdir
    call MPI_Init(ierr)
    do i = 1,niter
        write(*,*) 'Iteration ', i, 'started'
        call manager(2, 10, workdir)
        write(*,*) 'Iteration ', i, 'ended'        
    end do
    write(*,*) 'Main is done'
    call mpiinfo_despawn()
    call MPI_Finalize(ierr)    
end subroutine main


subroutine manager(nprocs, ntasks, workdir)
    use MPI
    use mpiinfo
    implicit none
    integer, intent(in) :: nprocs, ntasks
    integer :: i
    integer :: ierr
    integer, dimension(4) :: errcodes
    integer, dimension(:), allocatable :: counts, displs, payload, recvbuf
    character(len=256) :: workdir
    
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
    if (first) then
        write(*,*) 'Manager is spawning workers'
        call MPI_COMM_SPAWN(workdir, MPI_ARGV_NULL, nprocs, MPI_INFO_NULL, 0, MPI_COMM_WORLD, intercomm, errcodes, ierr)
        first = .false.
    else
        write(*,*) 'send signal to workers'
        call MPI_BCAST(.false., 1, MPI_LOGICAL, MPI_ROOT, intercomm, ierr)
    end if

    call MPI_BCAST(ntasks, 1, MPI_INTEGER, MPI_ROOT, intercomm, ierr)
    call MPI_BCAST(payload, 5, MPI_INTEGER, MPI_ROOT, intercomm, ierr)    

    allocate(recvbuf(5*ntasks))
    
    call MPI_GATHERV(MPI_IN_PLACE,0,MPI_DATATYPE_NULL,recvbuf,counts*5,displs*5,MPI_INTEGER,MPI_ROOT,intercomm,ierr)
    ! print *, recvbuf
    deallocate(counts, displs, payload, recvbuf)
    return    
end subroutine manager

