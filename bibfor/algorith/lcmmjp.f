      SUBROUTINE LCMMJP (MOD, NMAT, MATER, TIMED, TIMEF, COMP,
     &                   NBCOMM, CPMONO, PGL,NFS,NSG,TOUTMS,HSR,NR,NVI,
     &                   ITMAX,TOLER,VINF,VIND,
     &                   DSDE , DRDY, OPTION, IRET)
      IMPLICIT NONE
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 19/12/2012   AUTEUR PELLET J.PELLET 
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
C RESPONSABLE PROIX J.M.PROIX
C TOLE CRP_21 CRS_1404
C     ----------------------------------------------------------------
C     COMPORTEMENT MONOCRISTALLIN
C                :  MATRICE SYMETRIQUE DE COMPORTEMENT TANGENT
C                   COHERENT A T+DT? en hpp et gdef
C     ----------------------------------------------------------------
C     IN  MOD    :  TYPE DE MODELISATION
C         NMAT   :  DIMENSION MATER
C         MATER  :  COEFFICIENTS MATERIAU
C         TIMED  :  ISTANT PRECEDENT
C         TIMEF  :  INSTANT ACTUEL
C         COMP   :  NOM COMPORTEMENT
C         NBCOMM :  INCIDES DES COEF MATERIAU
C         CPMONO :  NOM DES COMPORTEMENTS
C         PGL    :  MATRICE DE PASSAGE
C         TOUTMS :  TENSEURS D'ORIENTATION
C         HSR    :  MATRICE D'INTERACTION
C         NVI    :  NOMBRE DE VARIABLES INTERNES
C         NR     :  DIMENSION DU SYSTEME A RESOUDRE
C         ITMAX  :  ITER_INTE_MAXI
C         TOLER  :  RESI_INTE_RELA
C         VIND   :  VARIABLES INTERNES A L'INSTANT PRECEDENT T
C         VINF   :  VARIABLES INTERNES A T+DT
C         DRDY   :  MATRICE JACOBIENNE
C         OPTION :  OPTION DE CALCUL MATRICE TANGENTE
C     OUT DSDE   :  MATRICE DE COMPORTEMENT TANGENT = DSIG/DEPS
C                   DSDE = INVERSE(Y0-Y1*INVERSE(Y3)*Y2)
C         IRET   :  CODE RETOUR
C     ----------------------------------------------------------------
      INTEGER NDT , NDI , NMAT , NVI, ITMAX, NFS, NSG
      INTEGER K,J,NR, IRET,NS,NBCOMM(NMAT,3)
C DIMENSIONNEMENT DYNAMIQUE
      REAL*8 DRDY(NR,NR),DSDE(6,*),KYL(6,6),DET,I6(6,6),ZINV(6,6)
      REAL*8 TOLER,MATER(*),YF(NR),DY(NR),UN,ZERO,TIMED,TIMEF,PGL(3,3)
      REAL*8 Z0(6,6),Z1(6,(NR-NDT))
      REAL*8 Z2((NR-NDT),6),Z3((NR-NDT),(NR-NDT))
      REAL*8 TOUTMS(NFS,NSG,6),HSR(NSG,NSG)
      REAL*8 VIND(*),VINF(*),DF(9),YD(NR)
      CHARACTER*8     MOD
      CHARACTER*16    COMP(*), OPTION
      CHARACTER*24    CPMONO(5*NMAT+1)
      PARAMETER       ( UN   =  1.D0   )
      PARAMETER       ( ZERO =  0.D0   )
      COMMON /TDIM/ NDT,NDI
      INTEGER IRR,DECIRR,NBSYST,DECAL,GDEF
      COMMON/POLYCR/IRR,DECIRR,NBSYST,DECAL,GDEF
      DATA  I6        /UN     , ZERO  , ZERO  , ZERO  ,ZERO  ,ZERO,
     1                 ZERO   , UN    , ZERO  , ZERO  ,ZERO  ,ZERO,
     2                 ZERO   , ZERO  , UN    , ZERO  ,ZERO  ,ZERO,
     3                 ZERO   , ZERO  , ZERO  , UN    ,ZERO  ,ZERO,
     4                 ZERO   , ZERO  , ZERO  , ZERO  ,UN    ,ZERO,
     5                 ZERO   , ZERO  , ZERO  , ZERO  ,ZERO  ,UN/

C -  INITIALISATION

      NS=NR-NDT
      IRET=0

C     RECALCUL DE LA DERNIERE MATRICE JACOBIENNE
      IF (OPTION.EQ. 'RIGI_MECA_TANG') THEN
          CALL R8INIR(NR,0.D0, DY, 1)
          CALL R8INIR(9,0.D0, DF, 1)
          CALL R8INIR(NR,0.D0, YF, 1)
          CALL R8INIR(NR,0.D0, YD, 1)
          CALL R8INIR(NVI,0.D0, VIND, 1)
          CALL LCMMJA (COMP,MOD, NMAT, MATER, TIMED, TIMEF,
     &      ITMAX,TOLER,NBCOMM, CPMONO, PGL,NFS,NSG,TOUTMS,HSR,
     &      NR,NVI,VIND,DF,YF,YD,DY,DRDY, IRET)
          IF (IRET.GT.0) GOTO 9999
      ENDIF

C - RECUPERER LES SOUS-MATRICES BLOC

      DO 101 K=1,6
      DO 101 J=1,6
         Z0(K,J)=DRDY(K,J)
 101   CONTINUE
      DO 201 K=1,6
      DO 201 J=1,NS
         Z1(K,J)=DRDY(K,NDT+J)
 201   CONTINUE

      DO 301 K=1,NS
      DO 301 J=1,6
         Z2(K,J)=DRDY(NDT+K,J)
 301   CONTINUE
      DO 401 K=1,NS
      DO 401 J=1,NS
         Z3(K,J)=DRDY(NDT+K,NDT+J)
 401   CONTINUE
C     Z2=INVERSE(Z3)*Z2
C     CALL MGAUSS ('NCSP',Z3, Z2, NS, NS, 6, DET, IRET )
      CALL MGAUSS ('NCWP',Z3, Z2, NS, NS, 6, DET, IRET )
      IF (IRET.GT.0) GOTO 9999

C     KYL=Z1*INVERSE(Z3)*Z2
      CALL PROMAT(Z1,6,6,NS,Z2,NS,NS,6,KYL)

C     Z0=Z0+Z1*INVERSE(Z3)*Z2
      DO 501 K=1,6
      DO 501 J=1,6
         Z0(K,J)=Z0(K,J)-KYL(K,J)
 501  CONTINUE
 
      CALL DCOPY(36,I6,1,ZINV,1)
C     CALL MGAUSS ('NCSP',Z0, ZINV, 6, 6, 6, DET, IRET )
      CALL MGAUSS ('NCWP',Z0, ZINV, 6, 6, 6, DET, IRET )
      IF (IRET.GT.0) GOTO 9999
      
      IF (GDEF.EQ.0) THEN
      
C        DSDE = INVERSE(Z0-Z1*INVERSE(Z3)*Z2)

         CALL DCOPY(36,ZINV,1,DSDE,1)
         
      ELSE
      
         CALL LCMMKG(ZINV,NVI,VIND,VINF,NMAT,MATER,MOD,NR,DSDE)
      
      ENDIF
 9999 CONTINUE       
      END
