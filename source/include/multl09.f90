!start multl09.f90
#ifndef TILT
  t(6,2)=t(6,2)-dppi/(one+dpp)
#else
  t(6,2)=(t(6,2)-(dppi/(one+dpp))*tiltc(k))-(dppi/(one+dpp))*(one-tiltc(k))
  t(6,4)=(t(6,4)-(dppi/(one+dpp))*tilts(k))-(dppi/(one+dpp))*tilts(k)
#endif
!end multl09.f90
