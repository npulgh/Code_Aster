      SUBROUTINE PACOU1(X,FVEC,DF,WORK,EPS,VECR1,VECR2,TYPFLU,VECR3,
     +                 AMOR,MASG,VECR4,VECR5,VECI1,VG,INDIC,NBM,NMODE,N)
      IMPLICIT REAL*8 (A-H,O-Z)
C ---------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGELINE  DATE 08/03/2004   AUTEUR REZETTE C.REZETTE 
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR   
C (AT YOUR OPTION) ANY LATER VERSION.                                 
C
C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT 
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF          
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU    
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.                            
C
C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE   
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,       
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.      
C ======================================================================
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C ARGUMENTS
C ---------
      REAL*8 X(*),FVEC(*),DF(N,*),WORK(*),EPS
      REAL*8 AMOR(*),VG,MASG(*)
      REAL*8 VECR1(*),VECR2(*),VECR3(*),VECR4(*),VECR5(*)
      INTEGER VECI1(*)
      CHARACTER*8 TYPFLU
C
C ---------------------------------------------------------------------
C
      DO 12 J = 1,N
        TEMP = X(J)
        H = EPS*ABS(TEMP)
        IF (ABS(H).LE.1.0D-30) H = EPS
        X(J) = TEMP + H
        H = X(J) - TEMP
        CALL PACOUF(X,WORK,VECR1,VECR2,TYPFLU,VECR3,AMOR,MASG,VECR4,
     +              VECR5,VECI1,VG,INDIC,NBM,NMODE)
        X(J) = TEMP
        DO 11 I = 1,N
          DF(I,J) = (WORK(I)-FVEC(I))/H
   11   CONTINUE
   12 CONTINUE
C
      END
