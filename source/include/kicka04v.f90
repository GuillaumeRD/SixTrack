! start include/kicka04v.f90
  mpe=4
  mx=2
  cxzr=xl
  cxzi=zl
  cxzyr=cxzr**2-cxzi**2
  cxzyi=cxzr*cxzi+cxzi*cxzr
  tiltck=tiltc(k)**2-tilts(k)**2
  tiltsk=(two*tiltc(k))*tilts(k)
  qu=(three*ekk)*(tiltck*cxzyi-tiltsk*cxzyr)
  qv=((-one*three)*ekk)*(tiltck*cxzyr+tiltsk*cxzyi)
  ab1(2)=qu
  ab2(2)=-one*qv
  cxzyrr=cxzyr*cxzr-cxzyi*cxzi
  cxzyi=cxzyr*cxzi+cxzyi*cxzr
  cxzyr=cxzyrr
  dyy1=ekk*(tiltc(k)*cxzyi-tilts(k)*cxzyr)
  dyy2=ekk*(tiltc(k)*cxzyr+tilts(k)*cxzyi)
  tiltckuk=tiltck*tiltc(k)-tiltsk*tilts(k)
  tiltsk=tiltck*tilts(k)+tiltsk*tiltc(k)
  tiltck=tiltckuk
  ab1(3)=(three*ekk)*(tiltck*zl-tiltsk*xl)
  ab2(3)=(three*ekk)*(tiltck*xl+tiltsk*zl)
  tiltckuk=tiltck*tiltc(k)-tiltsk*tilts(k)
  tiltsk=tiltck*tilts(k)+tiltsk*tiltc(k)
  tiltck=tiltckuk
  ab1(4)=ekk*tiltsk
  ab2(4)=ekk*tiltck
! end include/kicka04v.f90
