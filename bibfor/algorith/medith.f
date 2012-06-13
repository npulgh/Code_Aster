      SUBROUTINE MEDITH(TYPCAL,MODELE,CHARGE,INFCHA,MEDIRI)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
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
      IMPLICIT NONE

      INCLUDE 'jeveux.h'
      CHARACTER*4 TYPCAL
      CHARACTER*24 MODELE,CHARGE,INFCHA,MEDIRI

C ----------------------------------------------------------------------
C CALCUL DES MATRICES ELEMENTAIRES DES ELEMENTS DE LAGRANGE

C C'EST UNE RECOPIE DE MEDIME OU L'ON MODIFIE CHME EN CHTH


C IN  TYPCAL  : TYPE DU CALCUL :
C               'THER', POUR LA RESOLUTION DE LA THERMIQUE,
C               'DLAG', POUR LE CALCUL DE LA DERIVEE DE T
C IN  MODELE  : NOM DU MODELE
C IN  CHARGE  : LISTE DES CHARGES
C IN  INFCHA  : INFORMATIONS SUR LES CHARGEMENTS
C OUT MEDIRI  : MATRICES ELEMENTAIRES



      CHARACTER*8 NOMCHA,LPAIN(1),LPAOUT(1),K8BID
      CHARACTER*19 MATEL
      CHARACTER*16 OPTION
      CHARACTER*24 LIGRCH,LCHIN(1),LCHOUT(1)
      INTEGER IRET,NCHAR,ILIRES,JMED,ICHAR,JCHAR,JINF

      CALL JEMARQ()
      CALL JEEXIN(CHARGE,IRET)
      IF (IRET.EQ.0) GO TO 20
      CALL JELIRA(CHARGE,'LONMAX',NCHAR,K8BID)
      CALL JEVEUO(CHARGE,'L',JCHAR)

      CALL JEEXIN(MEDIRI,IRET)
      IF (IRET.EQ.0) THEN
        MATEL = '&&METDIR           '
        MEDIRI = MATEL//'.RELR'
        CALL MEMARE('V',MATEL,MODELE(1:8),' ',' ','RIGI_THER')
        CALL WKVECT(MEDIRI,'V V K24',NCHAR,JMED)
      ELSE
        CALL JEVEUO(MEDIRI,'E',JMED)
      END IF

      LPAOUT(1) = 'PMATTTR'
      LCHOUT(1) = MEDIRI(1:8)//'.ME001'

      IF (ZK24(JCHAR).NE.'        ') THEN
        ILIRES = 0
        CALL JEVEUO(INFCHA,'L',JINF)
        DO 10 ICHAR = 1,NCHAR
          IF (ZI(JINF+ICHAR).NE.0) THEN
            NOMCHA = ZK24(JCHAR+ICHAR-1) (1:8)
            LIGRCH = NOMCHA//'.CHTH.LIGRE'

            CALL JEEXIN(NOMCHA//'.CHTH.LIGRE.LIEL',IRET)
            IF (IRET.LE.0) GO TO 10
            LCHIN(1) = NOMCHA//'.CHTH.CMULT'
            CALL EXISD('CHAMP_GD',NOMCHA//'.CHTH.CMULT',IRET)
            IF (IRET.LE.0) GO TO 10

            LPAIN(1) = 'PDDLMUR'
            CALL CODENT(ILIRES+1,'D0',LCHOUT(1) (12:14))
            OPTION = 'THER_DDLM_R'
            CALL CALCUL('S',OPTION,LIGRCH,1,LCHIN,LPAIN,1,LCHOUT,LPAOUT,
     &                  'V','OUI')
            ZK24(JMED+ILIRES) = LCHOUT(1)
            ILIRES = ILIRES + 1
          END IF
   10   CONTINUE
        CALL JEECRA(MEDIRI,'LONUTI',ILIRES,K8BID)
      END IF
   20 CONTINUE
C FIN ------------------------------------------------------------------
      CALL JEDEMA()
      END
