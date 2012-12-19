      SUBROUTINE LCJACP(FAMI,KPG,KSP,LOI,TOLER,ITMAX,MOD,IMAT,
     &                    NMAT,MATERD,MATERF,NR,NVI,
     &                    TIMED,TIMEF, DEPS,EPSD,VIND,VINF,YD,
     &                    COMP,NBCOMM,CPMONO,PGL,NFS,NSG,TOUTMS,HSR,
     &                    DY,R,DRDY,VERJAC,DRDYB,IRET,CRIT)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF DEBUG  DATE 19/12/2012   AUTEUR PELLET J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
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
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C TOLE CRP_21 CRS_1404
C     CONSTRUCTION DE LA MATRICE JACOBIENNE PAR PERTURBATION
C     IN  FAMI   :  FAMILLE DE POINT DE GAUSS
C         KPG    :  NUMERO DU POINT DE GAUSS
C         KSP    :  NUMERO DU SOUS-POINT DE GAUSS
C         LOI    :  MODELE DE COMPORTEMENT
C         TOLER  :  TOLERANCE DE CONVERGENCE LOCALE
C         ITMAX  :  NOMBRE MAXI D'ITERATIONS LOCALES
C         MOD    :  TYPE DE MODELISATION
C         IMAT   :  ADRESSE DU MATERIAU CODE
C         NMAT   :  DIMENSION MATER
C         MATERD :  COEFFICIENTS MATERIAU A T
C         MATERF :  COEFFICIENTS MATERIAU A T+DT
C         NR     :  NB EQUATION DU SYSTEME R(DY)
C         NVI    :  NB VARIABLES INTERNES
C         TIMED  :  INSTANT  T
C         TIMEF  :  INSTANT T+DT
C     VAR DEPS   :  INCREMENT DE DEFORMATION
C     IN  EPSD   :  DEFORMATION A T
C         SIGD   :  CONTRAINTE A T
C         VIND   :  VARIABLES INTERNES A T
C         VINF   :  VARIABLES INTERNES A T+DT
C         YD     :  VARIABLES A T   = ( SIGD  VIND  (EPSD3)   )
C         COMP   :  COMPORTEMENT
C         DY     :  INCREMENT DES VARIABLES = ( DSIG  DVIN  (DEPS3)  )
C         R      :  VECTEUR RESIDU
C         DRDY   :  JACOBIEN
C
C         VERJAC : =0 : PAS DE VERIFICATION
C         =1 : CONSTRUCTION DE LA JACOBIENNE PAR PERTURBATION (LCJACP)
C                COMPARAISON A LA MATRICE JACOBIENNE ISSU DE LCJACB
C         =2 : UTILISATION DE LA JACOBIENNE PAR PERTURBATION (LCJACP)
C                COMME MATRICE JACOBIENNE A LA PLACE DE LCJACB
C     OUT DRDYB  : MATRICE JACOBIENNE PAR PERTURBATION
C ----------------------------------------------------------------------
      IMPLICIT NONE

      INTEGER NMAT,NBCOMM(NMAT,3),NR,IMPR,VALI(2),NFS,NSG
      INTEGER IMAT,I,J,ITMAX,IRET,KPG,KSP,NVI,VERJAC

      REAL*8 TOLER,EPSD(6),DEPS(6),VIND(NVI),VINF(NVI),TIMED,TIMEF,ERR

C     DIMENSIONNEMENT DYNAMIQUE (MERCI F90)
      REAL*8 DY(NR),R(NR),DRDYB(NR,NR),RINI(NR),DYINI(NR),RP(NR),RM(NR)
      REAL*8 DRDY(NR,NR),YD(NR),DYM(NR),DYP(NR),YFP(NR),YFM(NR)

      REAL*8 MATERD(NMAT,2),MATERF(NMAT,2),PGL(3,3),EPS1,EPS2,EPS0
      REAL*8 TOUTMS(NFS,NSG,6),HSR(NSG,NSG),CRIT(*)
      REAL*8 VALR(4),R8MIEM,MAXTGT,NORMD1,NORMD2,MAXERR

      CHARACTER*8     MOD
      CHARACTER*16    LOI,COMP(*)
      CHARACTER*24    CPMONO(5*NMAT+1)
      CHARACTER*(*)   FAMI
      DATA IMPR/0/
C ----------------------------------------------------------------------
      CALL LCEQVN(NR,DY,DYINI)
      CALL LCEQVN(NR,R,RINI)
      MAXTGT=0.D0
      NORMD1=0.D0
      NORMD2=0.D0

      DO 1002 I=1,6
        NORMD1=NORMD1+DYINI(I)*DYINI(I)
 1002 CONTINUE

      DO 1003 I=7,NR
        NORMD2=NORMD2+DYINI(I)*DYINI(I)
 1003 CONTINUE
 
      IF (NORMD1.LT.R8MIEM()) THEN
         DO 1007 I=1,6
            NORMD1=NORMD1+YD(I)*YD(I)
 1007    CONTINUE      
      ENDIF
      IF (NORMD2.LT.R8MIEM()) THEN
         DO 1008 I=7,NR
            NORMD2=NORMD2+YD(I)*YD(I)
 1008    CONTINUE
      ENDIF

      EPS0=1.D-7
      EPS1=EPS0
      EPS2=EPS0
      IF (NORMD1.GT.R8MIEM()) THEN      
         EPS1=EPS1*SQRT(NORMD1)
      ENDIF
      IF (NORMD2.GT.R8MIEM()) THEN
         EPS2=EPS2*SQRT(NORMD2)
      ENDIF

      DO 1004 I=1,NR
         CALL LCEQVN(NR,DYINI,DYP)
         IF (I.LE.6) THEN
         DYP(I)=DYP(I)+EPS1
         ELSE
         DYP(I)=DYP(I)+EPS2
         ENDIF
         CALL LCSOVN ( NR , YD , DYP , YFP )
         CALL LCRESI ( FAMI,KPG,KSP,LOI,MOD,IMAT,NMAT,MATERD,MATERF,
     &           COMP,NBCOMM,CPMONO,PGL,NFS,NSG,TOUTMS,HSR,NR,NVI,VIND,
     &           VINF,ITMAX, TOLER,TIMED,TIMEF,YD,YFP,DEPS,EPSD,DYP,RP,
     &              IRET ,CRIT)
         IF (IRET.GT.0) THEN
            GOTO 9999
         ENDIF
         CALL LCEQVN(NR,DYINI,DYM)
         IF (I.LE.6) THEN
         DYM(I)=DYM(I)-EPS1
         ELSE
         DYM(I)=DYM(I)-EPS2
         ENDIF
         CALL LCSOVN ( NR , YD , DYM , YFM )
         CALL LCRESI ( FAMI,KPG,KSP,LOI,MOD,IMAT,NMAT,MATERD,MATERF,
     &           COMP,NBCOMM,CPMONO,PGL,NFS,NSG,TOUTMS,HSR,NR,NVI,VIND,
     &           VINF,ITMAX, TOLER,TIMED,TIMEF,YD,YFM,DEPS,EPSD,DYM,RM,
     &              IRET ,CRIT)
         IF (IRET.GT.0) THEN
            GOTO 9999
         ENDIF
C        SIGNE - CAR LCRESI CALCULE -R
         DO 1005 J=1,NR
            IF (I.LE.6) THEN
               DRDYB(J,I)=-(RP(J)-RM(J))/2.D0/EPS1
            ELSE
               DRDYB(J,I)=-(RP(J)-RM(J))/2.D0/EPS2
            ENDIF
 1005    CONTINUE
 1004 CONTINUE

C COMPARAISON DRDY ET DRDYB

      MAXERR=0.D0
      ERR=0.D0
      IF ((VERJAC.EQ.1).AND.(IMPR.EQ.0)) THEN
         DO 1001 I=1,NR
         DO 1001 J=1,NR
           IF(ABS(DRDY(I,J)).GT.MAXTGT) THEN
              MAXTGT=ABS(DRDY(I,J))
           ENDIF
 1001    CONTINUE
         DO 1006 I=1,NR
         DO 1006 J=1,NR
           IF(ABS(DRDY(I,J)).GT.(1.D-9*MAXTGT)) THEN
           IF(ABS(DRDYB(I,J)).GT.(1.D-9*MAXTGT)) THEN
              ERR=ABS(DRDY(I,J)-DRDYB(I,J))/DRDYB(I,J)
           IF (ERR.GT.1.D-3) THEN
              VALI(1) = I
              VALI(2) = J

              VALR(1) = TIMEF
              VALR(2) = ERR
              VALR(3) = DRDYB(I,J)
              VALR(4) = DRDY(I,J)
              CALL U2MESG('I', 'DEBUG_1',0,' ',2,VALI,4,VALR)
              MAXERR=MAX(MAXERR,ABS(ERR))
              IMPR=1
           ENDIF
           ENDIF
           ENDIF
 1006    CONTINUE
      ENDIF

C     UTILISATION DE DRDYB COMME MATRICE JACOBIENNE
      IF (VERJAC.EQ.2) THEN
         CALL LCEQVN(NR*NR,DRDYB,DRDY)
      ENDIF

 9999 CONTINUE
      END
