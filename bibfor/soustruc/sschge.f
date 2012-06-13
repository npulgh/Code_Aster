      SUBROUTINE SSCHGE(NOMACR)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF SOUSTRUC  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
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
      IMPLICIT REAL*8 (A-H,O-Z)
C
C     ARGUMENTS:
C     ----------
      INCLUDE 'jeveux.h'
      CHARACTER*8 NOMACR
C ----------------------------------------------------------------------
C     BUT: TRAITER LE MOT CLEF "CAS_CHARGE"
C             DE L'OPERATEUR MACR_ELEM_STAT
C     LES CHARGEMENTS SERONT CONDENSES LORS DE L'ASSEMBLAGE.
C
C     IN: NOMACR : NOM DU MACR_ELEM_STAT
C
C     OUT: LES OBJETS SUIVANTS DU MACR_ELEM_STAT SONT CALCULES:
C             NOMACR.LICA(NOMCAS)
C             NOMACR.LICH(NOMCAS)
C
C ----------------------------------------------------------------------
C
C
      CHARACTER*1  BASE
      CHARACTER*8  KBID
      CHARACTER*14 NU
      CHARACTER*8  NOMO,MATERI,CARA
      CHARACTER*24 MATE
      CHARACTER*8 VPROF,NOMCAS
      CHARACTER*19 VECAS,VECEL
      INTEGER      IARG
C
      CALL JEMARQ()
C
      BASE = 'V'
      CALL JEVEUO(NOMACR//'.REFM' ,'L',IAREFM)
      NOMO= ZK8(IAREFM-1+1)
      MATERI  = ZK8(IAREFM-1+3)
      IF (MATERI.NE.'        ') THEN
        CALL RCMFMC(MATERI,MATE)
      ELSE
        MATE = ' '
      END IF
      CARA  = ZK8(IAREFM-1+4)
      NU= ZK8(IAREFM-1+5)
      IF (NU(1:8).NE.NOMACR) CALL ASSERT(.FALSE.)
C
      VECEL = '&&VECEL            '
      VECAS = NOMACR//'.CHARMECA'
C
      CALL JEVEUO(NOMACR//'.DESM' ,'E',IADESM)
      CALL JELIRA(NOMACR//'.LICH','LONMAX',NCH,KBID)
      NCH= NCH-1
      VPROF= ' '
      NDDLE= ZI(IADESM-1+4)
      NDDLI= ZI(IADESM-1+5)
      NDDLT= NDDLE+NDDLI
C
C     -- ON VERIFIE LA PRESENCE PARFOIS NECESSAIRE DE CARA_ELEM
C        ET CHAM_MATER :
      CALL GETFAC('CAS_CHARGE',NOCC)
C
      DO 1, IOCC= 1,NOCC
C
        CALL GETVTX('CAS_CHARGE','NOM_CAS',IOCC,IARG,1,NOMCAS,N1)
        CALL JECROC(JEXNOM(NOMACR//'.LICA',NOMCAS))
        CALL JECROC(JEXNOM(NOMACR//'.LICH',NOMCAS))
        CALL JENONU(JEXNOM(NOMACR//'.LICA',NOMCAS),ICAS)
        CALL JEVEUO(JEXNUM(NOMACR//'.LICA',ICAS),'E',IALICA)
        CALL JEVEUO(JEXNUM(NOMACR//'.LICH',ICAS),'E',IALICH)
C
C       -- MISE A JOUR DE .LICH:
C       ------------------------
        CALL GETVTX('CAS_CHARGE','SUIV',IOCC,IARG,1,KBID,N1)
        IF (KBID(1:3).EQ.'OUI') THEN
          ZK8(IALICH-1+1)= 'OUI_SUIV'
        ELSE
          ZK8(IALICH-1+1)= 'NON_SUIV'
        END IF
        CALL GETVID('CAS_CHARGE','CHARGE',IOCC,IARG,0,KBID,N1)
        IF (-N1.GT.NCH) CALL U2MESS('F','SOUSTRUC_40')
        CALL GETVID('CAS_CHARGE','CHARGE',IOCC,IARG,-N1,
     &              ZK8(IALICH+1),N2)
C
C       -- INSTANT:
C       -----------
        CALL GETVR8('CAS_CHARGE','INST',IOCC,IARG,1,TIME,N2)
C
C       -- CALCULS VECTEURS ELEMENTAIRES DU CHARGEMENT :
C       ------------------------------------------------
        CALL ME2MME(NOMO,-N1,ZK8(IALICH+1),
     &         MATE,CARA,.TRUE.,TIME,VECEL,0,BASE)
        CALL SS2MM2(NOMO,VECEL,NOMCAS)
C
C        -- ASSEMBLAGE:
        CALL ASSVEC('V',VECAS,1,VECEL,1.0D0,NU,VPROF,'ZERO',1)
C
C       -- RECOPIE DE VECAS.VALE DANS .LICA(1:NDDLT) :
        CALL JEVEUO(VECAS//'.VALE','L',IAVALE)
        DO 11 KK=1,NDDLT
          ZR(IALICA-1+KK)=ZR(IAVALE-1+KK)
 11     CONTINUE
C
C       -- CONDENSATION DE .LICA(1:NDDLT) DANS .LICA(NDDLT+1,2*NDDLT) :
        CALL SSVAU1(NOMACR,IALICA,IALICA+NDDLT)
C
C       -- ON COMPTE LES CAS DE CHARGE EFFECTIVEMENT CALCULES:
        ZI(IADESM-1+7) = ICAS
C
        CALL JEDETC(' ',VECEL,1)
        CALL JEDETC(' ',VECAS,1)
 1    CONTINUE
C
C
      CALL JEDEMA()
      END
