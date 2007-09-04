      SUBROUTINE CALCUL(STOP,OPTIO,LIGRLZ,NIN,LCHIN,LPAIN,NOU,LCHOU,
     &                  LPAOU,BASE)

      IMPLICIT NONE

C MODIF CALCULEL  DATE 04/09/2007   AUTEUR DURAND C.DURAND 
C ======================================================================
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE                            VABHHTS J.PELLET
C     ARGUMENTS:
C     ----------
      INTEGER NIN,NOU
      CHARACTER*(*) BASE,OPTIO
      CHARACTER*(*) LCHIN(*),LCHOU(*),LPAIN(*),LPAOU(*),LIGRLZ
C ----------------------------------------------------------------------
C     ENTREES:
C        STOP   :  /'S' : ON S'ARRETE SI AUCUN ELEMENT FINI DU LIGREL
C                         NE SAIT CALCULER L'OPTION.
C                  /'C' : ON CONTINUE SI AUCUN ELEMENT FINI DU LIGREL
C                         NE SAIT CALCULER L'OPTION. IL N'EXISTE PAS DE
C                         CHAMP "OUT" DANS CE CAS.
C        OPTIO  :  NOM D'1 OPTION
C        LIGRLZ :  NOM DU LIGREL SUR LEQUEL ON DOIT FAIRE LE CALCUL
C        NIN    :  NOMBRE DE CHAMPS PARAMETRES "IN"
C        NOU    :  NOMBRE DE CHAMPS PARAMETRES "OUT"
C        LCHIN  :  LISTE DES NOMS DES CHAMPS "IN"
C        LCHOU  :  LISTE DES NOMS DES CHAMPS "OUT"
C        LPAIN  :  LISTE DES NOMS DES PARAMETRES "IN"
C        LPAOU  :  LISTE DES NOMS DES PARAMETRES "OUT"
C        BASE   :  'G' , 'V' OU 'L'

C     SORTIES:
C       ALLOCATION ET CALCUL DES OBJETS CORRESPONDANT AUX CHAMPS "OUT"

C ----------------------------------------------------------------------
      LOGICAL      LFETMO,LFETIC,LFETTS,LFETTD
      CHARACTER*24 K24B,INFOFE,VALK(2),KFEL,KCAL
      REAL*8       RBID,TEMPS(6)
      CHARACTER*19 LCHIN2(NIN),LCHOU2(NOU)
      CHARACTER*8 LPAIN2(NIN),LPAOU2(NOU),K8BID
      CHARACTER*19 LIGREL,K19B
      CHARACTER*1 STOP
      INTEGER IACHII,IACHIK,IACHIX,IADSGD,IBID,NBPROC,IFETI1,IFETI2,IIEL
      INTEGER IALIEL,IAMACO,IAMLOC,IAMSCO,IANOOP,IANOTE,IAOBTR,IAUX1,IDD
      INTEGER IAOPDS,IAOPMO,IAOPNO,IAOPPA,IAOPTT,IMA,IFCPU,RANG,IFM,NIV
      INTEGER IER,ILLIEL,ILMACO,ILMLOC,ILMSCO,ILOPMO,IINF,IRET1,IFEL1
      INTEGER ILOPNO,IPARG,IPARIN,IRET,IUNCOD,J,LGCO,IFEL2,IRET2,ILIMPI
      INTEGER NPARIO,NBOBMX,NPARIN,NBSD
      INTEGER NBGREL,TYPELE,NBELEM,NUCALC
      INTEGER NBPARA,NBOBTR,NVAL,INDIK8
      CHARACTER*32 JEXNOM,JEXNUM,PHEMOD
      CHARACTER*8 NOPARA
      INTEGER OPT,AFAIRE,INPARA
      INTEGER NGREL,IEL,NUMC
      INTEGER NPIN,I,IPAR,NIN2,NIN3,NOU2,NOU3,JTYPMA
      CHARACTER*8 NOMPAR,CAS
      CHARACTER*1 BASE2,KBID
      COMMON /CAII02/IAOPTT,LGCO,IAOPMO,ILOPMO,IAOPNO,ILOPNO,IAOPDS,
     &       IAOPPA,NPARIO,NPARIN,IAMLOC,ILMLOC,IADSGD
      COMMON /CAII03/IAMACO,ILMACO,IAMSCO,ILMSCO,IALIEL,ILLIEL
      COMMON /CAII04/IACHII,IACHIK,IACHIX
      COMMON /CAII05/IANOOP,IANOTE,NBOBTR,IAOBTR,NBOBMX
      CHARACTER*16 OPTION,NOMTE,NOMTM,PHENO,MODELI
      COMMON /CAKK01/OPTION,NOMTE,NOMTM,PHENO,MODELI
      INTEGER        IAWLOC,IAWTYP,NBELGR,IGR,JCTEAT,LCTEAT
      COMMON /CAII06/IAWLOC,IAWTYP,NBELGR,IGR,JCTEAT,LCTEAT
      COMMON /CAII08/IEL
      INTEGER NBOBJ,IAINEL,ININEL
      COMMON /CAII09/NBOBJ,IAINEL,ININEL

      INTEGER NUTE,JNBELR,JNOELR,IACTIF,JPNLFP,JNOLFP,NBLFPG
      COMMON /CAII11/NUTE,JNBELR,JNOELR,IACTIF,JPNLFP,JNOLFP,NBLFPG

      INTEGER CAINDZ(512),CAPOIZ
      COMMON /CAII12/CAINDZ,CAPOIZ

C     -- FONCTIONS FORMULES :
C     NUMAIL(IGR,IEL)=NUMERO DE LA MAILLE ASSOCIEE A L'ELEMENT IEL
C      NUMAIL(IGR,IEL) = ZI(IALIEL-1+ZI(ILLIEL-1+IGR)-1+IEL)

C---------------- COMMUNS NORMALISES  JEVEUX  --------------------------
      COMMON /IVARJE/ZI(1)
      COMMON /RVARJE/ZR(1)
      COMMON /CVARJE/ZC(1)
      COMMON /LVARJE/ZL(1)
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      INTEGER ZI
      REAL*8 ZR
      COMPLEX*16 ZC
      LOGICAL ZL,EXICH,DBG
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80

C DEB-------------------------------------------------------------------

      CALL JEMARQ()
      IACTIF = 1
      DO 10 I = 1,512
        CAINDZ(I) = 1
   10 CONTINUE
      CALL MECOEL()

      LIGREL = LIGRLZ
      BASE2 = BASE
      OPTION = OPTIO
      CALL INFNIV(IFM,NIV)


C     SI DBG=.TRUE. ON FAIT DES IMPRESSIONS POUR LE DEBUG :
C     ----------------------------------------------------
      DBG = .FALSE.


C    POUR SAVOIR SI SOLVEUR FETI PARALLELE OU NON. SI C'EST LE CAS
C    ON TARIT LE VOLUME DE DONNEES.
C    ON NE TRAITE PAS L'OPTION DE CALCUL ELEMENTAIRE SERVANT A
C    DIMENSIONNER DES VECTEURS VARI_R, NSPG_NBVA, CAR ON A BESOIN, PROC
C    PAR PROC, DE RESU_ELEM DIMENSIONNES GLOBALEMENT MEME SI ILS SONT
C    REMPLIS QUE PARTIELLEMENT
C     -----------------------------------------------------------------
      LFETMO=.FALSE.
      LFETTS=.FALSE.
      LFETTD=.FALSE.
      LFETIC=.FALSE.
      K19B='                    '
      KCAL='&CALCUL.FETI.NUMSD'
      CALL JEEXIN('&FETI.MAILLE.NUMSD',IRET)
      IF (IRET.NE.0) THEN
C     -- SOLVEUR FETI
C       - CALCUL DU RANG ET DU NBRE DE PROC
        CALL FETMPI(2,IBID,IBID,1,RANG,IBID,K24B,K24B,K24B,RBID)
        CALL FETMPI(3,IBID,IBID,1,IBID,NBPROC,K24B,K24B,K24B,RBID)
C       - ON PROFILE OU PAS ?
        CALL JEVEUO('&FETI.FINF','L',IINF)
        INFOFE=ZK24(IINF)
        IF (INFOFE(11:11).EQ.'T') THEN
          LFETIC=.TRUE.
          CALL JEVEUO('&FETI.INFO.CPU.ELEM','E',IFCPU)
        ENDIF
C       - SI PARALLELISME ET OPTION.NE.'NSPG_NBVA',
C       - ON VA TARIR LE FLOT DE DONNEES
        IF ((NBPROC.GT.1).AND.(OPTION(1:9).NE.'NSPG_NBVA')) THEN
          IF (LIGREL(9:15).EQ.'.MODELE') THEN
C         -    FETI PARALLELE SUR LIGREL DE MODELE
C         -    ON VA DONC TRIER PAR MAILLE PHYSIQUE
            LFETMO=.TRUE.
            CALL JEVEUO('&FETI.MAILLE.NUMSD','L',IFETI1)
            IFETI1=IFETI1-1
          ELSE
C         -    PROBABLEMENT FETI PARALLELE SUR LIGREL TARDIF
C         -    DANS LE DOUTE, ON S'ABSTIENT ET ON FAIT TOUT
            KFEL=LIGREL(1:19)//'.FEL1'
            CALL JEEXIN(KFEL,IRET1)
            IF (IRET1.NE.0) THEN
C         -   LIGREL A MAILLES TARDIVES
              CALL JELIRA(KFEL,'LONMAX',NBSD,K8BID)
              CALL JEVEUO(KFEL,'L',IFEL1)
              CALL JEVEUO('&FETI.LISTE.SD.MPI','L',ILIMPI)
              DO 5 IDD=1,NBSD
                IF (ZI(ILIMPI+IDD).EQ.1) THEN
C         -   LE SOUS-DOMAINE IDD EST CONCERNE PAR CE PROC
                  IF (ZK24(IFEL1+IDD-1)(1:19).EQ.LIGREL(1:19)) THEN
C         -   LIGREL TARDIF CONCENTRE SUR LE SOUS DOMAINE IDD
C         -   IL FAUT TOUT FAIRE
                    LFETTS=.TRUE.
                  ELSE IF (ZK24(IFEL1+IDD-1)(1:19).NE.K19B) THEN
C         -   LIGREL TARDIF DUPLIQUE, NOTAMMENT, SUR LE SOUS DOMAINE IDD
C             POINTE PAR UN .FEL2 (AUTRE QUE LIGREL DE CONTACT INIT)
                    KFEL=LIGREL(1:19)//'.FEL2'
                    CALL JEEXIN(KFEL,IRET2)
                    IF (IRET2.NE.0) THEN
C         -   ON VA TRIER PAR MAILLE TARDIVE, SINON ON FAIT TOUT PAR
C         -   PRUDENCE
                      LFETTD=.TRUE.
                      CALL JEVEUO(KFEL,'L',IFEL2)
                    ENDIF
                  ENDIF
                ENDIF
    5         CONTINUE
C     -- FIN SI IRET1
            ENDIF
C     -- FIN SI MODELE
          ENDIF
          IF ((LFETMO.AND.LFETTS).OR.(LFETMO.AND.LFETTD).OR.
     &       (LFETTS.AND.LFETTD)) CALL U2MESS('F','CALCULEL6_75')
C     -- FIN SI PARALLELE
        ENDIF

C     -- MONITORING
        IF (INFOFE(1:1).EQ.'T') THEN
          WRITE(IFM,*)'<FETI/CALCUL> RANG ',RANG
          WRITE(IFM,*)'<FETI/CALCUL> LIGREL/OPTION ',LIGREL,' ',OPTION
          IF (LFETMO) THEN
            WRITE(IFM,*)'<FETI/CALCUL> LIGREL DE MODELE'
          ELSE IF (LFETTS) THEN
            WRITE(IFM,*)'<FETI/CALCUL> LIGREL TARDIF NON DUPLIQUE'
          ELSE IF (LFETTD) THEN
            WRITE(IFM,*)'<FETI/CALCUL> LIGREL TARDIF DUPLIQUE'
          ELSE
            IF (NBPROC.GT.1) WRITE(IFM,*)'<FETI/CALCUL> AUTRE LIGREL'
          ENDIF
        ENDIF
C     -- FIN SI FETI
      ENDIF


C     -- SI FETI MESURE DU TEMPS POUR PROFILING
      IF ((LFETIC).OR.(NIV.GE.2)) THEN
        CALL UTTCPU(55,'INIT ',6,TEMPS)
        CALL UTTCPU(55,'DEBUT',6,TEMPS)
      ENDIF

C     DEBCA1  MET DES OBJETS EN MEMOIRE (ET COMMON):
C     -----------------------------------------------------------------
      CALL DEBCA1(OPTION,LIGREL)



      CALL JEVEUO('&CATA.TE.TYPEMA','L',JTYPMA)
      CALL JENONU(JEXNOM('&CATA.OP.NOMOPT',OPTION),OPT)
      IF (OPT.LE.0) THEN
        CALL U2MESK('F','CALCULEL_29',1,OPTION)
      END IF

C     -- POUR SAVOIR L'UNITE LOGIQUE OU ECRIRE LE FICHIER ".CODE" :
      CALL GETVLI(IUNCOD,CAS)


C     1- SI AUCUN TYPE_ELEMENT DU LIGREL NE SAIT CALCULER L'OPTION,
C     -- ON VA DIRECTEMENT A LA SORTIE :
C     -------------------------------------------------------------
      AFAIRE = 0
      IER = 0
      DO 20,J = 1,NBGREL(LIGREL)
        NUTE = TYPELE(LIGREL,J)
        CALL JENUNO(JEXNUM('&CATA.TE.NOMTE',NUTE),NOMTE)
        NOMTM = ZK8(JTYPMA-1+NUTE)
        NUMC = NUCALC(OPT,NUTE,0)

C        -- SI LE NUMERO DU TEOOIJ EST NEGATIF :
        IF (NUMC.LT.0) THEN
          VALK(1)=NOMTE
          VALK(2)=OPTION
          IF (NUMC.EQ.-1) THEN
            CALL U2MESK('F','CALCULEL_30', 2 ,VALK)
          ELSE IF (NUMC.EQ.-2) THEN
            CALL U2MESK('A','CALCULEL_30', 2 ,VALK)
          ELSE
            CALL U2MESS('F','CALCULEL_32')
          END IF
        END IF

        AFAIRE = MAX(AFAIRE,NUMC)
   20 CONTINUE
      CALL ASSERT(IER.LE.0)
      IF (AFAIRE.EQ.0) THEN
        IF (STOP.EQ.'S') THEN
          CALL U2MESK('F','CALCULEL_34',1,OPTION)
        ELSE
          GO TO 120
        END IF
      END IF



C     2- ON REND PROPRES LES LISTES : LPAIN,LCHIN,LPAOU,LCHOU :
C        EN NE GARDANT QUE LES PARAMETRES DU CATALOGUE DE L'OPTION
C        QUI SERVENT A AU MOINS UN TYPE_ELEMENT
C     ---------------------------------------------------------
      IF (NIN.GT.80) CALL U2MESS('F','CALCULEL_35')
      NIN3 = ZI(IAOPDS-1+2)
      NOU3 = ZI(IAOPDS-1+3)

      NIN2 = 0
      DO 40,I = 1,NIN
        NOMPAR = LPAIN(I)
        IPAR = INDIK8(ZK8(IAOPPA),NOMPAR,1,NIN3)
        IF (IPAR.GT.0) THEN
          DO 30,J = 1,NBGREL(LIGREL)
            NUTE = TYPELE(LIGREL,J)
            IPAR = INPARA(OPT,NUTE,'IN ',NOMPAR)

            IF (IPAR.EQ.0) GO TO 30
            CALL EXISD('CHAMP_GD',LCHIN(I),IRET)
            IF (IRET.EQ.0) GO TO 30
            NIN2 = NIN2 + 1
            LPAIN2(NIN2) = LPAIN(I)
            LCHIN2(NIN2) = LCHIN(I)
            GO TO 40
   30     CONTINUE
        END IF
   40 CONTINUE

C     -- VERIF PAS DE DOUBLONS DANS LPAIN2 :
      CALL KNDOUB(8,LPAIN2,NIN2,IRET)
      CALL ASSERT(IRET.EQ.0)

      NOU2 = 0
      DO 60,I = 1,NOU
        NOMPAR = LPAOU(I)
        IPAR = INDIK8(ZK8(IAOPPA+NIN3),NOMPAR,1,NOU3)
        IF (IPAR.GT.0) THEN
          DO 50,J = 1,NBGREL(LIGREL)
            NUTE = TYPELE(LIGREL,J)
            IPAR = INPARA(OPT,NUTE,'OUT',NOMPAR)

            IF (IPAR.EQ.0) GO TO 50
            NOU2 = NOU2 + 1
            LPAOU2(NOU2) = LPAOU(I)
            LCHOU2(NOU2) = LCHOU(I)
C           -- ON INTERDIT LA CREATION DU CHAMP ' ' :
            CALL ASSERT(LCHOU2(NOU2).NE.' ')
            GO TO 60
   50     CONTINUE
        END IF
   60 CONTINUE
C     -- VERIF PAS DE DOUBLONS DANS LPAOU2 :
      CALL KNDOUB(8,LPAOU2,NOU2,IRET)
      CALL ASSERT(IRET.EQ.0)


C     3- DEBCAL FAIT DES INITIALISATIONS ET MET LES OBJETS EN MEMOIRE :
C     -----------------------------------------------------------------
      CALL DEBCAL(OPTION,LIGREL,NIN2,LCHIN2,LPAIN2,NOU2,LCHOU2)
      IF (DBG) CALL CALDBG(OPTION,'IN',NIN2,LCHIN2,LPAIN2)


C     4- ALLOCATION DES RESULTATS ET DES CHAMPS LOCAUX:
C     -------------------------------------------------
      CALL ALRSLT(OPT,LIGREL,NOU2,LCHOU2,LPAOU2,BASE2)
      CALL ALCHLO(OPT,LIGREL,NIN2,LPAIN2,LCHIN2,NOU2,LPAOU2)



C     5- BOUCLE SUR LES GREL :
C     -------------------------------------------------
      NGREL = NBGREL(LIGREL)
      DO 80 IGR = 1,NGREL

        NUTE = TYPELE(LIGREL,IGR)
        CALL JENUNO(JEXNUM('&CATA.TE.NOMTE',NUTE),NOMTE)
        NOMTM = ZK8(JTYPMA-1+NUTE)
        CALL DISMOI('F','PHEN_MODE',NOMTE,'TYPE_ELEM',IBID,PHEMOD,IBID)
        PHENO = PHEMOD(1:16)
        MODELI = PHEMOD(17:32)
        CALL JELIRA(JEXNUM('&CATA.TE.CTE_ATTR',NUTE),'LONMAX',
     &              LCTEAT,KBID)
        IF (LCTEAT.GT.0) THEN
           CALL JEVEUO(JEXNUM('&CATA.TE.CTE_ATTR',NUTE),'L',JCTEAT)
        ELSE
           JCTEAT=0
        END IF
        NBELGR = NBELEM(LIGREL,IGR)
        NUMC = NUCALC(OPT,NUTE,0)
        IF (NUMC.LT.-10) CALL U2MESS('F','CALCULEL_2')
        IF (NUMC.GT.9999) CALL U2MESS('F','CALCULEL_8')

        IF (NUMC.GT.0) THEN

C       -- SI FETI PARALLELE, ON VA REMPLIR LE VECTEUR AUXILIAIRE
C       -- '&CALCUL.FETI.NUMSD'
          IF (LFETMO.OR.LFETTD) THEN
            CALL WKVECT(KCAL,'V V L',NBELGR,IFETI2)
            CALL JERAZO(KCAL,NBELGR,1)
            IFETI2=IFETI2-1
            IAUX1=IALIEL-1+ZI(ILLIEL-1+IGR)-1
            DO 68 IIEL=1,NBELGR
C           - NUMERO DE MAILLE
              IMA=ZI(IAUX1+IIEL)
              IF (LFETMO) THEN
C           - LIGREL DE MODELE, ON TAG EN SE BASANT SUR
C            '&FETI.MAILLE.NUMSD'
                IF (IMA.LE.0) CALL U2MESS('F','CALCULEL6_76')
                IF (ZI(IFETI1+IMA).GT.0) ZL(IFETI2+IIEL)=.TRUE.
              ELSE IF (LFETTD) THEN
                IF (IMA.GE.0) CALL U2MESS('F','CALCULEL6_76')
                IDD=ZI(IFEL2+2*(-IMA-1)+1)
C            - MAILLE TARDIVES, ON TAG EN SE BASANT SUR .FEL2
C             (VOIR NUMERO.F)
                IF (IDD.GT.0) THEN
C            - MAILLE NON SITUEE A L'INTERFACE
                  IF (ZI(ILIMPI+IDD).EQ.1) ZL(IFETI2+IIEL)=.TRUE.
                ELSE IF (IDD.EQ.0) THEN
C            - MAILLE D'UN AUTRE PROC, ON NE FAIT RIEN
C              ZL(IFETI2+IIEL) INITIALISE A .FALSE.
                ELSE IF (IDD.LT.0) THEN
C            - MAILLE A L'INTERFACE, ON NE S'EMBETE PAS ET ON FAIT TOUT
C              (C'EST DEJA ASSEZ COMPLIQUE COMME CELA !)
                  ZL(IFETI2+IIEL)=.TRUE.
                ENDIF
              ENDIF
   68       CONTINUE
C       -- MONITORING
            IF (INFOFE(2:2).EQ.'T') THEN
              CALL UTIMSD(IFM,2,.FALSE.,.TRUE.,KCAL,1,' ')
            ENDIF
          ENDIF

          CALL INIGRL(LIGREL,IGR,NBOBJ,ZI(IAINEL),ZK24(ININEL),NVAL)


C           5.2 ECRITURE AU FORMAT ".CODE" DU COUPLE (OPTION,TYPE_ELEM)
C           ------------------------------------------------------
          IF (IUNCOD.GT.0) THEN
            WRITE (IUNCOD,*) CAS,' &&CALCUL ',OPTION,' ',NOMTE,
     &        ' ''OUI'' '
          END IF


          NPIN = NBPARA(OPT,NUTE,'IN ')
          CALL MECOE1(OPT,NUTE)
          DO 70 IPAR = 1,NPIN
            NOMPAR = NOPARA(OPT,NUTE,'IN ',IPAR)
            IPARG = INDIK8(ZK8(IAOPPA),NOMPAR,1,NPARIO)
            IPARIN = INDIK8(LPAIN2,NOMPAR,1,NIN2)
            EXICH = ((IPARIN.GT.0) .AND. ZL(IACHIX-1+IPARIN))
            IF (.NOT.EXICH) THEN
              ZI(IAWLOC-1+7* (IPARG-1)+1) = -1
              ZI(IAWLOC-1+7* (IPARG-1)+4) = 0
              GO TO 70
            END IF

            CALL EXTRAI(NIN2,LCHIN2,LPAIN2,NOMPAR,LIGREL)
   70     CONTINUE


C           5.3 MISE A ZERO DES CHAMPS "OUT"
          CALL ZECHLO(OPT,NUTE)

C           5.4 ON ECRIT UNE VALEUR "UNDEF" AU BOUT DE
C              TOUS LES CHAMPS LOCAUX "IN" ET "OUT":
          CALL CAUNDF('ECRIT',OPT,NUTE)

C           5.5 ON FAIT LES CALCULS ELEMENTAIRES:
          IF (DBG) WRITE (6,*) '&&CALCUL OPTION=',OPTION,NOMTE,' ',NUMC
          CALL VRCDEC()
          CALL TE0000(NUMC,OPT,NUTE)

C           5.6 ON VERIFIE LA VALEUR "UNDEF" AU BOUT DES
C               CHAMPS LOCAUX "OUT" :
          CALL CAUNDF('VERIF',OPT,NUTE)

C         5.7 ON RECOPIE DES CHAMPS LOCAUX DANS LES CHAMPS GLOBAUX:
          CALL MONTEE(OPT,NUTE,NOU2,LCHOU2,LPAOU2)
C         IMPRESSIONS DE DEBUG POUR DETERMINER LE TEXXXX COUPABLE :
          IF (DBG) CALL CALDBG(OPTION,'OUTG',NOU2,LCHOU2,LPAOU2)

          IF (LFETMO.OR.LFETTD) CALL JEDETR(KCAL)
        END IF
   80 CONTINUE
C     ---FIN BOUCLE IGR


      IF (DBG) CALL CALDBG(OPTION,'OUTF',NOU2,LCHOU2,LPAOU2)


C     7- ON DETRUIT LES OBJETS VOLATILES CREES PAR CALCUL:
C     ----------------------------------------------------
      DO 110,I = 1,NBOBTR
        CALL JEDETR(ZK24(IAOBTR-1+I))
  110 CONTINUE
      CALL JEDETR('&&CALCUL.OBJETS_TRAV')

  120 CONTINUE
      IACTIF = 0

C SI FETI, MESURE DU TEMPS POUR PROFILING
      IF ((LFETIC).OR.(NIV.GE.2)) THEN
        CALL UTTCPU(55,'FIN  ',6,TEMPS)
        IF (NIV.GE.2) WRITE(IFM,'(A44,D11.4,D11.4)')
     &    'TEMPS CPU/SYS CALCUL ELEM '//OPTION//': ',TEMPS(5),TEMPS(6)
        IF (LFETIC) ZR(IFCPU+RANG)=ZR(IFCPU+RANG)+TEMPS(5)+TEMPS(6)
      ENDIF
      CALL JEDEMA()
      END
