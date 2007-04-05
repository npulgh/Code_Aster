      SUBROUTINE TE0054(OPTION,NOMTE)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 06/04/2007   AUTEUR PELLET J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
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
C.......................................................................
      IMPLICIT REAL*8 (A-H,O-Z)

C     BUT: CALCUL DES MATRICES DE MASSE ELEMENTAIRE EN THERMIQUE
C          ELEMENTS ISOPARAMETRIQUES 3D

C          OPTION : 'MASS_THER'

C     ENTREES  ---> OPTION : OPTION DE CALCUL
C              ---> NOMTE  : NOM DU TYPE ELEMENT
C.......................................................................

C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
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
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------

      CHARACTER*2 CODRET

      CHARACTER*16  NOMTE,OPTION,PHENOM
      REAL*8        VALPAR,DFDX(27),DFDY(27),DFDZ(27),POIDS
      INTEGER       IPOIDS,IVF,IDFDE,IGEOM,IMATE
      INTEGER       JGANO,NNO,KP,NPG2,IJ,I,J,IMATTT,ITEMPS

      CALL ELREF4(' ','RIGI',NDIM,NNO,NNOS,NPG2,IPOIDS,IVF,IDFDE,JGANO)

      CALL JEVECH('PGEOMER','L',IGEOM)
      CALL JEVECH('PMATERC','L',IMATE)
      CALL JEVECH('PTEMPSR','L',ITEMPS)
      CALL JEVECH('PMATTTR','E',IMATTT)

      CALL RCCOMA(ZI(IMATE),'THER',PHENOM,CODRET)
      IF (CODRET.NE.'OK') CALL U2MESS('A','ELEMENTS2_63')

      VALPAR = ZR(ITEMPS)
      DELTAT = ZR(ITEMPS+1)
      CALL RCVALA(ZI(IMATE),' ',PHENOM,1,'INST',VALPAR,1,'RHO_CP',CP,
     &           CODRET, 'FM')

C    BOUCLE SUR LES POINTS DE GAUSS

      DO 40 KP = 1,NPG2

        L = (KP-1)*NNO
        CALL DFDM3D ( NNO, KP, IPOIDS, IDFDE,
     &                ZR(IGEOM), DFDX, DFDY, DFDZ, POIDS )

        DO 30 I = 1,NNO

          DO 20 J = 1,I
            IJ = (I-1)*I/2 + J
            ZR(IMATTT+IJ-1) = ZR(IMATTT+IJ-1) +
     &                        CP/DELTAT*POIDS*ZR(IVF+L+I-1)*
     &                        ZR(IVF+L+J-1)

   20     CONTINUE
   30   CONTINUE

   40 CONTINUE

      END
