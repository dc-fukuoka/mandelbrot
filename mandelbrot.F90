program main
  implicit none

  integer :: iter_max
  real(8) :: dx, dy
  real(8) :: x_min, x_max, y_min, y_max, tol
  namelist/params/iter_max, dx, dy, x_min, x_max, y_min, y_max, tol
  
  complex(8) :: z, c
  complex(8),allocatable,dimension(:,:) :: zs
  real(8) :: x, y
  integer :: iter
  integer :: i, j, imax, jmax
  real(8) :: time
  integer :: clk(2), clk_rate, clk_max

  read(11, nml=params)
  
  write(6, *) "maximum iteration:", iter_max

  imax = int((x_max - x_min)/dx) + 1
  jmax = int((y_max - y_min)/dy) + 1
  write(6, *) "imax:", imax, "jmax:", jmax
  allocate(zs(imax, jmax))

  call system_clock(clk(1), clk_rate, clk_max)
  !$omp parallel do private(i, j, x, y, c, z)
  do j = 1, jmax
     y = y_min + (j - 1)*dy
     do i = 1, imax
        x = x_min + (i - 1)*dx
        c = cmplx(x, y)
        z = (0.0d0, 0.0d0)
        do iter = 1, iter_max
           z = z**2 + c
           if (abs(z) >= tol) exit
        end do
        zs(i, j) = z
     end do
  end do
  call system_clock(clk(2))
  time = 1.0d0*(clk(2) - clk(1))/clk_rate
  write(6, *) "time[s]:", time

  do i = 1, imax
     x = x_min + (i - 1)*dx
     do j = 1, jmax
        y = y_min + (j - 1)*dy
        write(100, '(3(es16.5e3))') x, y, abs(zs(i, j))
     end do
     write(100, *)
  end do

  deallocate(zs)
  
  stop
end program main
