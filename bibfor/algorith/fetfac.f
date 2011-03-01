      SUBROUTINE FETFAC(LMAT,MATAS,IDD,NPREC,NBSD,MATASS,SDFETI,NBSDF,
     &                  BASE,INFOFE)
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 01/03/2011   AUTEUR PELLET J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2011  EDF R&D                  WWW.CODE-ASTER.ORG
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
C-----------------------------------------------------------------------
C    - FONCTION REALISEE:  RECHERCHE DES MODES DE CORPS RIGIDES ET REM
C      PLISSAGE DES OBJETS JEVEUX AD HOC POUR FETI.
C
C      IN   LMAT: IN  : DESCRIPTEUR DE LA MATRICE DE RIGIDITE LOCALE
C      IN  MATAS: K19 : NOM DE LA MATRICE DE RIGIDITE LOCALE
C      IN    IDD: IN  : NUMERO DU SOUS-DOMAINE
C      IN  NPREC: IN  : PARAMETRE STIPULANT LA QUASI-NULLITE DU PIVOT
C      IN   NBSD: IN  : NBRE DE SOUS-DOMAINES
C      IN MATASS: K19 : MATRICE DE RIGIDITE GLOBALE
C      IN SDFETI: K24 : STRUCTURE DE DONNEES SD_FETI
C   IN/OUT NBSDF:  IN : NBRE DE SOUS-DOMAINES FLOTTANTS
C      IN   BASE:  K1 : BASE SUR LAQUELLE EST CREE LA MATR_ASSE
C      IN INFOFE: K24 : VECTEUR DE MONITORING POUR FETI
C----------------------------------------------------------------------
C RESPONSABLE BOITEAU O.BOITEAU
C CORPS DU PROGRAMME
      IMPLICIT NONE

C DECLARATION PARAMETRES D'APPELS
      INTEGER      LMAT,IDD,NBSD,NPREC,NBSDF
      CHARACTER*1  BASE
      CHARACTER*19 MATAS,MATASS
      CHARACTER*24 SDFETI,INFOFE

C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
      INTEGER            ZI
      COMMON  / IVARJE / ZI(1)
      REAL*8             ZR
      COMMON  / RVARJE / ZR(1)
      COMPLEX*16         ZC
      COMMON  / CVARJE / ZC(1)
      CHARACTER*8        ZK8
      CHARACTER*16                ZK16
      CHARACTER*24                          ZK24
      CHARACTER*32                                    ZK32
      CHARACTER*80                                              ZK80
      COMMON  / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) , ZK80(1)
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------

C DECLARATION VARIABLES LOCALES
      INTEGER      IFM,NIV,NBMOCR,I,JADR,KADR,NEQ,NAUX,IUNIFI,IFR,
     &             IFETF,IEXIST,IREFA,IBID
      CHARACTER*8  NOMSD,K8BID
      CHARACTER*19 VEMOCR,VEINPN,K19BID
      CHARACTER*24 NOMSDF,NOMSDP,NOMSDA,NOMSDR,K24NUM
      CHARACTER*32 JEXNOM,JEXNUM
      LOGICAL      LBID

C CORPS DU PROGRAMME
      CALL JEMARQ()

C RECUPERATION DU NIVEAU D'IMPRESSION
      CALL INFNIV(IFM,NIV)

C INIT. NOMS OBJETS JEVEUX
      NOMSDP=MATASS//'.FETP'
      NOMSDR=MATASS//'.FETR'
      NOMSDA=SDFETI(1:19)//'.FETA'

C NOM DU SOUS-DOMAINE
      CALL JENUNO(JEXNUM(NOMSDA,IDD),NOMSD)
C NBRE DE DDLS
      NEQ=ZI(LMAT+2)
      NOMSDF=MATASS//'.FETF'

      CALL JEEXIN(NOMSDF,IEXIST)
      IF (IEXIST.EQ.0) THEN
C MATASS.FETF
        CALL WKVECT(NOMSDF,BASE(1:1)//' V I',NBSD,IFETF)
        DO 10 I=1,NBSD
          ZI(IFETF+I-1)=0
   10   CONTINUE

C MATASS.FETP/.FETR
        CALL JECREC(NOMSDP,BASE(1:1)//' V I','NO','DISPERSE',
     &    'VARIABLE',NBSD)
        CALL JECREC(NOMSDR,BASE(1:1)//' V R','NO','DISPERSE',
     &    'VARIABLE',NBSD)
      ELSE
        CALL JEVEUO(NOMSDF,'E',IFETF)
      ENDIF

C VEMOCR: MATRICE DES MODES DE CORPS RIGIDES
      VEMOCR = '&&FETFAC.FETI.MOCR'
      VEINPN = '&&FETFAC.FETI.INPN'
C RECHERCHE DES MODES DE CORPS RIGIDES DANS LA MATRICE LMAT
      CALL TLDLG2(LMAT,NPREC,NBMOCR,VEMOCR,'FETI',VEINPN)

C RANGEMENT DANS LES STRUCTURES DE DONNEES
      IF (NBMOCR.NE.0) THEN
C PRESENCE DE MODES DE CORPS RIGIDES
        NBSDF=NBSDF+1
C MATASS.FETF
        ZI(IFETF+IDD-1)=NBMOCR
C MATASS.FETP
        CALL JECROC(JEXNOM(NOMSDP,NOMSD))
        CALL JEECRA(JEXNOM(NOMSDP,NOMSD),'LONMAX',NBMOCR,K8BID)
        CALL JEVEUO(JEXNOM(NOMSDP,NOMSD),'E',JADR)
C VEINPN: VECTEUR DES INDICES DE PIVOTS QUASI NULS
        CALL JEVEUO(VEINPN,'L',KADR)
        DO 30 I=1,NBMOCR
          ZI(JADR+I-1)=ZI(KADR+I-1)
   30   CONTINUE
C MATASS.FETR
        NAUX=NEQ*NBMOCR
        CALL JEVEUO(VEMOCR,'L',KADR)
        CALL JECROC(JEXNOM(NOMSDR,NOMSD))
        CALL JEECRA(JEXNOM(NOMSDR,NOMSD),'LONMAX',NAUX,K8BID)
        CALL JEVEUO(JEXNOM(NOMSDR,NOMSD),'E',JADR)
        DO 40 I=1,NAUX
          ZR(JADR+I-1)=ZR(KADR+I-1)
   40   CONTINUE
      ENDIF

C NOM DU NUME_DDL ASSOCIE A LA MATRICE LOCALE POUR IMPRESSIONS
C FICHIER SI INFO_FETI(15:15)='T'
      CALL JEVEUO(MATAS//'.REFA','L',IREFA)
      K24NUM=ZK24(IREFA+1)
      CALL FETTSD(INFOFE,IDD,NAUX,IBID,SDFETI(1:19),K24NUM,NBMOCR,KADR,
     &            IBID,IFM,LBID,IBID,IBID,IBID,K19BID,10,LBID)
C MONITORING
      IFR=IUNIFI('MESSAGE')
      IF (INFOFE(1:1).EQ.'T')
     &  WRITE(IFM,*)'<FETI/FETFAC> SD: ',IDD,' ',MATAS(1:19)
      IF (INFOFE(3:3).EQ.'T')
     &  CALL UTIMSD(IFR,2,.FALSE.,.TRUE.,MATAS(1:19),1,' ')
      IF ((INFOFE(3:3).EQ.'T').AND.(IDD.EQ.NBSD))
     &  CALL UTIMSD(IFR,2,.FALSE.,.TRUE.,MATASS(1:19),1,' ')

      CALL JEDETR('&&FETFAC.FETI.MOCR')
      CALL JEDETR('&&FETFAC.FETI.INPN')
      CALL JEDEMA()
      END
