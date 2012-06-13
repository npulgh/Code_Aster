      SUBROUTINE NIPL2O(FAMI  ,NNO1  ,NNO2  ,NPG1  ,IPOIDS,IVF1  ,
     &                  IVF2  ,IDFDE1,GEOM  ,TYPMOD,OPTION,IMATE ,
     &                  COMPOR,LGPG  ,CRIT  ,INSTAM,INSTAP,DEPLM ,
     &                  DDEPL ,ANGMAS,PRESM ,DPRES ,PI    ,DPI   ,
     &                  SIGM  ,VIM   ,SIGP  ,VIP   ,STAB  ,FINTU ,
     &                  FINTA ,FINTP ,KUU   ,KAA   ,KPP   ,KUA   ,
     &                  KUP   ,KAP   ,CODRET)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
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
C RESPONSABLE PELLET J.PELLET
C TOLE CRP_21 CRS_1404

      IMPLICIT NONE

      INCLUDE 'jeveux.h'
      INTEGER       NNO1,NNO2,NPG1,IMATE,LGPG,CODRET
      INTEGER       IPOIDS,IVF1,IVF2,IDFDE1

      REAL*8        INSTAM, INSTAP
      REAL*8        GEOM(2,NNO1), CRIT(6)
      REAL*8        DEPLM(2,NNO1),DDEPL(2,NNO1)
      REAL*8        PRESM(1,NNO2),DPRES(1,NNO2)
      REAL*8        PI(2,NNO1),DPI(2,NNO1)
      REAL*8        DFDI(NNO1,2)
      REAL*8        SIGM(5,NPG1),SIGP(5,NPG1), STAB
      REAL*8        VIM(LGPG,NPG1),VIP(LGPG,NPG1)
      REAL*8        KUU(2,9,2,9),KUA(2,9,1,4),KAA(1,4,1,4)
      REAL*8        KPP(2,9,2,9),KUP(2,9,2,9),KAP(1,4,2,9)
      REAL*8        FINTU(2,9), FINTA(1,4),FINTP(2,9)
      REAL*8        ANGMAS(3)
      CHARACTER*8   TYPMOD(*)
      CHARACTER*16  COMPOR(*), OPTION
      CHARACTER*(*) FAMI

C......................................................................
C     BUT:  CALCUL  DES OPTIONS RIGI_MECA_TANG, RAPH_MECA ET FULL_MECA
C           EN HYPO-ELASTICITE
C......................................................................
C IN  NNO1    : NOMBRE DE NOEUDS DE L'ELEMENT LIES AUX DEPLACEMENTS
C IN  NNO2    : NOMBRE DE NOEUDS DE L'ELEMENT LIES A LA PRESSION
C IN  NPG1    : NOMBRE DE POINTS DE GAUSS
C IN  POIDSG  : POIDS DES POINTS DE GAUSS
C IN  VFF1    : VALEUR  DES FONCTIONS DE FORME LIES AUX DEPLACEMENTS
C               ET AU GRAD DE PRESSION PROJETE
C IN  VFF2    : VALEUR  DES FONCTIONS DE FORME LIES A LA PRESSION
C IN  DFDE1   : DERIVEE DES FONCTIONS DE FORME ELEMENT DE REFERENCE
C IN  DFDK1   : DERIVEE DES FONCTIONS DE FORME ELEMENT DE REFERENCE
C IN  GEOM    : COORDONEES DES NOEUDS
C IN  TYPMOD  : TYPE DE MODELISATION
C IN  OPTION  : OPTION DE CALCUL
C IN  IMATE   : MATERIAU CODE
C IN  COMPOR  : COMPORTEMENT
C IN  LGPG    : "LONGUEUR" DES VARIABLES INTERNES POUR 1 POINT DE GAUSS
C               CETTE LONGUEUR EST UN MAJORANT DU NBRE REEL DE VAR. INT.
C IN  CRIT    : CRITERES DE CONVERGENCE LOCAUX
C IN  INSTAM  : INSTANT PRECEDENT
C IN  INSTAP  : INSTANT DE CALCUL
C IN  TM      : TEMPERATURE AUX NOEUDS A L'INSTANT PRECEDENT
C IN  TP      : TEMPERATURE AUX NOEUDS A L'INSTANT DE CALCUL
C IN  TREF    : TEMPERATURE DE REFERENCE
C IN  DEPLM   : DEPLACEMENT A L'INSTANT PRECEDENT
C IN  DDEPL   : INCREMENT DE DEPLACEMENT
C IN  ANGMAS  : LES TROIS ANGLES DU MOT_CLEF MASSIF (AFFE_CARA_ELEM)
C IN  PRESM  : P ET G  A L'INSTANT PRECEDENT
C IN  DPRES  : INCREMENT POUR P ET G
C IN  SIGM    : CONTRAINTES A L'INSTANT PRECEDENT
C IN  VIM     : VARIABLES INTERNES A L'INSTANT PRECEDENT

C OUT DFDI    : DERIVEE DES FONCTIONS DE FORME  AU DERNIER PT DE GAUSS
C OUT SIGP    : CONTRAINTES DE CAUCHY (RAPH_MECA ET FULL_MECA)
C OUT VIP     : VARIABLES INTERNES    (RAPH_MECA ET FULL_MECA)
C OUT FINTU   : FORCES INTERNES
C OUT FINTA   : FORCES INTERNES LIEES AUX MULTIPLICATEURS
C OUT KUU     : MATRICE DE RIGIDITE (RIGI_MECA_TANG ET FULL_MECA)
C OUT KUA     : MATRICE DE RIGIDITE TERMES CROISES U - PG
C                                       (RIGI_MECA_TANG ET FULL_MECA)
C OUT KAA     : MATRICE DE RIGIDITE TERME PG (RIGI_MECA_TANG, FULL_MECA)
C......................................................................
C

      LOGICAL      GRAND,AXI
      INTEGER      KPG,I,J,KL,M,N,PQ,NDIM
      REAL*8       DSIDEP(6,6),DEPS(6),F(3,3)
      REAL*8       EPSM(6),EPSLDC(6),DEPLDC(6)
      REAL*8       SIGMAM(6),SIGMA(6),SIGTR
      REAL*8       DEF(4,9,2),DEFD(4,9,2),DEFTR(9,2)
      REAL*8       DIVUM,DDIVU,PM,DP,R,RAC2
      REAL*8       POIDS,VFF1,VFF2,VFFN,VFFM
      REAL*8       ALPHA,RBID,DDOT,TMP,TMP1,TMP2
      REAL*8       GRADM(2),DGRAD(2),VALPI(2),DVALP(2)

C-----------------------------------------------------------------------
C - INITIALISATION
      CALL R8INIR( 18, 0.D0, FINTU,1)
      CALL R8INIR(  4, 0.D0, FINTA,1)
      CALL R8INIR( 18, 0.D0, FINTP,1)
      CALL R8INIR(324, 0.D0, KUU,  1)
      CALL R8INIR(324, 0.D0, KPP,  1)
      CALL R8INIR( 72, 0.D0, KUA,  1)
      CALL R8INIR( 16, 0.D0, KAA,  1)
      CALL R8INIR(324, 0.D0, KUP,  1)
      CALL R8INIR( 72, 0.D0, KAP,  1)
      CALL R8INIR(  6, 0.D0, SIGMA,1)

      RAC2  = SQRT(2.D0)
      GRAND = .FALSE.
      AXI   = TYPMOD(1) .EQ. 'AXIS'
      NDIM  = 2

C - CALCUL POUR CHAQUE POINT DE GAUSS
      DO 800 KPG = 1,NPG1

C - CALCUL DE LA PRESSION
        PM = 0.D0
        DP = 0.D0
        DO 20 N = 1, NNO2
          VFF2 = ZR(IVF2-1+N+(KPG-1)*NNO2)
          PM = PM + VFF2*PRESM(1,N)
          DP = DP + VFF2*DPRES(1,N)
 20     CONTINUE

C - CALCUL DES ELEMENTS GEOMETRIQUES
C - CALCUL DE DFDI,F,EPS,R(EN AXI) ET POIDS
        CALL R8INIR(6, 0.D0, EPSM,1)
        CALL R8INIR(6, 0.D0, DEPS,1)
        CALL NMGEOM(NDIM,NNO1,AXI,GRAND,GEOM,KPG,IPOIDS,IVF1,IDFDE1,
     &              DEPLM,.TRUE.,POIDS,DFDI,F,EPSM,R)

C - CALCUL DE DEPS
        CALL NMGEOM(NDIM,NNO1,AXI,GRAND,GEOM,KPG,IPOIDS,IVF1,IDFDE1,
     &              DDEPL,.TRUE.,POIDS,DFDI,F,DEPS,R)

        DIVUM = EPSM(1) + EPSM(2) + EPSM(3)
        DDIVU = DEPS(1) + DEPS(2) + DEPS(3)

C - CALCUL DES MATRICES B ET BD
        DO 35 N=1,NNO1
          DO 30 I=1,2
            DEF(1,N,I) =  F(I,1)*DFDI(N,1)
            DEF(2,N,I) =  F(I,2)*DFDI(N,2)
            DEF(3,N,I) =  0.D0
            DEF(4,N,I) = (F(I,1)*DFDI(N,2) + F(I,2)*DFDI(N,1))/RAC2
 30       CONTINUE
 35     CONTINUE

C - TERME DE CORRECTION (3,3) AXI QUI PORTE EN FAIT SUR LE DDL 1
        IF (AXI) THEN
          DO 50 N=1,NNO1
            VFF1 = ZR(IVF1-1+N+(KPG-1)*NNO1)
            DEF(3,N,1) = F(3,3)*VFF1/R
 50       CONTINUE
        END IF

C - CALCUL DE LA TRACE ET DEVIATEUR DE B
          DO 70 N = 1, NNO1
            DO 65 I = 1,2
              DEFTR(N,I) =  DEF(1,N,I) + DEF(2,N,I) + DEF(3,N,I)
              DO 60 KL = 1,3
                DEFD(KL,N,I) = DEF(KL,N,I) - DEFTR(N,I)/3.D0
 60           CONTINUE
              DEFD(4,N,I) = DEF(4,N,I)
 65         CONTINUE
 70       CONTINUE

C - CALCUL DU GRAD DE PRESSION PROJETE
        VALPI(1) = 0.D0
        VALPI(2) = 0.D0
        DVALP(1) = 0.D0
        DVALP(2) = 0.D0

        GRADM(1) = 0.D0
        GRADM(2) = 0.D0
        DGRAD(1) = 0.D0
        DGRAD(2) = 0.D0

        DO 21 N = 1, NNO1
          DO 19 I = 1, NDIM
            GRADM(I) = GRADM(I)+DFDI(N,I)*PRESM(1,N)
            DGRAD(I) = DGRAD(I)+DFDI(N,I)*DPRES(1,N)
            VALPI(I) = VALPI(I) + ZR(IVF2+N+(KPG-1)*NNO2-1)*PI(I,N)
            DVALP(I) = DVALP(I) + ZR(IVF2+N+(KPG-1)*NNO2-1)*DPI(I,N)
 19       CONTINUE
 21     CONTINUE

C - DEFORMATION POUR LA LOI DE COMPORTEMENT
        CALL DCOPY(6, EPSM,1, EPSLDC,1)
        CALL DCOPY(6, DEPS,1, DEPLDC,1)

C - CONTRAINTE EN T- POUR LA LOI DE COMPORTEMENT
        SIGMAM(1) = SIGM(1,KPG) + SIGM(5,KPG)
        SIGMAM(2) = SIGM(2,KPG) + SIGM(5,KPG)
        SIGMAM(3) = SIGM(3,KPG) + SIGM(5,KPG)
        SIGMAM(4) = SIGM(4,KPG)*RAC2
        SIGMAM(5) = 0.D0
        SIGMAM(6) = 0.D0

C - APPEL A LA LOI DE COMPORTEMENT
      IF (.NOT.AXI)  TYPMOD(1) = 'AXIS    '

C - APPEL A LA LOI DE COMPORTEMENT
        CALL NMCOMP(FAMI,KPG,1,NDIM,TYPMOD,IMATE,COMPOR,CRIT,
     &            INSTAM, INSTAP, 6, EPSLDC, DEPLDC, 6, SIGMAM,
     &            VIM(1,KPG), OPTION, ANGMAS, 1, RBID,
     &            SIGMA, VIP(1,KPG), 36, DSIDEP, 1, RBID,
     &            CODRET)
      IF (.NOT.AXI)  TYPMOD(1) = 'C_PLAN  '

C - CALCUL DE L'INVERSE DE KAPPA
        CALL CALALP(KPG,IMATE,COMPOR,ALPHA)

C - CALCUL DE LA MATRICE DE RIGIDITE
        IF ( OPTION(1:9) .EQ. 'RIGI_MECA'
     &  .OR. OPTION(1:9) .EQ. 'FULL_MECA' ) THEN

C - TERME K_UU (DEPLACEMENTS/DEPLACEMENTS)
          DO 80 N = 1, NNO1
            DO 79 I = 1, NDIM
              DO 78 M = 1, NNO1
                DO 76 J = 1, NDIM
                  TMP = 0.D0
                  DO 75 KL = 1, 2*NDIM
                    DO 74 PQ = 1, 2*NDIM
                      TMP=TMP+DEFD(KL,N,I)*DSIDEP(KL,PQ)*DEFD(PQ,M,J)
 74                 CONTINUE
 75               CONTINUE
                  KUU(I,N,J,M) = KUU(I,N,J,M) + POIDS*TMP
 76             CONTINUE
 78           CONTINUE
 79         CONTINUE
 80       CONTINUE

C - TERME K_UA (DEPLACEMENTS/PRESSION)
          DO 90 N = 1, NNO1
            DO 89 I = 1, NDIM
              DO 88 M = 1, NNO2
                TMP = DEFTR(N,I)*ZR(IVF2+M+(KPG-1)*NNO2-1)
                KUA(I,N,1,M) = KUA(I,N,1,M) + POIDS*TMP
 88           CONTINUE
 89         CONTINUE
 90       CONTINUE

C - TERME K_UP (DEPLACEMENTS/GRAD DE PRESSION PROJETE) = 0

C - TERME K_AA (PRESSION/PRESSION)
          DO 501 N = 1, NNO2
            VFFN = ZR(IVF2 + N + (KPG-1)*NNO2-1)
            DO 502 M = 1, NNO2
              VFFM = ZR(IVF2 + M + (KPG-1)*NNO2-1)
              TMP = 0.D0
C - PRODUIT SCALAIRE DES GRAD DE FONCTIONS DE FORME
              DO 503 J = 1, NDIM
                TMP = TMP + DFDI(N,J)*DFDI(M,J)
 503          CONTINUE
              KAA(1,N,1,M)=KAA(1,N,1,M)-POIDS*(TMP*STAB+VFFN*VFFM*ALPHA)
 502        CONTINUE
 501      CONTINUE

C - TERME K_AP (PRESSION/GRAD DE PRESSION PROJETE)
C - NOEUDS DE PI
          DO 109 N = 1, NNO1
            TMP2 = ZR(IVF2 + N + (KPG-1)*NNO2-1)
C - NOEUDS DE P
            DO 110 M = 1, NNO2
              DO 111 I = 1, NDIM
              TMP = DEFTR(M,I)*TMP2
              KAP(1,M,I,N) = KAP(1,M,I,N) + POIDS*TMP*STAB
 111          CONTINUE
 110        CONTINUE
 109      CONTINUE

C - TERME K_PP (GRAD DE PRESSION PROJETE/GRAD DE PRESSION PROJETE)
          DO 117 N = 1, NNO1
            VFFN= ZR(IVF1 + N + (KPG-1)*NNO1-1)
            DO 118 M = 1, NNO1
              VFFM = ZR(IVF1 + M + (KPG-1)*NNO1-1)
              TMP = VFFN*VFFM*STAB
              DO 119 I = 1, NDIM
                KPP(I,N,I,M) = KPP(I,N,I,M) - POIDS*TMP
 119          CONTINUE
 118        CONTINUE
 117      CONTINUE
        END IF
C - REMARQUE : MATRICE NN NUL QUE SI I=J DONC KPP(I,.,J,M)=0 SINON

C - CALCUL DE LA FORCE INTERIEURE ET DES CONTRAINTES DE CAUCHY
        IF(OPTION(1:9).EQ.'FULL_MECA'.OR.
     &     OPTION(1:9).EQ.'RAPH_MECA') THEN

C - CONTRAINTES A L'EQUILIBRE
          SIGTR = SIGMA(1) + SIGMA(2) + SIGMA(3)
          DO 130 PQ = 1, 3
            SIGMA(PQ) = SIGMA(PQ) - SIGTR/3 + (PM+DP)
 130      CONTINUE

C - CALCUL DE FINT_U
          DO 140 N = 1, NNO1
            DO 139 I = 1, NDIM
              TMP = DDOT(2*NDIM, SIGMA,1, DEF(1,N,I),1)
              FINTU(I,N) = FINTU(I,N) + TMP*POIDS
 139        CONTINUE
 140      CONTINUE

C - CALCUL DE FINTA RESIDU DE P
          DO 150 N = 1, NNO2
            VFF2 = ZR(IVF2+N+(KPG-1)*NNO2-1)
            TMP1 = 0.D0
            TMP2 = 0.D0
C - PRODUIT SCALAIRE DE GRAD FONC DE FORME DE P ET GRAD P OU FONC DE PI
            DO 155 I = 1, NDIM
              TMP1 = TMP1 + DFDI(N,I)*(GRADM(I)+DGRAD(I))
              TMP2 = TMP2 + DFDI(N,I)*(VALPI(I)+DVALP(I))
 155        CONTINUE
            TMP = (DIVUM+DDIVU-(PM+DP)*ALPHA)*VFF2-STAB*(TMP1 - TMP2)
            FINTA(1,N) = FINTA(1,N) + TMP*POIDS
 150      CONTINUE

C - CALCUL DE FINTP RESIDU DE PI
          DO 145 N = 1, NNO1
            VFF2 = ZR(IVF1+N+(KPG-1)*NNO1-1)
            DO 144 I = 1, NDIM
              TMP = VFF2 * (GRADM(I)+ DGRAD(I)- VALPI(I)-DVALP(I))
              FINTP(I,N) = FINTP(I,N) + STAB*TMP*POIDS
 144        CONTINUE
 145      CONTINUE

C - STOCKAGE DES CONTRAINTES
          DO 290 KL = 1, 3
            SIGP(KL,KPG) = SIGMA(KL)
 290      CONTINUE
          SIGP(4,KPG) = SIGMA(4)/RAC2
          SIGP(5,KPG) = SIGTR/3.D0 - PM - DP
        END IF

 800  CONTINUE
      END
