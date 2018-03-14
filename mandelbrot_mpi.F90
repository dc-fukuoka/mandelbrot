program main
  use mpi_f08
  implicit none

  integer :: iter_max
  real(8) :: dx, dy
  real(8) :: x_min, x_max, y_min, y_max, tol
  integer :: np_i, np_j
  namelist/params/iter_max, dx, dy, x_min, x_max, y_min, y_max, tol
  namelist/mpi/np_i, np_j
  
  complex(8) :: z, c
  real(8),allocatable,dimension(:,:) :: abs_zs
  real(8) :: x, y
  integer :: iter
  integer :: i, j, imax, jmax
  real(8) :: time, t0

  integer :: iam, np
  integer :: istart, iend, jstart, jend
  integer :: imax_l, jmax_l, imax_mod, jmax_mod
  integer,dimension(2) :: idivs, coords
  logical,dimension(2) :: prds
  type(mpi_comm) :: comm_cart
  integer :: iam_cart, np_cart

  ! for derived datatype
  integer,dimension(2) :: sizes, subsizes, starts
  type(mpi_datatype) :: filetype

  character(len=16) :: out = "out"
  type(mpi_file) :: fh
  integer(kind=mpi_offset_kind) :: disp
  type(mpi_status) :: stat
  
  call mpi_init
  call mpi_comm_rank(mpi_comm_world, iam)
  call mpi_comm_size(mpi_comm_world, np)

  read(11, nml=params)
  read(11, nml=mpi)

  if (np /= np_i*np_j) then
     if (iam == 0) then
        write(6, *) "np must equal to np_i*np_j"
        write(6, *) "np_i, np_j:", np_i, np_j
     end if
     call mpi_finalize
     stop
  end if

  prds = .false.
  idivs(1) = np_i
  idivs(2) = np_j
  call mpi_cart_create(mpi_comm_world, 2, idivs, prds, .false., comm_cart)
  call mpi_comm_rank(comm_cart, iam_cart)
  call mpi_comm_size(comm_cart, np_cart)
  call mpi_cart_coords(comm_cart, iam_cart, 2, coords)

  ! global
  imax = int((x_max - x_min)/dx) + 1
  jmax = int((y_max - y_min)/dy) + 1
  if (iam == 0) then
     write(6, *) "maximum iteration:", iter_max
     write(6, *) "imax:", imax, "jmax:", jmax
  end if

  ! local indices
  ! for i
  imax_mod = mod(imax, np_i)
  imax_l = imax/np_i
  if (coords(1) < imax_mod) then
     imax_l = imax_l + 1
  end if
  
  if (coords(1) == 0) then
     istart = 1
  else if (coords(1) > 0 .and. coords(1) < imax_mod) then
     istart = coords(1)*imax_l + 1
  else
     istart = coords(1)*imax_l + imax_mod + 1
  end if
  iend   = istart + imax_l - 1
  
  ! for j
  jmax_mod = mod(jmax, np_j)
  jmax_l = jmax/np_j
  if (coords(2) < jmax_mod) then
     jmax_l = jmax_l + 1
  end if
  
  if (coords(2) == 0) then
     jstart = 1
  else if (coords(2) > 0 .and. coords(2) < jmax_mod) then
     jstart = coords(2)*jmax_l + 1
  else
     jstart = coords(2)*jmax_l + jmax_mod + 1
  end if
  jend   = jstart + jmax_l - 1

  sizes(1)    = imax
  sizes(2)    = jmax
  subsizes(1) = imax_l
  subsizes(2) = jmax_l
  starts(1)   = istart - 1
  starts(2)   = jstart - 1
    
  call mpi_type_create_subarray(2, sizes, subsizes, starts, mpi_order_fortran, mpi_real8, filetype)
  
  call mpi_type_commit(filetype)
  call mpi_file_open(mpi_comm_world, out, mpi_mode_wronly+mpi_mode_create, mpi_info_null, fh)
  disp = 0
  call mpi_file_set_view(fh, disp, mpi_real8, filetype, "native", mpi_info_null)

  allocate(abs_zs(istart:iend, jstart:jend))

  !$omp parallel
  !$omp workshare
  abs_zs = 0.0d0
  !$omp end workshare
  !$omp end parallel

  call mpi_barrier(mpi_comm_world)
  t0 = mpi_wtime()
  !$omp parallel do private(i, j, iter, x, y, c, z)
  do j = jstart, jend
     y = y_min + (j - 1)*dy
     do i = istart, iend
        x = x_min + (i - 1)*dx
        c = cmplx(x, y)
        z = (0.0d0, 0.0d0)
        do iter = 1, iter_max
           z = z**2 + c
           if (abs(z) >= tol) exit
        end do
        abs_zs(i, j) = abs(z)
     end do
  end do
  call mpi_barrier(mpi_comm_world)
  time = mpi_wtime() - t0
  if (iam == 0) write(6, *) "time[s]:", time

  call mpi_file_write_all(fh, abs_zs, imax_l*jmax_l, mpi_real8, stat)

  ! finalize
  call mpi_file_close(fh)
  call mpi_type_free(filetype)
  call mpi_comm_free(comm_cart)
  deallocate(abs_zs)
  call mpi_finalize
  stop
end program main
