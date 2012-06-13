      SUBROUTINE XMAFR1(NDIM,ND,P)

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
C RESPONSABLE GENIAUT S.GENIAUT
C
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      REAL*8       ND(3),P(3,3)
      INTEGER      NDIM
C ----------------------------------------------------------------------
C        CALCUL DE LA MATRICE DE L'OPÉRATEUR DE PROJECTION

C IN    NDIM : DIMENSION DU MAILLAGE
C IN    ND   : NORMALE

C OUT   P    : OPÉRATEUR DE PROJECTION





      INTEGER     I,J

C     P : OPÉRATEUR DE PROJECTION
      DO 10 I = 1,NDIM
        DO 20 J = 1,NDIM
          P(I,J) = -1.D0 * ND(I)*ND(J)
 20     CONTINUE
 10   CONTINUE

      DO 30 I = 1,NDIM
         P(I,I) = 1.D0 + P(I,I)
 30   CONTINUE

      END
