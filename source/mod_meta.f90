! ================================================================================================ !
!  SixTrack Meta Data Module
!  V.K. Berglyd Olsen, BE-ABP-HSS
!  Last modified: 2018-11-15
!  Records simulation meta data in a file
! ================================================================================================ !
module mod_meta

  use floatPrecision

  implicit none

  character(len=12), parameter     :: meta_fileName = "sim_meta.dat"
  integer,           private, save :: meta_fileUnit
  logical,           public,  save :: meta_isActive = .false.

  ! Collected MetaData
  integer,           public,  save :: meta_nPartInit = 0 ! Initial number of particles
  integer,           public,  save :: meta_nPartTurn = 0 ! Counted in tracking routines

  ! Meta Write Interface
  interface meta_write
    module procedure meta_write_char
    module procedure meta_write_real32
    module procedure meta_write_real64
    module procedure meta_write_real128
    module procedure meta_write_int16
    module procedure meta_write_int32
    module procedure meta_write_int64
    module procedure meta_write_log
  end interface meta_write

  private :: meta_write_char
  private :: meta_write_real32
  private :: meta_write_real64
  private :: meta_write_real128
  private :: meta_write_int16
  private :: meta_write_int32
  private :: meta_write_int64
  private :: meta_write_log

contains

subroutine meta_initialise

  use crcoall
  use file_units

  integer ioStat

  call funit_requestUnit(meta_fileName, meta_fileUnit)
  open(meta_fileUnit,file=meta_fileName,status="replace",form="formatted",iostat=ioStat)
  if(ioStat /= 0) then
    write(lout,"(2(a,i0))") "META> ERROR Opening of '"//meta_fileName//"' on unit #",meta_fileUnit," failed with iostat = ",ioStat
    call prror(-1)
  end if

  write(meta_fileUnit,"(a)") "# SixTrack Simulation Meta Data"
  write(meta_fileUnit,"(a)") repeat("#",80)

  meta_isActive = .true.

end subroutine meta_initialise

subroutine meta_finalise

  call meta_write("NumParticleTurns", meta_nPartTurn)

  meta_isActive = .false.
  close(meta_fileUnit)

end subroutine meta_finalise

! ================================================================================================ !
!  Interface routines for writing data to sim_meta.dat
!  V.K. Berglyd Olsen, BE-ABP-HSS
!  Last modified: 2018-11-15
! ================================================================================================ !
subroutine meta_write_char(name, value, fmt)
  character(len=*),           intent(in) :: name
  character(len=*),           intent(in) :: value
  character(len=*), optional, intent(in) :: fmt
  call meta_checkActive
  if(present(fmt)) then
    write(meta_fileUnit,"(a,"//fmt//")") meta_padName(name)//" : "//value
  else
    write(meta_fileUnit,"(a)")           meta_padName(name)//" : "//value
  end if
end subroutine meta_write_char

subroutine meta_write_real32(name, value, fmt)
  use, intrinsic :: iso_fortran_env, only : real32
  character(len=*),           intent(in) :: name
  real(kind=real32),          intent(in) :: value
  character(len=*), optional, intent(in) :: fmt
  call meta_checkActive
  if(present(fmt)) then
    write(meta_fileUnit,"(a,"//fmt//")") meta_padName(name)//" : ",value
  else
    write(meta_fileUnit,"(a,es15.7e3)")  meta_padName(name)//" : ",value
  end if
end subroutine meta_write_real32

subroutine meta_write_real64(name, value, fmt)
  use, intrinsic :: iso_fortran_env, only : real64
  character(len=*),           intent(in) :: name
  real(kind=real64),          intent(in) :: value
  character(len=*), optional, intent(in) :: fmt
  call meta_checkActive
  if(present(fmt)) then
    write(meta_fileUnit,"(a,"//fmt//")") meta_padName(name)//" : ",value
  else
    write(meta_fileUnit,"(a,es24.16e3)") meta_padName(name)//" : ",value
  end if
end subroutine meta_write_real64

subroutine meta_write_real128(name, value, fmt)
  use, intrinsic :: iso_fortran_env, only : real128
  character(len=*),           intent(in) :: name
  real(kind=real128),         intent(in) :: value
  character(len=*), optional, intent(in) :: fmt
  call meta_checkActive
  if(present(fmt)) then
    write(meta_fileUnit,"(a,"//fmt//")") meta_padName(name)//" : ",value
  else
    write(meta_fileUnit,"(a,es41.33e3)") meta_padName(name)//" : ",value
  end if
end subroutine meta_write_real128

subroutine meta_write_int16(name, value, fmt)
  use, intrinsic :: iso_fortran_env, only : int16
  character(len=*),           intent(in) :: name
  integer(kind=int16),        intent(in) :: value
  character(len=*), optional, intent(in) :: fmt
  call meta_checkActive
  if(present(fmt)) then
    write(meta_fileUnit,"(a,"//fmt//")") meta_padName(name)//" : ",value
  else
    write(meta_fileUnit,"(a,i6)")        meta_padName(name)//" : ",value
  end if
end subroutine meta_write_int16

subroutine meta_write_int32(name, value, fmt)
  use, intrinsic :: iso_fortran_env, only : int32
  character(len=*),           intent(in) :: name
  integer(kind=int32),        intent(in) :: value
  character(len=*), optional, intent(in) :: fmt
  call meta_checkActive
  if(present(fmt)) then
    write(meta_fileUnit,"(a,"//fmt//")") meta_padName(name)//" : ",value
  else
    write(meta_fileUnit,"(a,i11)")       meta_padName(name)//" : ",value
  end if
end subroutine meta_write_int32

subroutine meta_write_int64(name, value, fmt)
  use, intrinsic :: iso_fortran_env, only : int64
  character(len=*),           intent(in) :: name
  integer(kind=int64),        intent(in) :: value
  character(len=*), optional, intent(in) :: fmt
  call meta_checkActive
  if(present(fmt)) then
    write(meta_fileUnit,"(a,"//fmt//")") meta_padName(name)//" : ",value
  else
    write(meta_fileUnit,"(a,i20)")       meta_padName(name)//" : ",value
  end if
end subroutine meta_write_int64

subroutine meta_write_log(name, value, fmt)
  character(len=*),           intent(in) :: name
  logical,                    intent(in) :: value
  character(len=*), optional, intent(in) :: fmt
  call meta_checkActive
  if(present(fmt)) then
    write(meta_fileUnit,"(a,"//fmt//")") meta_padName(name)//" : ",value
  else
    if(value) then
      write(meta_fileUnit,"(a)") meta_padName(name)//" : true"
    else
      write(meta_fileUnit,"(a)") meta_padName(name)//" : false"
    end if
  end if
end subroutine meta_write_log

function meta_padName(inName) result(padName)
  character(len=*), intent(in) :: inName
  character(len=32) padName
  integer i, j
  padName = " "
  j = 0
  do i=1,len(inName)
    if(ichar(inName(i:i)) <= 32 .or. ichar(inName(i:i)) >= 127) cycle
    j = j + 1
    if(j > 32) cycle
    padName(j:j) = inName(i:i)
  end do
end function meta_padName

subroutine meta_checkActive
  use crcoall
  if(meta_isActive .eqv. .false.) then
    write(lout,"(a)") "META> ERROR Trying to write meta data before initialisation or after finalisation."
    call prror(-1)
  end if
end subroutine meta_checkActive

end module mod_meta