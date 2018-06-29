!strack=zero
!strackx=ed(IX)
!strackz=ek(IX)

!Going to momenum and psigma


!FOX  PUSIG=((EJ1-E0)/(E0F*(E0F/E0))) ;

!FOX  TEMPI(1) = X(1) ;
!FOX  TEMPI(2) = Y(1) ;
!FOX  TEMPI(3) = X(2) ;
!FOX  TEMPI(4) = Y(2) ;
!FOX  TEMPI(5) = SIGMDA ;
!FOX  TEMPI(6) = PUSIG ;


!Full 6d-formula 

!FOX  ONEDPDA   = (ONE + DPDA)/MTCDA  ;
!FOX  FPPSIGDA  = ( ONE + ((E0F/E0)*(E0F/E0))*TEMPI(6) ) / ONEDPDA ;

!     Set up C,S, Q_DA,R_DA,Z
!FOX  COSTH_DA = COS(EK(IX)/ONEDPDA) ;
!FOX  SINTH_DA = SIN(EK(IX)/ONEDPDA) ;

!FOX  Q_DA = -EK(IX) * ED(IX) / ONEDPDA ;
!FOX  R_DA = FPPSIGDA / (ONEDPDA*ONEDPDA) * EK(IX) * ED(IX) ;
!FOX  Z_DA = FPPSIGDA / (ONEDPDA*ONEDPDA) * EK(IX) ;

!FOX  PXFDA  = TEMPI(2)*ONEDPDA + TEMPI(1)*Q_DA ;
!FOX  PYFDA  = TEMPI(4)*ONEDPDA + TEMPI(3) *Q_DA ;
!FOX  SIGFDA = TEMPI(5) - (ONE/TWO)*(TEMPI(1)*TEMPI(1) +  TEMPI(3) *TEMPI(3))*R_DA*C1M3 ;


!       R_DAipken formulae p.29 (3.37)
!FOX  X(1) =  (TEMPI(1)  * COSTH_DA  +  TEMPI(3)  * SINTH_DA) ;
!FOX  Y(1) =  ((TEMPI(2) + (TEMPI(1)*Q_DA/ONEDPDA)) * COSTH_DA  
!FOX  +  (TEMPI(4) +  (TEMPI(3) *Q_DA/ONEDPDA)) * SINTH_DA) ;
!FOX  X(2) = (-TEMPI(1)  * SINTH_DA  +  TEMPI(3)  * COSTH_DA) ;
!FOX  Y(2) = (-(TEMPI(2) + (TEMPI(1)*Q_DA/ONEDPDA)) * SINTH_DA 
!FOX  +  (TEMPI(4) +  (TEMPI(3) *Q_DA/ONEDPDA)) * COSTH_DA) ;

!FOX  SIGMDA =  (SIGFDA + (TEMPI(1)*PYFDA - TEMPI(3)*PXFDA)*Z_DA*C1M3) ;
	