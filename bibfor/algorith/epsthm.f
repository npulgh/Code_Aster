      SUBROUTINE EPSTHM ( NDDLS, NDDLM, NNO, NNOS, NNOM, NMEC,
     &                    DIMDEF, DIMUEL, NDIM, NPI,
     &                    IPOIDS, IPOID2, IVF, IVF2,
     &                    IDFDE, IDFDE2, DFDI, DFDI2, B,
     &                    GEOM, DEPLA,
     &                    MECANI, PRESS1, PRESS2, TEMPE,
     &                    NP1, NP2, AXI, EPSM )
C
       IMPLICIT NONE
C
C DECLARATION PARAMETRES D'APPEL
C
       INTEGER      NDDLS, NDDLM, NNO, NNOS, NNOM, NMEC
       INTEGER      DIMDEF, DIMUEL, NDIM, NPI
       INTEGER      IPOIDS, IPOID2, IVF, IVF2
       INTEGER      IDFDE, IDFDE2
       INTEGER      NP1, NP2
       INTEGER      MECANI(5), PRESS1(7), PRESS2(7), TEMPE(5)
       REAL*8       GEOM(NDIM,NNO), DEPLA(DIMUEL), EPSM(6,NPI)
       LOGICAL      AXI
C ======================================================================
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 02/05/2011   AUTEUR DELMAS J.DELMAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2011  EDF R&D                  WWW.CODE-ASTER.ORG
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
C TOLE  CRP_21
C ======================================================================
C     BUT : CALCUL DES DEFORMATIONS MECANIQUES AU POINT DE GAUSS
C           EN MECANIQUE DES MILIEUX POREUX AVEC COUPLAGE THM
C ======================================================================
C IN  NDDL    : NOMBRE DE DEGRES DE LIBERTE PAR NOEUD DE L'ELEMENT
C IN  NNO     : NOMBRE DE NOEUDS DE L'ELEMENT
C IN  NNOS    : NOMBRE DE NOEUDS SOMMET DE L'ELEMENT
C IN  DIMDEF  : DIMENSION DU TABLEAU DES DEFORMATIONS GENERALISEES
C               AU POINT DE GAUSS
C IN  NDIM    : DIMENSION DU PROBLEME
C IN  NPI     : NOMBRE DE POINTS DE GAUSS
C IN  IPOIDS  : ADRESSE DANS ZR DU TABLEAU POIDS(IPG)
C IN  IVF     : ADRESSE DANS ZR DU TABLEAU FF(INO,IPG)
C IN  IDFDE   : ADRESSE DANS ZR DU TABLEAU DFF(IDIM,INO,IPG)
C AUX DFDI    : DERIVEE DES FONCTIONS DE FORME POUR LES VARIABLES P2
C AUX DFDI2   : DERIVEE DES FONCTIONS DE FORME POUR LES VARIABLES P1
C AUX B       : MATRICE PERMETTANT LES OPERATIONS ELEMENTAIRES
C IN  GEOM    : COORDONEES DES NOEUDS
C IN  DEPLA   : VALEURS DES DEPLACEMENTS AUX NOEUDS
C IN  NMEC    : VARIABLE CARACTERISANT LE MILIEU
C IN  MECANI  : VARIABLE CARACTERISANT LE MILIEU
C IN  PRESS1  : VARIABLE CARACTERISANT LE MILIEU
C IN  PRESS2  : VARIABLE CARACTERISANT LE MILIEU
C IN  TEMPE   : VARIABLE CARACTERISANT LE MILIEU
C IN  NP1     : VAUT 1 SI LA MODELISATION CONTIENT UNE PRESSION
C               COMME VARIABLE
C IN  NP2     : VAUT 1 SI LA MODELISATION CONTIENT UNE DEUXIEME
C               PRESSION COMME VARIABLE
C IN  AXI     : VRAI SI ELEMENT APPELANT AXI
C OUT EPSM    : DEFORMATIONS AUX POINTS DE GAUSS SUR L'ELEMENT COURANT
C ======================================================================
C
      INTEGER IPI, KPI, IAUX, J
      INTEGER ADDEME, ADDEP1, ADDEP2, ADDETE
      INTEGER YAMEC, YATE, YAP1, YAP2
      REAL*8 POIDS,POIDS2, B(DIMDEF,DIMUEL)
      REAL*8 DFDI(NNO,3), DFDI2(NNOS,3)
C
C====
C 1. PREALABLES
C====
C
      YAMEC  = MECANI(1)
      ADDEME = MECANI(2)
C
      YAP1   = PRESS1(1)
      IF ( YAP1.EQ.1 ) THEN
        ADDEP1 = PRESS1(3)
      ENDIF
C
      YAP2   = PRESS2(1)
      IF ( YAP2.EQ.1 ) THEN
        ADDEP2 = PRESS2(3)
      ENDIF
C
      YATE   = TEMPE(1)
      IF ( YATE.EQ.1 ) THEN
        ADDETE = TEMPE(2)
      ENDIF
C
C====
C 2. CALCUL SELON LES PHYSIQUES
C====
C
      DO 20 , KPI = 1 , NPI
C
C ======================================================================
C --- CALCUL DE LA MATRICE B AU POINT DE GAUSS -------------------------
C ======================================================================
        IPI = KPI
        CALL CABTHM (NDDLS,NDDLM,NNO,NNOS,NNOM,DIMUEL,
     >               DIMDEF,NDIM,IPI,IPOIDS,IPOID2,IVF,IVF2,
     >               IDFDE,IDFDE2,DFDI,DFDI2,
     >               GEOM,POIDS,POIDS2,B,NMEC,YAMEC,ADDEME,YAP1,
     >               ADDEP1,YAP2,ADDEP2,YATE,ADDETE,NP1,NP2,AXI)
C
C ======================================================================
C --- CALCUL DES DEFORMATIONS ------------------------------------------
C ======================================================================
C
        IF ( YAMEC.EQ.1 ) THEN
C
        DO 210 , IAUX = 1 , 6
C
          EPSM(IAUX,IPI) = 0.D0
C
          DO 211 , J = 1,DIMUEL
            EPSM(IAUX,IPI) = EPSM(IAUX,IPI)+B(IAUX+NDIM,J)*DEPLA(J)
  211     CONTINUE
C
  210   CONTINUE
C
        ENDIF
C
C ======================================================================
C
   20 CONTINUE
C
C ======================================================================
C
      END
