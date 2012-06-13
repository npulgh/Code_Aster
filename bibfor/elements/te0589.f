      SUBROUTINE TE0589(OPTION,NOMTE)
      IMPLICIT NONE
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
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
      INCLUDE 'jeveux.h'
      CHARACTER*16 OPTION,NOMTE
C ......................................................................

C    - FONCTION REALISEE:  CALCUL DU SECOND MEMBRE : TRAVAIL DE LA
C                          DILATATION THERMIQUE

C    - ARGUMENTS:
C        DONNEES:      OPTION       -->  OPTION DE CALCUL
C                      NOMTE        -->  NOM DU TYPE ELEMENT
C ......................................................................

      INTEGER NBRDDM,NPG,IPOIDS,IVF
      PARAMETER (NBRDDM=156)
      INTEGER NDIM,NNOS,NNO,JCOOPG,IDFDK,JDFD2,JGANO
      REAL*8 F(NBRDDM),B(4,NBRDDM),VOUT(NBRDDM)
      REAL*8 VTEMP(NBRDDM),PASS(NBRDDM,NBRDDM)
      INTEGER M,NBRDDL

      CALL ELREF5(' ','RIGI',NDIM,NNO,NNOS,NPG,IPOIDS,JCOOPG,IVF,IDFDK,
     &            JDFD2,JGANO)


      M = 3
      IF (NOMTE.EQ.'MET6SEG3') M = 6

C     FORMULE GENERALE

      NBRDDL = NNO* (6+3+6* (M-1))

C     VERIFS PRAGMATIQUES

      IF (NBRDDL.GT.NBRDDM) THEN
        CALL U2MESS('F','ELEMENTS4_40')
      END IF
      IF (NOMTE.EQ.'MET3SEG3') THEN
        IF (NBRDDL.NE.63) THEN
          CALL U2MESS('F','ELEMENTS4_41')
        END IF
      ELSE IF (NOMTE.EQ.'MET6SEG3') THEN
        IF (NBRDDL.NE.117) THEN
          CALL U2MESS('F','ELEMENTS4_41')
        END IF
      ELSE IF (NOMTE.EQ.'MET3SEG4') THEN
        IF (NBRDDL.NE.84) THEN
          CALL U2MESS('F','ELEMENTS4_41')
        END IF
      ELSE
        CALL U2MESS('F','ELEMENTS4_42')
      END IF

      CALL TUTEMP(OPTION,NOMTE,NBRDDL,F,B,VOUT,PASS,VTEMP)
      END
