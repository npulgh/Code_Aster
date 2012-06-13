      SUBROUTINE XMCOOR(JCESD,JCESV,JCESL,IFISS,NDIM ,NPTE ,
     &                  NUMMAE,IFAC  ,XP    ,YP    ,COORD)
C
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
C TOLE CRS_1404
C
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      INTEGER      JCESD(10),JCESV(10),JCESL(10)
      INTEGER      NDIM,NUMMAE,IFAC,NPTE,IFISS
      REAL*8       XP,YP
      REAL*8       COORD(3)
C
C ----------------------------------------------------------------------
C
C ROUTINE XFEM (CONTACT - GRANDS GLISSEMENTS)
C
C CALCUL DES COORDONNEES LOCAUX DU PT D'INTEGRATION OU DE SON PROJETE
C DANS LES MAILLES MAITRES OU ESCLAVES RESPECTIVEMENT
C
C TRAVAIL EFFECTUE EN COLLABORATION AVEC L'I.F.P.
C
C ----------------------------------------------------------------------
C
C

C  JCES*(3)  : POINTEURS DE LA SD SIMPLE DES COOR DES PT D'INTER
C  JCES*(4)  : POINTEURS DE LA SD SIMPLE DE CONNECTIVIT� DES FACETTES
C IN IFISS  : NUM�RO DE FISSURE LOCALE DANS NUMMAE
C IN  NDIM  : DIMENSION DU PROBLEME
C IN  NUMMAE: POSITION DE LA MAILLE ESCLAVE OU MAITRE
C IN  IFAC  : NUMERO LOCAL DE LA FACETTE ESCLAVE OU MAITRE
C IN  XP    : COORDONNEE X DU POINT D'INTEGRATION DE CONTACT SUR
C             LA MAILLE ESCLAVE OU MAITRE
C IN  YP    : COORDONNEE Y DU POINT D'INTEGRATION DE CONTACT SUR
C             LA MAILLE ESCLAVE OU MAITRE
C OUT COORD : COORDONNEES DU POINT D'INTEGRATION DANS L'ELEMENT
C             PARENT
C
C
C
C
      REAL*8  COOR(NPTE)
      INTEGER I,J,IAD,NUMPI(NPTE)
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- RECUPERATION DES NUM LOCAUX DES PTS D'INTER DE LA FACETTE
C
      CALL VECINI(NPTE,0.D0,COOR)
      DO 10 I=1,NPTE
        NUMPI(I)=0
 10   CONTINUE
      CALL VECINI(3,0.D0,COORD)
C
      DO 20 I=1,NPTE
        CALL CESEXI('S',JCESD(4),JCESL(4),NUMMAE,1,IFISS,
     &              (IFAC-1)*NDIM+I,IAD)
        CALL ASSERT(IAD.GT.0)
        NUMPI(I) = ZI(JCESV(4)-1+IAD)
 20   CONTINUE
      DO 30 I=1,NDIM
C --- BOUCLE SUR LES DIMENSIONS
        DO 40 J=1,NPTE
C --- BOUCLE SUR LES POINTS D'INTERSECTIONS
C --- RECUPERATION DE LA COMPOSANTE LOCALE I DE CHACUN DES POINTS
C --- D'INTERSECTIONS J DE LA FACETTE
          CALL CESEXI('S',JCESD(3),JCESL(3),NUMMAE,1,IFISS,
     &                NDIM*(NUMPI(J)-1)+I,IAD)
          CALL ASSERT(IAD.GT.0)
          COOR(J) = ZR(JCESV(3)-1+IAD)
 40     CONTINUE
C --- CALCUL DE LA COMPOSANTE I POUR LE POINT DE CONTACT DANS LA
C --- MAILLE PARENTE
        IF (NDIM.EQ.2) THEN
          IF(NPTE.LE.2) THEN
            COORD(I) = COOR(1)*(1-XP)/2 + COOR(2)*(1+XP)/2
          ELSEIF(NPTE.EQ.3) THEN
            COORD(I) = -COOR(1)*XP*(1-XP)/2 + COOR(2)*XP*(1+XP)/2
     &              + COOR(3)*(1+XP)*(1-XP)
          ENDIF
        ELSEIF (NDIM.EQ.3) THEN
          COORD(I) = COOR(1)*(1-XP-YP) + COOR(2)*XP + COOR(3)*YP
        ENDIF
 30   CONTINUE
C
      CALL JEDEMA()
      END
