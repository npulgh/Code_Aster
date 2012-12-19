      SUBROUTINE TE0181(OPTION,NOMTE)
      IMPLICIT NONE
      INCLUDE 'jeveux.h'

      CHARACTER*16 OPTION,NOMTE
C.......................................................................
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 19/12/2012   AUTEUR PELLET J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
C (AT YOUR OPTION) ANY LATER VERSION.

C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.

C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================

C     BUT: CALCUL DES MATRICES DE MASSE ELEMENTAIRE EN ACOUSTIQUE
C          ELEMENTS ISOPARAMETRIQUES 3D

C          OPTION : 'MASS_ACOU '

C     ENTREES  ---> OPTION : OPTION DE CALCUL
C          ---> NOMTE  : NOM DU TYPE ELEMENT
C.......................................................................


      INTEGER  IPOIDS,IVF,IDFDE,IGEOM,IMATE
      INTEGER  JGANO,NNO,KP,NPG,IJ,I,J,IMATTT
      REAL*8   CEL,DFDX(27),DFDY(27),DFDZ(27),POIDS
      INTEGER ICODRE

      COMPLEX*16 VALRES


C-----------------------------------------------------------------------
      INTEGER L ,NDI ,NDIM ,NNOS
C-----------------------------------------------------------------------
      CALL ELREF4(' ','MASS',NDIM,NNO,NNOS,NPG,IPOIDS,IVF,IDFDE,JGANO)
      NDI = NNO* (NNO+1)/2

      CALL JEVECH('PGEOMER','L',IGEOM)
      CALL JEVECH('PMATERC','L',IMATE)
      CALL JEVECH('PMATTTC','E',IMATTT)

      CALL RCVALC(ZI(IMATE),'FLUIDE',1,'CELE_C',VALRES,
     &            ICODRE,1)
      CEL = DBLE(VALRES)

      DO 20 I = 1,NDI
        ZC(IMATTT-1+I) = (0.0D0,0.0D0)
   20 CONTINUE

C    BOUCLE SUR LES POINTS DE GAUSS

      DO 50 KP = 1,NPG
        L = (KP-1)*NNO

        CALL DFDM3D ( NNO, KP, IPOIDS, IDFDE,
     &                ZR(IGEOM), DFDX, DFDY, DFDZ, POIDS )

        DO 40 I = 1,NNO
          DO 30 J = 1,I
            IJ = (I-1)*I/2 + J
            ZC(IMATTT+IJ-1) = ZC(IMATTT+IJ-1) +
     &                        ((1.0D0,0.0D0)/ (CEL**2))*POIDS*
     &                        ZR(IVF+L+I-1)*ZR(IVF+L+J-1)
   30     CONTINUE
   40   CONTINUE
   50 CONTINUE

      END
