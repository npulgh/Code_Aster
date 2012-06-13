      SUBROUTINE RSUTNC(NOMSD,NOMSY,NBVALE,TABNOM,TABORD,NBTROU)
      IMPLICIT REAL*8 (A-H,O-Z)
      INCLUDE 'jeveux.h'
      INTEGER NBVALE,TABORD(*),NBTROU
      CHARACTER*(*) NOMSD,NOMSY,TABNOM(*)
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C RESPONSABLE VABHHTS J.PELLET
C      RECUPERATION DES CHAMPS NOTES ET DE LEURS NUMEROS D'ORDRE DANS
C      UNE STRUCTURE DE DONNEES NOMSD ET DE NOM SYMBOLIQUE NOMSY.
C ----------------------------------------------------------------------
C IN  : NOMSD  : NOM DE LA STRUCTURE "RESULTAT"
C IN  : NOMSY  : NOM SYMBOLIQUE DES CHAMPS A RECHERCHER
C IN  : NBVALE : DIMENSION DES TABLEAUX
C                = 0 , ON REND LE NOMBRE DE CHAMPS TROUVES (-NBTROU)
C OUT : TABNOM : TABLEAU DES NOMS DE CHAMPS
C OUT : TABORD : TABLEAU DES NUMEROS D'ORDRE DES CHAMPS TROUVES
C OUT : NBTROU : NOMBRE DE CHAMPS TROUVES
C                SI NBTROU > NBVALE, ALORS NBTROU = -NBTROU.
C ----------------------------------------------------------------------
      CHARACTER*16 NOMS2
      CHARACTER*19 NOMD2
      CHARACTER*24 CHEXTR
      CHARACTER*1 K1BID
C ----------------------------------------------------------------------

      CALL JEMARQ()
      NBTROU = 0
      NOMS2 = NOMSY
      NOMD2 = NOMSD
      IF (NBVALE.LT.0) GO TO 20
      IF (NOMS2.EQ.' ') GO TO 20

      CALL JELIRA(NOMD2//'.ORDR','LONUTI',NBORDR,K1BID)
      CALL JEVEUO(NOMD2//'.ORDR','L',JORDR)
      CALL JENONU(JEXNOM(NOMD2//'.DESC',NOMS2),IBID)
      CALL JEVEUO(JEXNUM(NOMD2//'.TACH',IBID),'L',JTACH)
      ITROU = 0
      DO 10 I = 0,NBORDR - 1
        CHEXTR = ZK24(JTACH+I)
        IF (CHEXTR.NE.' ') THEN
          NBTROU = NBTROU + 1
          IF (NBVALE.EQ.0) GO TO 10
          ITROU = ITROU + 1
          IF (ITROU.LE.NBVALE) THEN
            TABORD(ITROU) = ZI(JORDR+I)
            TABNOM(ITROU) = CHEXTR
          END IF
        END IF
   10 CONTINUE
      IF (NBTROU.GT.NBVALE) NBTROU = -NBTROU

   20 CONTINUE
      CALL JEDEMA()
      END
