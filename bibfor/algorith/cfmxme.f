      SUBROUTINE CFMXME(NOMA  ,NUMEDD,SDDYNA,DEFICO,RESOCO)
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
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      CHARACTER*8  NOMA
      CHARACTER*24 NUMEDD
      CHARACTER*19 SDDYNA
      CHARACTER*24 DEFICO,RESOCO
C
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODES CONTINUE)
C
C CREATION SD DE RESOLUTION RESOCO
C
C ----------------------------------------------------------------------
C
C
C IN  NOMA   : NOM DU MAILLAGE
C IN  NUMEDD : NUME_DDL DE LA MATRICE TANGENTE GLOBALE
C IN  SDDYNA : SD DYNAMIQUE
C IN  DEFICO : SD POUR LA DEFINITION DE CONTACT
C IN  RESOCO : SD POUR LA RESOLUTION DE CONTACT
C
C
C
C
      INTEGER      IFM,NIV
      CHARACTER*8  K8BID
      INTEGER      IRET  ,NEQ   ,NTPC
      LOGICAL      NDYNLO,LDYNA ,CFDISL,LNOEU 
      CHARACTER*24 MDECOL,ETATCT
      INTEGER      JMDECO,JETAT
      CHARACTER*24 TABFIN,APJEU
      INTEGER      JTABF,JAPJEU
      CHARACTER*24 VITINI,ACCINI
      CHARACTER*24 JEUSUR
      INTEGER      JUSU
      CHARACTER*24 CYCLIS,CYCNBR,CYCTYP,CYCPOI,CYCGLI
      INTEGER      JCYLIS,JCYNBR,JCYTYP,JCYPOI,JCYGLI
      INTEGER      CFDISI
      INTEGER      CFMMVD,ZTABF,ZETAT
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFDBG('CONTACT',IFM,NIV)
C
C --- AFFICHAGE
C
      IF (NIV.GE.2) THEN
        WRITE (IFM,*) '<CONTACT> ... CREATION DES SD POUR LA '//
     &                ' FORMULATION CONTINUE'
      ENDIF
C
C --- INITIALISATIONS
C
      CALL DISMOI('F','NB_EQUA',NUMEDD,'NUME_DDL',NEQ,K8BID,IRET)
      NTPC   = CFDISI(DEFICO,'NTPC'     )
      LDYNA  = NDYNLO(SDDYNA,'DYNAMIQUE')
C
C --- TABLEAU CONTENANT LES INFORMATIONS DIVERSES
C
      TABFIN = RESOCO(1:14)//'.TABFIN'
      ZTABF  = CFMMVD('ZTABF')
      CALL WKVECT(TABFIN,'V V R',ZTABF*NTPC+1,JTABF)
      ZR(JTABF) = NTPC
C
C --- GESTION AUTOMATIQUE DES RELATIONS REDONDANTES
C
      CALL MMREDO(NUMEDD,DEFICO,RESOCO)
C
C --- CREATION DES CARTES D'USURE
C
      CALL MMUSUC(NOMA  ,DEFICO,RESOCO)
C
C --- CREATION INDICATEUR DE DECOLLEMENT DANS COMPLIANCE
C
      MDECOL = RESOCO(1:14)//'.MDECOL'
      CALL WKVECT(MDECOL,'V V L',1,JMDECO)
      ZL(JMDECO+1-1) = .FALSE.
C
C --- VECTEUR POUR LA DYNAMIQUE A L INSTANT MOINS
C --- UTILE UNIQUEMENT AFIN D ARCHIVER LE DERNIER INSTANT CALCULE
C --- SI PLANTE POUR LE NOUVEAU PAS DE TEMPS DANS
C --- LES ITERATIONS DE NEWTON
C
      IF (LDYNA) THEN
        VITINI = RESOCO(1:14)//'.VITI'
        ACCINI = RESOCO(1:14)//'.ACCI'
        CALL VTCREB(VITINI,NUMEDD,'V','R',NEQ   )
        CALL VTCREB(ACCINI,NUMEDD,'V','R',NEQ   )
      ENDIF
C
C --- OBJET DE SAUVEGARDE DE L ETAT DE CONTACT
C
      ZETAT  = CFMMVD('ZETAT')
      ETATCT = RESOCO(1:14)//'.ETATCT'
      CALL WKVECT(ETATCT,'V V R',ZETAT*NTPC,JETAT)
C
C --- JEU SUPPLEMENTAIRE POUR USURE
C
      JEUSUR = RESOCO(1:14)//'.JEUSUR'
      CALL WKVECT(JEUSUR,'V V R',NTPC  ,JUSU  )
C
C --- DETECTION DE CYCLAGE
C
      CYCLIS = RESOCO(1:14)//'.CYCLIS'
      CYCNBR = RESOCO(1:14)//'.CYCNBR'
      CYCTYP = RESOCO(1:14)//'.CYCTYP'
      CYCPOI = RESOCO(1:14)//'.CYCPOI'
      CYCGLI = RESOCO(1:14)//'.CYCGLI'
      CALL WKVECT(CYCLIS,'V V I'  ,4*NTPC,JCYLIS)
      CALL WKVECT(CYCNBR,'V V I'  ,4*NTPC,JCYNBR)
      CALL WKVECT(CYCTYP,'V V I'  ,4*NTPC,JCYTYP)
      CALL WKVECT(CYCPOI,'V V K16',4*NTPC,JCYPOI)
      CALL WKVECT(CYCGLI,'V V R'  ,3*NTPC,JCYGLI)
C
C --- JEU TOTAL
C
      APJEU  = RESOCO(1:14)//'.APJEU'
      CALL WKVECT(APJEU ,'V V R',NTPC  ,JAPJEU)
C
C --- TOUTES LES ZONES EN INTEGRATION AUX NOEUDS ?
C
      LNOEU = CFDISL(DEFICO,'ALL_INTEG_NOEUD')
      IF (.NOT.LNOEU) THEN
        CALL U2MESS('A','CONTACT3_16')
      ENDIF
C
      CALL JEDEMA()
      END
