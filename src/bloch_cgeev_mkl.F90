subroutine bloch_cgeev(nm, ndiag, ain, v, cc, ierr)
    !input/output
    integer, intent(in) :: nm, ndiag
    integer, intent(out) :: ierr
    ! real*4, intent(in) :: ar(nm,nm), ai(nm,nm)
    complex, intent(in) :: ain(nm,nm)
    complex, intent(out) :: v(nm), cc(nm,nm)
    
    
    
    !internal
    integer lwork, LWMAX, i, j
    PARAMETER        ( LWMAX = 1000 )
    complex, allocatable :: a(:,:), w(:)
    complex, allocatable :: LV(:,:), RV(:,:)
    real, allocatable :: rwork(:)
    complex :: temp(1000)
    complex, allocatable :: work(:)
    ! real :: rwork(2*ndiag)

    external cgeev

    allocate(a(ndiag,ndiag), w(ndiag))
    allocate(LV(ndiag,ndiag), RV(ndiag,ndiag))
    allocate(rwork(2*ndiag))
    
    write(*,*)'bloch_cgeev1'




    a = ain(:ndiag,:ndiag)
    ! write(*,*)'a', a(:5,:5)
    write(*,*)'bloch_cgeev2', a(:5,:5)

    ! query the workspace size
    LWORK = -1
    CALL CGEEV( 'N', 'V', ndiag, a,ndiag, w, LV, 1,RV, ndiag, temp, LWORK, RWORK, ierr )
    lwork = INT( temp( 1 ) )
    allocate( work(lwork) )
    write(*,*)'bloch_cgeev3'
    ! compute the eigenvalues and eigenvectors
    CALL CGEEV( 'N', 'V', ndiag, a,ndiag, w, LV, 1,RV, ndiag, WORK, LWORK, RWORK, ierr )

    IF( ierr.GT.0 ) THEN
        WRITE(*,*)'The algorithm failed to compute eigenvalues.'
        STOP
    END IF

    DO i=1,ndiag
        v(i) = w(i)
        DO j=1,ndiag
            cc(i,j) = RV(i,j)
        END DO
    END DO
    

end subroutine bloch_cgeev


