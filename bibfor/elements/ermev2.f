      SUBROUTINE ERMEV2(NNO,IGEOM,FF,SIG,NBCMP,DFDX,DFDY,
     &                  POIDS,POIAXI,DSX,DSY,NORME)
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      INTEGER NNO,IGEOM,NBCMP
      INTEGER POIAXI
      REAL*8  FF(NNO),DFDX(9),DFDY(9),POIDS,DSX,DSY,NORME,SIG(*)
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
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
C ======================================================================
C  ERREUR EN MECANIQUE - TERME VOLUMIQUE - DIMENSION 2
C  **        **                *                     *
C ======================================================================
C
C     BUT:
C         PREMIER TERME DE L'ESTIMATEUR D'ERREUR EN RESIDU EXPLICITE :
C         CALCUL DE LA DIVERGENCE ET DE LA NORME DE SIGMA EN UN POINT
C         DE GAUSS EN 2D. UTILISE POUR UN ELEMENT "CLASSIQUE" OU UN 
C         SOUS-ELEMENT ISSU DU DECOUPAGE X-FEM
C
C
C     ARGUMENTS:
C     ----------
C
C      ENTREE :
C-------------
C IN   NNO    : NOMBRE DE NOEUDS DU TYPE_MAILLE
C IN   IGEOM  : ADRESSE DANS ZR DU TABLEAU DES COORDONNEES
C IN   FF     : TABLEAU DES VALEURS DES FONCTIONS DE FORME AU POINT DE 
C               GAUSS COURANT
C IN   SIG    : TABLEAU DES CONTRAINTES AUX NOEUDS
C IN   NBCMP  : NOMBRE DE COMPOSANTES
C IN   DFDX   : DERIVEES DES FONCTIONS DE FORME / X
C IN   DFDY   : DERIVEES DES FONCTIONS DE FORME / Y
C IN   POIAXI : EN MODELISATION AXI :
C               =0 : ON NE MULTIPLIE PAS LE POIDS PAR LE RAYON
C               =1 : ON MULTIPLIE LE POIDS PAR LE RAYON
C               EN MODELISATION AUTRE : SANS OBJET
C
C      SORTIE :
C-------------
C OUT  DSX    : PREMIERE COMPOSANTE DE DIVERGENCE SIGMA
C OUT  DSY    : SECONDE COMPOSANTE DE DIVERGENCE SIGMA
C OUT  NORME  : NORME DE SIGMA AU POINT DE GAUSS
C
C
C     ENTREE ET SORTIE :
C----------------------
C IN/OUT   POIDS  : NE SERT QU'A ETRE MULTIPLIE PAR LE RAYON DANS LE
C                   CAS DES MODELISATIONS AXI
C
C ......................................................................
C
C
C
C
      INTEGER I

      REAL*8 DSIG11,DSIG12,DSIG22,DSIG21,SPG11,SPG22,SPG33,SPG12
      REAL*8 R,SIG11,SIG22,SIG33,SIG12,R8PREM
      LOGICAL LTEATT
C
C ----------------------------------------------------------------------
C
      DSIG11=0.D0
      DSIG12=0.D0
      DSIG22=0.D0
      DSIG21=0.D0
C
      SPG11=0.D0
      SPG22=0.D0
      SPG33=0.D0
      SPG12=0.D0
C
C====
C 1. MODELISATION AXI
C====
C
      IF (LTEATT(' ','AXIS','OUI')) THEN
C
        R=0.D0
        DO 10 I=1,NNO
          R=R+ZR(IGEOM-1+2*(I-1)+1)*FF(I)
C
          SIG11=SIG(NBCMP*(I-1)+1)
          SIG22=SIG(NBCMP*(I-1)+2)
          SIG33=SIG(NBCMP*(I-1)+3)
          SIG12=SIG(NBCMP*(I-1)+4)
C
          DSIG11=DSIG11+SIG11*DFDX(I)
          DSIG12=DSIG12+SIG12*DFDY(I)
          DSIG22=DSIG22+SIG22*DFDY(I)
          DSIG21=DSIG21+SIG12*DFDX(I)
C
          SPG11=SPG11+SIG11*FF(I)
          SPG22=SPG22+SIG22*FF(I)
          SPG33=SPG33+SIG33*FF(I)
          SPG12=SPG12+SIG12*FF(I)
C
  10    CONTINUE
C

        CALL ASSERT(ABS(R).GT.R8PREM())
C
        DSX=DSIG11+DSIG12+(1.D0/R)*(SPG11-SPG33)
        DSY=DSIG21+DSIG22+(1.D0/R)*SPG12
        IF ( POIAXI.EQ.1 ) THEN
          POIDS = POIDS*R
        ENDIF
C
C====
C 2. AUTRE MODELISATION
C====
C
      ELSE
C
        DO 20 I=1,NNO
          SIG11=SIG(NBCMP*(I-1)+1)
          SIG22=SIG(NBCMP*(I-1)+2)
          SIG33=SIG(NBCMP*(I-1)+3)
          SIG12=SIG(NBCMP*(I-1)+4)
C
          DSIG11=DSIG11+SIG11*DFDX(I)
          DSIG12=DSIG12+SIG12*DFDY(I)
          DSIG22=DSIG22+SIG22*DFDY(I)
          DSIG21=DSIG21+SIG12*DFDX(I)
C
          SPG11=SPG11+SIG11*FF(I)
          SPG22=SPG22+SIG22*FF(I)
          SPG33=SPG33+SIG33*FF(I)
          SPG12=SPG12+SIG12*FF(I)
C
  20    CONTINUE
C
        DSX=DSIG11+DSIG12
        DSY=DSIG21+DSIG22
C
      ENDIF
C
C====
C 3.
C====
C
      NORME=SPG11**2+SPG22**2+SPG33**2+SPG12**2
C
      END
