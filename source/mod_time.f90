! ================================================================================================ !
!  SixTrack Time Data Module
!  V.K. Berglyd Olsen, BE-ABP-HSS
!  Last modified: 2018-11-15
!  Records simulation times
! ================================================================================================ !
module mod_time

  use floatPrecision

  implicit none

  character(len=12), parameter     :: time_fileName = "sim_time.dat"
  integer,           private, save :: time_fileUnit

  ! Constants for determining timer checkpoints
  integer, parameter :: time_afterFileUnits      = 1
  integer, parameter :: time_afterDaten          = 2
  integer, parameter :: time_afterCRCheck        = 3
  integer, parameter :: time_afterClosedOrbit    = 4
  integer, parameter :: time_afterBeamDist       = 5
  integer, parameter :: time_afterInitialisation = 6
  integer, parameter :: time_afterPreTrack       = 7
  integer, parameter :: time_afterTracking       = 8
  integer, parameter :: time_afterPostTrack      = 9
  integer, parameter :: time_afterPostProcessing = 10
  integer, parameter :: time_afterFMA            = 11
  integer, parameter :: time_afterZIPF           = 12
  integer, parameter :: time_beforeExit          = 13

  real(kind=fPrec), public,  save :: time_timeZero = 0.0
  real(kind=fPrec), public,  save :: time_timeRecord(time_beforeExit)

  ! Constants for accumulated time
  integer, parameter :: time_clockDUMP = 1
  integer, parameter :: time_clockCOLL = 2
  integer, parameter :: time_clockSCAT = 3

  real(kind=fPrec), public,  save :: time_clockStart(3)
  real(kind=fPrec), public,  save :: time_clockTotal(3)
  integer,          public,  save :: time_clockCount(3)
  integer,          public,  save :: time_clockStops(3)

  real,             private, save :: time_timerRef     = 0.0
  logical,          private, save :: time_timerStarted = .false.

contains

subroutine time_initialise

  use crcoall
  use file_units

  integer ioStat

  call cpu_time(time_timeZero)

  call funit_requestUnit(time_fileName, time_fileUnit)
  open(time_fileUnit,file=time_fileName,status="replace",form="formatted",iostat=ioStat)
  if(ioStat /= 0) then
    write(lout,"(2(a,i0))") "TIME> ERROR Opening of '"//time_fileName//"' on unit #",time_fileUnit," failed with iostat = ",ioStat
    call prror(-1)
  end if

  write(time_fileUnit,"(a)") "# SixTrack Simulation Time Data"
  write(time_fileUnit,"(a)") repeat("#",80)

  call time_writeReal("Internal_ZeroTime",time_timeZero,"sec")

  time_timeRecord(:) = 0.0
  time_clockStart(:) = 0.0
  time_clockTotal(:) = 0.0
  time_clockCount(:) = 0
  time_clockStops(:) = 0

end subroutine time_initialise

subroutine time_finalise

  use mod_meta
  use mod_common, only : numl, mbloz

  real(kind=fPrec) trackTime, nP, nT, nE, nPT, nPTE

  ! Tracking Averages

  trackTime = time_timeRecord(time_afterTracking) - time_timeRecord(time_afterPreTrack)

  nT   = real(numl,fPrec)
  nE   = real(mbloz,fPrec)
  nPT  = real(meta_nPartTurn,fPrec)
  nP   = nPT/nT
  nPTE = nPT*nE

  call time_writeReal("Sum_Tracking",                     trackTime,      "sec")
  call time_writeReal("Avg_PerParticle",            1.0e3*trackTime/nP,   "msec")
  call time_writeReal("Avg_PerTurn",                1.0e3*trackTime/nT,   "msec")
  call time_writeReal("Avg_PerElement",             1.0e3*trackTime/nE,   "msec")
  call time_writeReal("Avg_PerParticleTurn",        1.0e6*trackTime/nPT,  "usec")
  call time_writeReal("Avg_PerParticleTurnElement", 1.0e9*trackTime/nPTE, "nsec")

  ! Timer Reports

  call time_writeReal("Cost_DumpModule",        time_clockTotal(time_clockDUMP), "sec", time_clockCount(time_clockDUMP))
  call time_writeReal("Cost_CollimationModule", time_clockTotal(time_clockCOLL), "sec", time_clockCount(time_clockCOLL))
  call time_writeReal("Cost_ScatterModule",     time_clockTotal(time_clockSCAT), "sec", time_clockCount(time_clockSCAT))

  close(time_fileUnit)

end subroutine time_finalise

subroutine time_timeStamp(timeStamp)

  integer, intent(in) :: timeStamp

  real(kind=fPrec) timeValue

  call cpu_time(timeValue)
  timeValue = timeValue - time_timeZero
  time_timeRecord(timeStamp) = timeValue

  select case(timeStamp)
  case(time_afterFileUnits)
    call time_writeReal("Stamp_AfterFileUnits",      timeValue, "sec")
  case(time_afterDaten)
    call time_writeReal("Stamp_AfterDaten",          timeValue, "sec")
  case(time_afterCRCheck)
    call time_writeReal("Stamp_AfterCRCheck",        timeValue, "sec")
  case(time_afterClosedOrbit)
    call time_writeReal("Stamp_AfterClosedOrbit",    timeValue, "sec")
  case(time_afterBeamDist)
    call time_writeReal("Stamp_AfterBeamDist",       timeValue, "sec")
  case(time_afterInitialisation)
    call time_writeReal("Stamp_AfterInitialisation", timeValue, "sec")
  case(time_afterPreTrack)
    call time_writeReal("Stamp_AfterPreTrack",       timeValue, "sec")
  case(time_afterTracking)
    call time_writeReal("Stamp_AfterTracking",       timeValue, "sec")
  case(time_afterPostTrack)
    call time_writeReal("Stamp_AfterPostTrack",      timeValue, "sec")
  case(time_afterPostProcessing)
    call time_writeReal("Stamp_AfterPostProcessing", timeValue, "sec")
  case(time_afterFMA)
    call time_writeReal("Stamp_AfterFMA",            timeValue, "sec")
  case(time_afterZIPF)
    call time_writeReal("Stamp_AfterZIPF",           timeValue, "sec")
  case(time_beforeExit)
    call time_writeReal("Stamp_BeforeExit",          timeValue, "sec")
  end select

end subroutine time_timeStamp

subroutine time_startClock(timerNo)
  integer, intent(in) :: timerNo
  time_clockCount(timerNo) = time_clockCount(timerNo) + 1
  call cpu_time(time_clockStart(timerNo))
end subroutine time_startClock

subroutine time_stopClock(timerNo)
  use crcoall
  integer, intent(in) :: timerNo
  real(kind=fPrec) currTime
  call cpu_time(currTime)
  time_clockStops(timerNo) = time_clockStops(timerNo) + 1
  time_clockTotal(timerNo) = time_clockTotal(timerNo) + currTime - time_clockStart(timerNo)
end subroutine time_stopClock

subroutine time_writeReal(timeLabel, timeValue, timeUnit, dataCount)

  character(len=*),  intent(in) :: timeLabel
  real(kind=fPrec),  intent(in) :: timeValue
  character(len=*),  intent(in) :: timeUnit
  integer, optional, intent(in) :: dataCount

  character(len=40) :: endText
  integer iLen

  if(present(dataCount)) then
    iLen = len_trim(timeUnit)
    write(endText,"(a,i0,a)") " "//trim(timeUnit)//repeat(" ",6-iLen)//"[N = ",dataCount,"]"
  else
    endText = " "//timeUnit
  end if

  iLen = len_trim(timeLabel)
  if(iLen > 32) then
    write(time_fileUnit,"(a,f14.6,a)") timeLabel(1:32)//" : ",timeValue,trim(endText)
  else
    write(time_fileUnit,"(a,f14.6,a)") trim(timeLabel)//repeat(" ",32-iLen)//" : ",timeValue,trim(endText)
  end if

end subroutine time_writeReal

! ================================================================================================ !
!  Old timing routines from sixtrack.f90, moved and leaned up.
!  Last modified: 2018-11-15
! ================================================================================================ !
subroutine time_timerStart
  if(time_timerStarted) return
  time_timerStarted = .true.
  call cpu_time(time_timerRef)
end subroutine time_timerStart

subroutine time_timerCheck(timeValue)
  real, intent(inout) :: timeValue
  real currTime
  call time_timerStart
  call cpu_time(currTime)
  timeValue = currTime - time_timerRef
end subroutine time_timerCheck

end module mod_time