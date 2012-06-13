      SUBROUTINE DSINGU(NDIM,NELEM,NNOEM,NSOMMX,NELCOM,DEGRE,NBR,
     &                  ICNC,NUMELI,XY,ERREUR,ENERGI,MESU,
     &                  ALPHA,NALPHA)
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      INTEGER NDIM,NELEM,NNOEM,NSOMMX,NELCOM,DEGRE,NBR(NELEM)
      INTEGER ICNC(NSOMMX+2,NELEM),NUMELI(NELCOM+2,NNOEM)
      REAL*8  XY(3,NNOEM),ERREUR(NELEM),ENERGI(NELEM),MESU(NELEM)
      REAL*8  ALPHA(NELEM)
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
C TOLE CRS_1404
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
C
C     BUT:
C         CALCUL DES DEGRES ELEMENTAIRE DE LA SINGULARITE
C         OPTION : 'SING_ELEM'
C
C
C     ARGUMENTS:
C     ----------
C
C      ENTREE :
C-------------
C IN   NDIM                   : DIMENSION DU PROBLEME
C IN   NELEM                  : NOMBRE D ELEMENTS FINIS
C IN   NNOEM                  : NOMBRE DE NOEUDS
C IN   NSOMMX                 : NOMBRE DE SOMMETS MAX PAR EF
C IN   NELCOM                 : NOMBRE MAX D'EF PAR NOEUD
C IN   DEGRE                  : DEGRE DES EF 1 EF P1 2 POUR EF P2
C IN   NBR(NELEM)             : NOMBRE DE COMPOSANTES A STOCKER PAR EF
C      3 SI EF SURFACIQUES EN 2D OU VOLUMIQUES EN 3D
C      0 SINON
C IN   ICNC(NSOMMX+2,NELEM)   : CONNECTIVITE EF=>NOEUDS CONNECTES
C      1ERE VALEUR = NBRE DE NOEUDS SOMMETS CONNECTES A L EF N�X
C      2EME VALEUR = 1 SI EF UTILE 0 SINON
C      CONNECTIVITE  EF N�X=>N� DE NOEUDS SOMMETS CONNECTES A X
C      EN 2D EF UTILE = QUAD OU TRIA
C      EN 3D EF UTILE = TETRA OU HEXA
C IN   NUMELI(NELCOM+2,NNOEM) : CONNECTIVITE INVERSE NOEUD=>EF CONNECTES
C      1ERE VALEUR = NBRE D EFS UTILES CONNECTES AU NOEUD N�X
C      2EME VALEUR = 0 NOEUD MILIEU OU NON CONNECTE A UN EF UTILE
C                    1 NOEUD SOMMET A L INTERIEUR + LIE A UN EF UTILE
C                    2 NOEUD SOMMET BORD + LIE A UN EF UTILE
C      CONNECTIVITE  NOEUD N�X=>N� DES EF UTILE CONNECTES A X
C IN   XY(3,NNOEM)           : COORDONNEES DES NOEUDS
C IN   ERREUR(NELEM)         : ERREUR SUR CHAQUE EF
C IN   ENERGI(NELEM)         : ENERGIE SUR CHAQUE EF
C IN   PREC                  : % DE L ERREUR TOTALE SOUHAITE POUR
C                     CALCULER LA NOUVELLE CARTE DE TAILLE DES EF
C IN   MESU(NELEM)           : SURFACE OU VOLUME DE CHAQUE EF
C
C      SORTIE :
C-------------
C OUT  ALPHA(NELEM)          : DEGRE DE LA SINGULARITE PAR ELEMENT
C OUT  NALPHA                : NOMBRE DE CPE PAR ELEMENT DIFFERENTS
C                              1 PAR DEFAUT SI PAS DE SINGULARITE
C
C ......................................................................
C
C
C
C

      INTEGER NALPHA
C
C CALCUL DU DEGRE DE LA SINGULARITE ALPHA(NELEM)
C
      IF (NDIM.EQ.2) THEN
        CALL DALP2D(NELEM,NNOEM,DEGRE,NSOMMX,ICNC,NELCOM,
     &              NUMELI,NDIM,XY,ERREUR,ENERGI,MESU,
     &              ALPHA,NALPHA)
      ELSEIF (NDIM.EQ.3) THEN
        CALL DALP3D(NELEM,NNOEM,DEGRE,NSOMMX,ICNC,NELCOM,
     &              NUMELI,NDIM,XY,ERREUR,ENERGI,MESU,
     &              ALPHA,NALPHA)
      ELSE
        CALL ASSERT(.FALSE.)
      ENDIF

      END
