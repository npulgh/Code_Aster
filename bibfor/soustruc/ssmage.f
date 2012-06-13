      SUBROUTINE SSMAGE(NOMU,OPTION)
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
      CHARACTER*8 NOMU
      CHARACTER*9 OPTION
C ----------------------------------------------------------------------
C     BUT: TRAITER LE MOT CLEF "MASS_MECA" (RESP. "AMOR_MECA")
C             DE L'OPERATEUR MACR_ELEM_STAT
C           CALCULER LA MATRICE DE MASSE (OU AMORTISSEMENT)
C           CONDENSEE DU MACR_ELEM_STAT.
C
C     IN: NOMU   : NOM DU MACR_ELEM_STAT
C         OPTION : 'MASS_MECA' OU 'AMOR_MECA'
C
C     OUT: LES OBJETS SUIVANTS DU MACR_ELEM_STAT SONT CALCULES:
C           / NOMU.MAEL_MASS_VALE (SI MASS_MECA)
C           / NOMU.MAEL_AMOR_VALE (SI AMOR_MECA)
C
C ----------------------------------------------------------------------
C
C
      INTEGER      NCHACI,IBID,IER
      REAL*8       TIME
      CHARACTER*1  BASE
      CHARACTER*8   NOMO, CARA, MATERI, MATEL, PROMES
      CHARACTER*14 NU
      CHARACTER*19 MATAS
      CHARACTER*24 MATE, COMPOR
      CALL JEMARQ()
C
C --- ON CREER LES OBJETS DE TRAVAIL SUR LA VOLATILE
      BASE = 'V'
C
      CALL JEVEUO(NOMU//'.REFM' ,'E',IAREFM)
      NOMO   = ZK8(IAREFM-1+1)
      CARA   = ZK8(IAREFM-1+4)
      MATERI = ZK8(IAREFM-1+3)
C
      IF ( MATERI .EQ. '        ' ) THEN
         MATE = ' '
      ELSE
         CALL RCMFMC ( MATERI , MATE )
      ENDIF
      NU= ZK8(IAREFM-1+5)
      IF (NU(1:8).NE.NOMU) CALL ASSERT(.FALSE.)
C
      MATEL = '&&MATEL'
      IF (OPTION.EQ.'MASS_MECA') THEN
        MATAS = NOMU//'.MASSMECA'
      ELSE IF (OPTION.EQ.'AMOR_MECA') THEN
        MATAS = NOMU//'.AMORMECA'
      ELSE
        CALL ASSERT(.FALSE.)
      END IF
C
      CALL JEVEUO(NOMU//'.DESM' ,'L',JDESM)
      NCHACI = ZI(JDESM-1+6)
C
C
      CALL JEVEUO(NOMU//'.VARM' ,'L',JVARM)
      TIME = ZR(JVARM-1+2)
C
C     -- CALCULS MATRICES ELEMENTAIRES DE MASSE (OU AMORTISSEMENT):
      IF (OPTION.EQ.'MASS_MECA') THEN
         COMPOR = ' '
         CALL MEMAME('MASS_MECA  ',NOMO,NCHACI,ZK8(IAREFM-1+9+1),
     &                     MATE,CARA,.TRUE.,TIME,COMPOR,MATEL,BASE)
      ELSE IF (OPTION.EQ.'AMOR_MECA') THEN
         CALL DISMOI('F','NOM_PROJ_MESU',NOMU,'MACR_ELEM_STAT',IBID,
     &            PROMES,IER)
C     --  CAS MODIFICATION STRUCTURALE : CREATION MATRICE PAR SSMAU2
         IF (PROMES.EQ.' ') CALL U2MESS('F','SOUSTRUC_69')
      ELSE
         CALL U2MESS('F','SOUSTRUC_69')
      END IF
C
C        -- ASSEMBLAGE:
      IF (OPTION.EQ.'MASS_MECA') THEN
        CALL ASSMAM('G',MATAS,1,MATEL,1.0D0,NU,'ZERO',1)
C       -- IL FAUT COMPLETER LA MATRICE SI LES CALCULS SONT DISTRIBUES:
        CALL SDMPIC('MATR_ASSE',MATAS)
        CALL UALFCR(MATAS,'G')
      END IF
      CALL SSMAU2(NOMU,OPTION)
C
C        -- MISE A JOUR DE .REFM(7) OU REFM(8)
      IF (OPTION.EQ.'MASS_MECA') THEN
        ZK8(IAREFM-1+7)='OUI_MASS'
      ELSE IF (OPTION.EQ.'AMOR_MECA') THEN
        ZK8(IAREFM-1+8)='OUI_AMOR'
      ELSE
         CALL U2MESS('F','SOUSTRUC_69')
      END IF
C
      IF (OPTION.EQ.'MASS_MECA') THEN
        CALL JEDETC(' ',MATEL,1)
      END IF
      CALL JEDEMA()
C
      END
