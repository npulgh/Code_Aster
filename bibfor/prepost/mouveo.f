      SUBROUTINE MOUVEO ( ARETE, RCARTE, ANGDEB, ANGFIN, ANGARE,
     &                    ANGMAX, PROFON, VOLUME, EPAIS )
      IMPLICIT   NONE
      REAL*8              ARETE, RCARTE, ANGDEB, ANGFIN, ANGARE,
     &                    ANGMAX, PROFON, VOLUME, EPAIS
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 19/06/2007   AUTEUR LEBOUVIER F.LEBOUVIER 
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
C TOLE CRP_6
C-----------------------------------------------------------------------
      REAL*8   DELTA, TAU, ANG1, ANG2,AUXI,ANCIEN,THETA0,COTETA
      REAL*8   BANGF,XANDEB,YANDEB,TATETA,XHAUT,YHAUT,DISHX,DISHY
      REAL*8   HAUT,BASEX,BASEY,BASE,BANGM,R,SURFAC,SURF
      REAL*8   THETA1, THETA2, THETA3, FONC1, FONC2, FONC3
      REAL*8   A1, A2, A3, A, D,EPSI,XPROF,YPROF,XANGM,YANGM
      REAL*8   RAD, R8DGRD, DEG, R8RDDG
      REAL*8 VALR(2)
      INTEGER  I, K, IFM, NIV
      INTEGER VALI
C-----------------------------------------------------------------------
      CALL INFNIV ( IFM, NIV )
C
      RAD = R8DGRD( )
      DEG = R8RDDG( )
      AUXI=0.D0
      R= RCARTE
      D = RCARTE * SIN(ARETE*RAD)
      ANGMAX = ANGARE*RAD
      ANCIEN= 80.D0*RAD
      THETA0= 70.D0*RAD
      IF (ANGARE.GT.270.D0) THEN
        ANGMAX=(360.D0-ANGARE)*RAD
      ELSEIF (ANGARE.GT.180.D0) THEN
        ANGMAX=(ANGARE-180.D0)*RAD
      ELSEIF (ANGARE.GT.90.D0) THEN
        ANGMAX=(180.D0-ANGARE)*RAD
      ENDIF
      ANG2=THETA0
      COTETA=COS(THETA0)/(SIN(THETA0))
      SURFAC=VOLUME/EPAIS
      K=0
      EPSI=1.D-06
      I=1
C
C*********************************************************
C      RESOLUTION DE L'EQUATION S*E=V_USE
C      ON PROCEDE PAR DICHOTOMIE
C      ON PREND LA TANGENTE A L OBSTACLE EN THETA0
C      ON CALCULE LA SURFACE USEE ENTRE THETA0 ET L ANGLE
C      FORME PAR L INTERSECTION DE LA TGTE ET DE L ENCOCHE
C      ON MODIFIE L ANGLE FIN EN FONCTION DES RESULTATS
C*********************************************************
C
 50   CONTINUE

      BANGF = RCARTE*(SIN(ANG2)+COTETA*COS(ANG2))
C
C --- CALCUL DE L ANGLE DEBUT
      XANDEB = SIN(THETA0)*(BANGF-D)/COS(THETA0)
      YANDEB = D
      ANG1   = ATAN(YANDEB/XANDEB)*DEG
C
C --- CALCUL DE LA HAUTEUR
      TATETA = SIN(THETA0)/COS(THETA0)
      BANGM  = R*(SIN(ANGMAX)-TATETA*COS(ANGMAX))
C
      XHAUT = (BANGF-BANGM)*COS(THETA0)*SIN(THETA0)
      YHAUT = TATETA*XHAUT+BANGM
C
      DISHX = (R*COS(ANGMAX)-XHAUT)**2
      DISHY = (R*SIN(ANGMAX)-YHAUT)**2
      HAUT  = SQRT(DISHX+DISHY)
C
C --- CALCUL DE LA BASE
      BASEX = (R*COS(ANG2)-XANDEB)**2
      BASEY = (R*SIN(ANG2)-YANDEB)**2
C
      BASE = SQRT(BASEX+BASEY)
C
C --- CALCUL DE LA SURFACE USEE
      SURF = (BASE*HAUT)/2
C
C --- ON TESTE LA SURFACE CALCULEE AVEC LA SURFACE USEE DONNEE
      IF ((ABS(SURF-SURFAC)/SURFAC).LT.EPSI)  GOTO 70
C
C --- DICHOTOMIE ET ON REPART
      IF (SURF.LT.SURFAC) THEN
         K=K+1
         AUXI=ANG2
         ANG2=(ANG2+ANCIEN)/2
         IF (K.EQ.I) THEN
            THETA0=ANG2
            COTETA=COS(THETA0)/(SIN(THETA0))
         ENDIF
      ELSE 
         IF (AUXI.NE.0.D0) THEN
            ANCIEN=ANG2
            ANG2=(ANG2+AUXI)/2
         ELSE 
            ANCIEN=ANG2
            ANG2=(ANG2+ANGMAX)/2
         ENDIF
      ENDIF
      I=I+1
C
      IF (I.EQ.1000) THEN
         VALI = I
         VALR (1) = SURFAC*EPAIS
         VALR (2) = SURF*EPAIS
         CALL U2MESG('A','PREPOST6_3',0,' ',1,VALI,2,VALR)
         GOTO 70
      ENDIF
      GOTO 50
C
C --- C'EST TROUVE
 70   CONTINUE
      ANG2=ANG2*DEG
      IF ( ANGARE .LT. 90.D0 ) THEN
         ANGDEB = ANG1
         ANGFIN = ANG2
      ENDIF
      IF ( ANGARE .GT. 270.D0 ) THEN
         ANGDEB = 360.D0 - ANG2
         ANGFIN = 360.D0 - ANG1
      ENDIF
      IF ( (ANGARE.GT.90.D0) .AND. (ANGARE.LT.180.D0) ) THEN
         ANGDEB = 180.D0 - ANG2
         ANGFIN = 180.D0 - ANG1
      ENDIF
      IF ( (ANGARE.GT.180.D0) .AND. (ANGARE.LT.270.D0) ) THEN
         ANGDEB = 180.D0 + ANG1
         ANGFIN = 180.D0 + ANG2
      ENDIF
C
C --- CALCUL DE LA PROFONDEUR
C
      A = (SIN(ANGMAX)/COS(ANGMAX))+(COS(THETA0)/SIN(THETA0))
      XPROF =BANGF/A
      YPROF =(SIN(ANGMAX)/COS(ANGMAX))*XPROF
      XANGM =R*COS(ANGMAX)
      YANGM =R*SIN(ANGMAX)
      PROFON=SQRT(((XPROF-XANGM)**2)+((YPROF-YANGM)**2))
      ANGMAX = ANGARE
C
      END
