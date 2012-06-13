      SUBROUTINE XMELEM(NOMA  ,MODELE,DEFICO,RESOCO)
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
C RESPONSABLE ABBAS M.ABBAS
C
      IMPLICIT      NONE
      INCLUDE 'jeveux.h'
      CHARACTER*8   MODELE,NOMA
      CHARACTER*24  RESOCO,DEFICO
C
C ----------------------------------------------------------------------
C
C ROUTINE XFEM (METHODE XFEM - CREATION CHAM_ELEM)
C
C CREATION DES CHAM_ELEM
C
C ----------------------------------------------------------------------
C
C
C IN  NOMA   : NOM DU MAILLAGE
C IN  MODELE : NOM DU MODELE
C IN  DEFICO : SD POUR LA DEFINITION DE CONTACT
C IN  RESOCO : SD POUR LA RESOLUTION DE CONTACT
C
C

C
C
      INTEGER       IFM,NIV,NFISS,JNFIS,NFISMX
      CHARACTER*19  LIGREL
      CHARACTER*19  XDONCO,XINDCO,XSEUCO,XMEMCO,XGLISS,XCOHES
      CHARACTER*19  XINDCP,XMEMCP,XSEUCP,XCOHEP
      PARAMETER    (NFISMX=100)
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFDBG('XFEM',IFM,NIV)
C
C --- AFFICHAGE
C
      IF (NIV.GE.2) THEN
        WRITE (IFM,*) '<XFEM  > CREATION DES CHAM_ELEM'
      ENDIF
C
C --- INITIALISATIONS
C
      LIGREL = MODELE//'.MODELE'
C
C --- NOMBRE DE FISSURES
C
      CALL JEVEUO(MODELE//'.NFIS','L',JNFIS)
      NFISS  = ZI(JNFIS)
      IF (NFISS .GT. NFISMX) THEN
        CALL U2MESI('F', 'XFEM_2', 1, NFISMX)
      ENDIF
      IF (NFISS .LE. 0) THEN
        CALL U2MESS('F', 'XFEM_3')
      ENDIF
C
C
C
      XINDCO = RESOCO(1:14)//'.XFIN'
      XMEMCO = RESOCO(1:14)//'.XMEM'
      XINDCP = RESOCO(1:14)//'.XFIP'
      XMEMCP = RESOCO(1:14)//'.XMEP'
      XDONCO = RESOCO(1:14)//'.XFDO'
      XSEUCO = RESOCO(1:14)//'.XFSE'
      XSEUCP = RESOCO(1:14)//'.XFSP'
      XGLISS = RESOCO(1:14)//'.XFGL'
      XCOHES = RESOCO(1:14)//'.XCOH'
      XCOHEP = RESOCO(1:14)//'.XCOP'
C
C ---
C
      CALL XMELE1(NOMA  ,MODELE,DEFICO,LIGREL,NFISS ,
     &            XINDCO,'PINDCOI','RIGI_CONT')
      CALL XMELE1(NOMA  ,MODELE,DEFICO,LIGREL,NFISS ,
     &            XMEMCO,'PMEMCON','XCVBCA')
      CALL XMELE1(NOMA  ,MODELE,DEFICO,LIGREL,NFISS ,
     &            XINDCP,'PINDCOI','RIGI_CONT')
      CALL XMELE1(NOMA  ,MODELE,DEFICO,LIGREL,NFISS ,
     &            XMEMCP,'PMEMCON','XCVBCA')
      CALL XMELE1(NOMA  ,MODELE,DEFICO,LIGREL,NFISS ,
     &            XSEUCO,'PSEUIL','RIGI_CONT')
      CALL XMELE1(NOMA  ,MODELE,DEFICO,LIGREL,NFISS ,
     &            XSEUCP,'PSEUIL','XREACL')
      CALL XMELE1(NOMA  ,MODELE,DEFICO,LIGREL,NFISS ,
     &            XGLISS,'PGLISS','XCVBCA')
      CALL XMELE1(NOMA  ,MODELE,DEFICO,LIGREL,NFISS ,
     &            XCOHES,'PCOHES','RIGI_CONT')
      CALL XMELE1(NOMA  ,MODELE,DEFICO,LIGREL,NFISS ,
     &            XCOHEP,'PCOHES','XCVBCA')
C
C ---
C
      CALL XMELE2(NOMA  ,MODELE,DEFICO,LIGREL,NFISS ,
     &            XDONCO)
C
      CALL JEDEMA()
C
      END
