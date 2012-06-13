      SUBROUTINE VEFNME(MODELE,SIGMA ,CARAZ ,DEPMOI,DEPDEL,
     &                  VECELZ,MATCOD,COMPOR,NH    ,FNOEVO,
     &                  PARTPS,CARCRI,CHVARC,LIGREZ,LISCHA,
     &                  OPTION,STRX)
C
C MODIF ALGORITH  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
C ======================================================================
C            CONFIGURATION MANAGEMENT OF EDF VERSION
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
C RESPONSABLE ABBAS M.ABBAS
C
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      LOGICAL       FNOEVO
      REAL*8        PARTPS(*)
      CHARACTER*(*) MODELE,LIGREZ,LISCHA
      CHARACTER*(*) SIGMA,CARAZ,DEPMOI,DEPDEL,VECELZ
      CHARACTER*(*) MATCOD,COMPOR,CARCRI,CHVARC,STRX
      CHARACTER*16  OPTION
      INTEGER       NH
C
C ----------------------------------------------------------------------
C
C ROUTINE CALCUL
C
C CALCUL DES VECTEURS ELEMENTAIRES (FORC_NODA)
C
C ----------------------------------------------------------------------
C
C
C IN  MODELE : NOM DU MODELE (NECESSAIRE SI SIGMA EST UNE CARTE)
C IN  SIGMA  : NOM DU CHAM_ELEM (OU DE LA CARTE) DE CONTRAINTES
C IN  CARA   : NOM DU CARA_ELEM
C IN  DEPMOI : NOM DU CHAM_NO DE DEPLACEMENTS PRECEDENTS
C IN  DEPDEL : NOM DU CHAM_NO D'INCREMENT DEPLACEMENTS
C IN  MATCOD : NOM DU MATERIAU CODE
C IN  COMPOR : NOM DE LA CARTE DE COMPORTEMENT
C IN  NH     : NUMERO D'HARMONIQUE DE FOURIER
C IN  FNOEVO : VRAI SI FORCES NODALES EVOLUTIVES I E INSTANT PLUS ET
C              MOINS NECESSAIRES 5 STAT NON LINE TRAITANT DES PROBLEMES
C              PARABOLIQUES : APPLICATION A THM
C IN  PARTPS : INSTANT PRECEDENT, ACTUEL ET THETA
C IN  CARCRI : CARTE DES CRITERES ET DE THETA
C IN  CHVARC : NOM DU CHAMP DE VARIABLE DE COMMANDE
C IN  LIGREZ : (SOUS-)LIGREL DE MODELE POUR CALCUL REDUIT
C                  SI ' ', ON PREND LE LIGREL DU MODELE
C OUT VECELZ : VECT_ELEM RESULTAT.
C
C
C
C
      INTEGER      NBOUT,NBIN
      PARAMETER    (NBOUT=1, NBIN=33)
      CHARACTER*8  LPAOUT(NBOUT),LPAIN(NBIN)
      CHARACTER*19 LCHOUT(NBOUT),LCHIN(NBIN)
C
      CHARACTER*8  K8BLA,MAILLA,CARELE
      CHARACTER*19 LIGREL,LISCH2
      CHARACTER*8  NEWNOM
      CHARACTER*19 NUMHAR,TPSMOI,TPSPLU
      CHARACTER*19 CHGEOM,CHCARA(18),VECELE
      CHARACTER*24 CHPESA
      CHARACTER*16 OPTIO2
      LOGICAL      LBID
      INTEGER      IRET,IBID,IED,NCHAR,JCHAR,IER
      REAL*8       INSTM,INSTP,RBID
      COMPLEX*16   CBID
      CHARACTER*19 PINTTO,CNSETO,HEAVTO,LONCHA,BASLOC,LSN,LST,STANO
      CHARACTER*19 PMILTO,FISSNO
      LOGICAL      DEBUG
      INTEGER      IFMDBG,NIVDBG
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFDBG('PRE_CALCUL',IFMDBG,NIVDBG)
C
C --- INITIALISATIONS
C
      NEWNOM = '.0000000'
      CARELE = CARAZ
      VECELE = VECELZ
      LIGREL = LIGREZ
      NUMHAR = '&&VEFNME.NUME_HARM'
      TPSMOI = '&&VEFNME.CH_INSTAM'
      TPSPLU = '&&VEFNME.CH_INSTAP'
      K8BLA  = ' '
      OPTIO2 = OPTION
      IF (OPTION.NE.'FONL_NOEU') OPTIO2 = 'FORC_NODA'
      IF (NIVDBG.GE.2) THEN
        DEBUG  = .TRUE.
      ELSE
        DEBUG  = .FALSE.
      ENDIF
      IF ( DEPMOI.NE.' ' ) THEN
        CALL DISMOI('F','NOM_MAILLA',DEPMOI,'CHAM_NO',IBID,MAILLA,IED)
      ELSEIF ( SIGMA.NE.' ' ) THEN
        CALL DISMOI('F','NOM_MAILLA',SIGMA(1:19),'CHAM_ELEM',
     &              IBID,MAILLA,IED)
      ELSE
        CALL ASSERT(.FALSE.)
      ENDIF
      CHGEOM = MAILLA(1:8)//'.COORDO'
      IF (VECELE.EQ.' ') THEN
        VECELE = '&&VEFNME'
      ENDIF
      IF (LIGREL.EQ.' ') THEN
        LIGREL = MODELE(1:8)//'.MODELE'
      ENDIF
      CHPESA = ' '
      LISCH2 = LISCHA
C
C --- CARTE POUR LA PESANTEUR
C
      CALL JEEXIN(LISCH2//'.LCHA',IRET)
      IF (IRET.NE.0) THEN
        CALL JELIRA(LISCH2//'.LCHA','LONMAX',NCHAR,K8BLA)
        CALL JEVEUO(LISCH2//'.LCHA','L',JCHAR)
        CALL MECHPE(MODELE(1:8),NCHAR,ZK24(JCHAR),CHPESA)
      END IF
C
C --- CARTE POUR LES CARA. ELEM.
C
      CALL MECARA(CARELE(1:8),LBID  ,CHCARA)
C
C --- CARTE POUR LES HARMONIQUES DE FOURIER
C
      CALL MECACT('V',NUMHAR,'MAILLA',MAILLA,'HARMON',1,
     &            'NH',NH,RBID,CBID,K8BLA)
C
C --- CARTE DES INSTANTS POUR THM
C
      IF ( FNOEVO) THEN
        INSTM = PARTPS(1)
        INSTP = PARTPS(2)
        CALL MECACT('V',TPSMOI,'MAILLA',MAILLA,
     &              'INST_R',1,'INST',IBID,INSTM,CBID,K8BLA)
        CALL MECACT('V',TPSPLU,'MAILLA',MAILLA,
     &              'INST_R',1,'INST',IBID,INSTP,CBID,K8BLA)
      ENDIF
C
C --- INITIALISATION DES CHAMPS POUR CALCUL
C
      CALL INICAL(NBIN  ,LPAIN ,LCHIN ,
     &            NBOUT ,LPAOUT,LCHOUT)
C
C --- CREATION DES LISTES DES CHAMPS IN
C
      LPAIN(1)  = 'PGEOMER'
      LCHIN(1)  = CHGEOM
      LPAIN(2)  = 'PMATERC'
      LCHIN(2)  = MATCOD
      LPAIN(3)  = 'PCAGNPO'
      LCHIN(3)  = CHCARA(6)
      LPAIN(4)  = 'PCAORIE'
      LCHIN(4)  = CHCARA(1)
      LPAIN(5)  = 'PCOMPOR'
      LCHIN(5)  = COMPOR
      LPAIN(6)  = 'PCONTMR'
      LCHIN(6)  = SIGMA
      LPAIN(7)  = 'PDEPLMR'
      LCHIN(7)  = DEPMOI
      LPAIN(8)  = 'PDEPLPR'
      LCHIN(8)  = DEPDEL
      LPAIN(9)  = 'PCAARPO'
      LCHIN(9)  = CHCARA(9)
      LPAIN(10) = 'PCADISK'
      LCHIN(10) = CHCARA(2)
      LPAIN(11) = 'PCACOQU'
      LCHIN(11) = CHCARA(7)
      LPAIN(12) = 'PHARMON'
      LCHIN(12) = NUMHAR
      LPAIN(13) = 'PCAMASS'
      LCHIN(13) = CHCARA(12)
      LPAIN(14) = 'PCARCRI'
      LCHIN(14) = CARCRI
      LPAIN(15) = 'PINSTMR'
      LCHIN(15) = TPSMOI
      LPAIN(16) = 'PINSTPR'
      LCHIN(16) = TPSPLU
      LPAIN(17) = 'PVARCPR'
      LCHIN(17) = CHVARC
      LPAIN(18) = 'PCAGEPO'
      LCHIN(18) = CHCARA(5)
      LPAIN(19) = 'PNBSP_I'
      LCHIN(19) = CHCARA(16)
      LPAIN(20) = 'PFIBRES'
      LCHIN(20) = CHCARA(17)
      LPAIN(21) = 'PPESANR'
      LCHIN(21) = CHPESA
C
C --- CADRE X-FEM
C
      CALL EXIXFE(MODELE,IER)
      IF (IER.NE.0) THEN
        PINTTO =MODELE(1:8)//'.TOPOSE.PIN'
        CNSETO =MODELE(1:8)//'.TOPOSE.CNS'
        HEAVTO =MODELE(1:8)//'.TOPOSE.HEA'
        LONCHA =MODELE(1:8)//'.TOPOSE.LON'
        PMILTO =MODELE(1:8)//'.TOPOSE.PMI'
        BASLOC =MODELE(1:8)//'.BASLOC'
        LSN    =MODELE(1:8)//'.LNNO'
        LST    =MODELE(1:8)//'.LTNO'
        STANO  = MODELE(1:8)//'.STNO'
        FISSNO = MODELE(1:8)//'.FISSNO'
      ELSE
        PINTTO = '&&VEFNME.PINTTO.BID'
        CNSETO = '&&VEFNME.CNSETO.BID'
        HEAVTO = '&&VEFNME.HEAVTO.BID'
        LONCHA = '&&VEFNME.LONCHA.BID'
        BASLOC = '&&VEFNME.BASLOC.BID'
        PMILTO = '&&VEFNME.PMILTO.BID'
        LSN    = '&&VEFNME.LNNO.BID'
        LST    = '&&VEFNME.LTNO.BID'
        STANO  = '&&VEFNME.STNO.BID'
        FISSNO = '&&VEFNME.FISSNO.BID'
      ENDIF

      LPAIN(22) = 'PPINTTO'
      LCHIN(22) = PINTTO
      LPAIN(23) = 'PCNSETO'
      LCHIN(23) = CNSETO
      LPAIN(24) = 'PHEAVTO'
      LCHIN(24) = HEAVTO
      LPAIN(25) = 'PLONCHA'
      LCHIN(25) = LONCHA
      LPAIN(26) = 'PBASLOR'
      LCHIN(26) = BASLOC
      LPAIN(27) = 'PLSN'
      LCHIN(27) = LSN
      LPAIN(28) = 'PLST'
      LCHIN(28) = LST
      LPAIN(29) = 'PSTANO'
      LCHIN(29) = STANO
      LPAIN(30) = 'PCINFDI'
      LCHIN(30) = CHCARA(15)
      LPAIN(31) = 'PPMILTO'
      LCHIN(31) = PMILTO
      LPAIN(32) = 'PFISNO'
      LCHIN(32) = FISSNO
      LPAIN(33) = 'PSTRXMR'
      LCHIN(33) = STRX
C
C --- CREATION DES LISTES DES CHAMPS OUT
C
      LPAOUT(1) = 'PVECTUR'
      CALL GCNCO2(NEWNOM)
      LCHOUT(1) = '&&VEFNME.???????'
      LCHOUT(1)(10:16) = NEWNOM(2:8)
      CALL CORICH('E',LCHOUT(1),-1,IBID)
C
C --- PREPARATION DU VECT_ELEM RESULTAT
C
      CALL DETRSD('VECT_ELEM',VECELE)
      CALL MEMARE('V',VECELE,MODELE,' ',CARELE,'CHAR_MECA')

      IF (DEBUG) THEN
        CALL DBGCAL(OPTIO2,IFMDBG,
     &              NBIN  ,LPAIN ,LCHIN ,
     &              NBOUT ,LPAOUT,LCHOUT)
      ENDIF

C
C --- APPEL A CALCUL
C
      CALL CALCUL('S',OPTIO2,LIGREL,NBIN ,LCHIN ,LPAIN ,
     &                       NBOUT,LCHOUT,LPAOUT,'V','OUI')
C

C
      CALL REAJRE(VECELE,LCHOUT(1),'V')
C
      VECELZ = VECELE//'.RELR'
C
C --- MENAGE
C
      CALL DETRSD('CHAMP_GD',NUMHAR)
      CALL DETRSD('CHAMP_GD',TPSMOI)
      CALL DETRSD('CHAMP_GD',TPSPLU)
      CALL JEDEMA()
      END
