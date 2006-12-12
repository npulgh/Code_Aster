      SUBROUTINE VECHTH(TYPCAL,MODELZ,CHARGZ,INFOCZ,CARELZ,MATEZ,INSTZ,
     &                  CHTNZ,VAPRIZ,VAPRMZ,NRGRPA,NOPASZ,TYPESE,STYPSE,
     &                  VECELZ)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 13/12/2006   AUTEUR PELLET J.PELLET 
C TOLE CRP_20
C ======================================================================
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
C TOLE CRP_20
C ----------------------------------------------------------------------
C CALCUL DES VECTEURS ELEMENTAIRES DES CHARGES THERMIQUES

C IN  TYPCAL  : TYPE DU CALCUL :
C               'THER', POUR LA RESOLUTION DE LA THERMIQUE,
C               'DLAG', POUR LE CALCUL DE LA DERIVEE LAGRANGIENNE DE T
C IN  MODELE : NOM DU MODELE
C IN  CHARGE : LISTE DES CHARGES
C IN  INFOCH : INFORMATIONS SUR LES CHARGEMENTS
C IN  CARELE : CHAMP DE CARA_ELEM
C IN  MATE   : CHAMP MATERIAU
C IN  INST   : CARTE CONTENANT LA VALEUR DE L'INSTANT
C IN  NRGRPA : NBRE DE GROS PAS DE TEMPS (CRITERE DE STATIONNARITE)
C . POUR LE CALCUL DE LA TEMPERATURE :
C IN  CHTN   : CHAMP DE TEMPERATURE A L'INSTANT PRECEDENT
C IN  VAPRIN : SANS OBJET
C IN  VAPRMO : SANS OBJET
C IN  NOPASE : SANS OBJET
C IN  TYPESE : SANS OBJET
C . POUR LE CALCUL D'UNE DERIVEE :
C IN  CHTN   : CHAMP DE LA DERIVEE A L'INSTANT PRECEDENT
C IN  VAPRIN : VARIABLE PRINCIPALE (TEMPERATURE) A L'INSTANT COURANT
C IN  VAPRMO  : VARIABLE PRINCIPALE (TEMPERATURE) A L'INSTANT PRECEDENT
C IN  NOPASE : PARAMETRE SENSIBLE
C IN  TYPESE : TYPE DE SENSIBILITE
C                0 : CALCUL STANDARD, NON DERIVE
C                SINON : DERIVE (VOIR NTTYSE)
C IN  STYPSE  : SOUS-TYPE DE SENSIBILITE (VOIR NTTYSE)
C OUT VECELZ : VECT_ELEM
C   -------------------------------------------------------------------
C     SUBROUTINES APPELLEES:
C       MESSAGE:INFNIV.
C       JEVEUX:JEMARQ,JEDEMA,JEEXIN,JELIRA,JEVEUO,WKVECT,JEECRA,JEDETR.
C       MANIP SD: RSEXCH,DETRSD,MEGEOM,MECARA,EXISD,MECACT.
C       SENSIBILITE: PSRENC.
C       CALCUL: CALCUL.
C       FICH COMM: GETRES.
C       DIVERS: GCNCO2,CORICH.

C     FONCTIONS INTRINSEQUES:
C       AUCUNE.
C   -------------------------------------------------------------------
C     ASTER INFORMATIONS:
C       30/11/01 (OB): MODIFICATIONS POUR INSERER LES SECONDS MEMBRES
C                      INTRODUITS PAR LES CHARGEMENTS DES PB DERIVES.
C       08/03/02 (OB): CORRECTION BUG EN STATIONNAIRE AVEC TYPESE.EQ.8
C----------------------------------------------------------------------
C CORPS DU PROGRAMME
      IMPLICIT NONE

C 0.1. ==> ARGUMENTS

      INTEGER TYPESE,NRGRPA
      CHARACTER*4 TYPCAL
      CHARACTER*24 STYPSE
      CHARACTER*(*) MODELZ,CHARGZ,INFOCZ,CARELZ,INSTZ,CHTNZ,VECELZ,
     &              VAPRIZ,VAPRMZ,MATEZ,NOPASZ

C 0.2. ==> COMMUNS
C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------

      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------

C 0.3. ==> VARIABLES LOCALES

      CHARACTER*6 NOMPRO
      PARAMETER (NOMPRO='VECHTH')
      INTEGER NCHINX
      PARAMETER (NCHINX=9)
      INTEGER IRET,NCHAR,ICHA,ILVE,JCHAR,EXICHA,IBID,IFM,NIV,NBCMP,JINF,
     &        JLVE,K,LONLIS,NUMCHM,NUMORD,NCHIN,JNOLI,ICMP(1),IRETE,
     &        IRETH,IRETP,NBNOLI,I
      REAL*8 RCMP(1)
      COMPLEX*16 CCMP(1)
      CHARACTER*1 BASE
      CHARACTER*8 NOMCHA,LPAIN(NCHINX),PAOUT,K8BID,VECELE,NEWNOM,NOPASE,
     &            NOMCHS,NOMCH2,LICMP(1)
      CHARACTER*16 OPTION,NOMCMD
      CHARACTER*24 LIGREL(3),LCHIN(NCHINX),RESUEL,CHGEOM,CHCARA(15),
     &             VECTTH,GRADTH,MODELE,CHARGE,INFOCH,CARELE,INST,CHTN,
     &             VAPRIN,VAPRMO,MATE,KCMP(1),LCHINE,LCHINP
      LOGICAL BIDON,EXICAR,EXIGEO,LSENS,LDLAG,LPERML,LPEROK
C ----------------------------------------------------------------------
      INTEGER NBCHMX
      PARAMETER (NBCHMX=6)
      INTEGER NBOPT(NBCHMX),NLIGR(NBCHMX)
      CHARACTER*6 NOMPAR(NBCHMX),NOMCHP(NBCHMX),NOMOPT(NBCHMX),NOMGDZ
      DATA NOMCHP/'.T_EXT','.FLURE','.FLUR2','.SOURE','.HECHP','.GRAIN'/
      DATA NOMOPT/'TEXT_','FLUN_','FLUX_','SOUR_','PARO_','GRAI_'/
      DATA NOMPAR/'PT_EXT','PFLUXN','PFLUXV','PSOURC','PHECHP','PGRAIN'/
      DATA NBOPT/5,3,3,3,5,6/
      DATA NLIGR/1,1,1,1,2,1/

C DEB ------------------------------------------------------------------
C====
C 1.1 PREALABLES LIES AUX OPTIONS
C====
      CALL JEMARQ()
      IF (TYPCAL.NE.'THER' .AND. TYPCAL.NE.'DLAG' .AND.
     &    TYPCAL.NE.'SENS') CALL U2MESS('F','ALGORITH11_22')
C LOGICAL INDICATEUR D'UN CALCUL DE SENSIBILITE (TYPESE.GT.0)
      IF (TYPCAL.EQ.'SENS') THEN
        LSENS = .TRUE.
C ON VA REUTILISER LES OPTIONS DE CALCUL STANDARDS AVEC UNE FONCTION
C INDICATRICE (C'EST PEU OPTIMAL MAIS RAPIDE EN TERME DE DEVT ET DE
C TEST DE NON-REGRESSION) CHAQUE FOIS QUE C'EST POSSIBLE. SAUF POUR LA
C DERIVATION PAR RAPPORT AU COEFFICIENT D'ECHANGE CONVECTIF POUR
C LAQUELLE ON UTILISE UNE OPTION SPECIFIQUE: CHAR_SENS_TEXT/PARO.
        IF (TYPESE.NE.8) TYPCAL = 'THER'
      ELSE
        LSENS = .FALSE.
      END IF
C LOGICAL INDICATEUR D'UN CALCUL DE DERIVEE LAGRANGIENNE (TYPESE.EQ.-1)
      IF (TYPCAL.EQ.'DLAG') THEN
        LDLAG = .TRUE.
      ELSE
        LDLAG = .FALSE.
      END IF
      CALL INFNIV(IFM,NIV)
      NEWNOM = '.0000000'
      MODELE = MODELZ
      CHARGE = CHARGZ
      INFOCH = INFOCZ
      CARELE = CARELZ
      MATE = MATEZ
      INST = INSTZ
      CHTN = CHTNZ
      VAPRIN = VAPRIZ
      VAPRMO = VAPRMZ
      NOPASE = NOPASZ
      DO 10 I = 1,NCHINX
        LPAIN(I) = '        '
        LCHIN(I) = '                        '
   10 CONTINUE

C INITS. LIES AU CALCUL SUPPLEMENTAIRE 5. EN SENSIBILITE
      IF (LSENS) THEN
        BASE = 'V'
        NBCMP = 1
        LICMP(1) = 'TEMP'
        RCMP(1) = 0.D0
        KCMP(1) = '&FOZERO'
      END IF
C====
C 1.2 PREALABLES LIES AUX CHARGES
C====
      LIGREL(1) = MODELE(1:8)//'.MODELE'
C FLAG POUR SIGNIFIER LA PRESENCE DE CHARGES (NCHAR NON NUL)
      BIDON = .TRUE.
C TEST D'EXISTENCE DE L'OBJET JEVEUX CHARGE
      CALL JEEXIN(CHARGE,IRET)
      IF (IRET.NE.0) THEN
C LECTURE DU NBRE DE CHARGE NCHAR DANS L'OBJET JEVEUX CHARGE
        CALL JELIRA(CHARGE,'LONMAX',NCHAR,K8BID)
        IF (NCHAR.NE.0) THEN
          BIDON = .FALSE.
C LECTURE DES ADRESSES JEVEUX DES CHARGES ET DES INFOS AFFERENTES
          CALL JEVEUO(CHARGE,'L',JCHAR)
          CALL JEVEUO(INFOCH,'L',JINF)
        END IF
      END IF

C====
C 2. INIT. DES VECTEURS SECONDS MEMBRE ELEMENTAIRES
C====

C CREATION D'UN OBJET JEVEUX VOLATILE POUR STOCKER LES VECTEURS ELEM
      IF (TYPCAL.EQ.'DLAG') THEN
        VECELE = '&&VETCHD'
        NUMORD = 0
C RECUPERATION DU CHAMP_GD CORRESPONDANT A NOPASE(NUMORD,'THETA')
C ET NOPASE(NUMORD,'GRAD_NOEU_THETA')
        CALL RSEXCH(NOPASE,'THETA',NUMORD,VECTTH,IRET)
        CALL RSEXCH(NOPASE,'GRAD_NOEU_THETA',NUMORD,GRADTH,IRET)
      ELSE
        VECELE = '&&VETCHA'
      END IF

      RESUEL = '&&'//NOMPRO//'.???????'

C DESTRUCTION DE LA SD VECELE DE TYPE 'VECT_ELEM'
      CALL DETRSD('VECT_ELEM',VECELE)
      VECELZ = VECELE//'.LISTE_RESU'
C CREATION ET INITIALISATION DU VECT_ELEM ASSOCIE AU MODELE MODELE(1:8),
C AU MATERIAU MATE, AU CARA_ELEM CARELE ET A LA SUR_OPTION 'CHAR_THER'
      CALL MEMARE('V',VECELE,MODELE(1:8),MATE,CARELE,'CHAR_THER')
C CREATION DU VECTEUR VECELZ DE TYPE K24, DE LONGUEUR EFFECTIVE LONLIS
C ET DE LONGUEUR UTILE NULLE
      IF (BIDON) THEN
        CALL WKVECT(VECELZ,'V V K24',1,JLVE)
        CALL JEECRA(VECELZ,'LONUTI',0,K8BID)
C PAS DE CHARGE, ON S'EN VA
        GO TO 80
      ELSE
C NCHAR CHARGES, ON PREPARE LES SDS DE STOCKAGE IDOINES
C TRES LARGEMENT SURDIMENSIONNEES SI ON EST EN SENSIBILITE
        LONLIS = NBCHMX*NCHAR
        CALL WKVECT(VECELZ,'V V K24',LONLIS,JLVE)
        CALL JEECRA(VECELZ,'LONUTI',0,K8BID)
      END IF

C RECHERCHE DU CHAMP DE GEOMETRIE CHGEOM ASSOCIE AU MODELE(1:8) ET A LA
C LISTE DE CHARGES ZK24(JCHAR)
      CALL MEGEOM(MODELE(1:8),ZK24(JCHAR) (1:8),EXIGEO,CHGEOM)
C RECHERCHE DES NOMS DES CARAELEM CHCARA DANS LA CARTE CARELE(1:8)
      CALL MECARA(CARELE(1:8),EXICAR,CHCARA)

C====
C 3. PREPARATION DES CALCULS ELEMENTAIRES
C====

C CHAMP LOCAL CONTENANT LA CARTE DES NOEUDS (X Y Z)
      LPAIN(2) = 'PGEOMER'
      LCHIN(2) = CHGEOM
C ... LA CARTE DES INSTANTS (INST DELTAT THETA KHI  R RHO)
      LPAIN(3) = 'PTEMPSR'
      LCHIN(3) = INST
C ... LE CHAM_NO DE TEMPERATURE A L'INSTANT PRECEDENT (TEMP) OU
C ... LA DERIVE (DT/DS) A L'INSTANT PRECEDENT
      LPAIN(4) = 'PTEMPER'
      LCHIN(4) = CHTN
C ... LE COEFFICIENT D'ECHANGE
      LPAIN(5) = 'PCOEFH'

C AFFECTATIONS CONDITIONNELLES DES DEUX DERNIERS CHAMPS
      IF (TYPESE.EQ.8) THEN
C SI DERIVEE PAR RAPPORT AU COEFFICIENT D'ECHANGE CONVECTIF ON A
C LES CHAMPS LOCAUX CORRESPONDANTS AUX CHAMPS DE TEMPERATURES A T+ ET
C A T-.
        LPAIN(6) = 'PVAPRIN'
        LCHIN(6) = VAPRIN
C ON NE TRANSMET PAS LE CHAMP T- EN STATIONNAIRE (VRAI STATIONNAIRE
C OU PHASE STATIONNAIRE D'UN TRANSITOIRE)
        IF (NRGRPA.NE.0) THEN
          LPAIN(7) = 'PVAPRMO'
          LCHIN(7) = VAPRMO
        END IF
      ELSE
C AUTRE CAS
C ... LA CARTE MATERIAU (I1)
        LPAIN(6) = 'PMATERC'
        LCHIN(6) = MATE
C ... LE CHAMP DE DEPLACEMENT
        LPAIN(7) = 'PDEPLAR'
        LCHIN(7) = '&&DEPPLU'
      END IF

C ... LE CHAMP RESULTAT
      PAOUT = 'PVECTTR'

C====
C 3.1 IMPRESSIONS NIVEAU 2 POUR DIAGNOSTICS...
C====

      IF (NIV.EQ.2) THEN
        WRITE (IFM,*) '*******************************************'
        WRITE (IFM,*) ' CALCUL DE SECOND MEMBRE THERMIQUE: ',NOMPRO
        WRITE (IFM,*)
        WRITE (IFM,*) ' TYPE DE CALCUL   :',TYPCAL
        IF (LSENS) THEN
          WRITE (IFM,*) ' TYPESE/STYPSE        : ',TYPESE,' ',STYPSE
          WRITE (IFM,*) ' NOPASE               : ',NOPASE
        END IF
        WRITE (IFM,*) ' LIGREL/MODELE    :',LIGREL(1)
        WRITE (IFM,*) ' OBJ JEVEUX CHARGE:',CHARGE
        WRITE (IFM,*) '            INFOCH:',INFOCH
        WRITE (IFM,*) ' NBRE DE CHARGES  :',NCHAR
        WRITE (IFM,*) ' BOUCLE SUR LES CHARGES DE TYPE NEUMANN LIN'
      END IF

C====
C 4. BOUCLE SUR LES AFFE_CHAR_THER ==================================
C====
      ILVE = 0
      DO 70 ICHA = 1,NCHAR

C====
C 4.1 PREALABLES LIES AUX TYPES DE CL DE CET AFFE_CHAR_THER
C====
C EXICHA = 0 SI ON EST DANS UN CALCUL STANDARD OU SI ON EST DANS CALCUL
C DE SENSIBILITE ET QUE LE CHARGEMENT EST SENSIBLE AU PARAMETRE DE
C DERIVATION. BREF DANS LES DEUX CAS, ON A A ASSEMBLER UN SECOND MEMBRE
C ALORS QUE SINON A JUSTE A PEUT-ETRE ASSEMBLER UN TERME COMPLEMENTAIRE
C (SI ON EST EN SENSIBILITE TRANSITOIRE AVEC CHARGEMENT DE TYPE ECHANGE)
C ACCES A LA COMPOSANTE NCHAR+ICHA DE LA SD INFO_CHARGE CONCERNANT LES
C CHARGE DE TYPE NEUMANN. SI NUMCHM NON NUL, CE TYPE DE CL EXISTE DANS
C CET AFFE_CHAR_THER
        NUMCHM = ZI(JINF+NCHAR+ICHA)

        IF (NUMCHM.GT.0) THEN

C NOM DE LA CHARGE
          NOMCHA = ZK24(JCHAR+ICHA-1) (1:8)
          LIGREL(2) = NOMCHA//'.CHTH.LIGRE'
          IF (NIV.EQ.2) THEN
            WRITE (IFM,*) ' '
            WRITE (IFM,*) '   CHARGE         :',NOMCHA
          END IF

C==== POUR TYPCAL = 'THER' OU 'DLAG' ASSEMBLAGE DU SECOND MEMBRE ====
C==== ELEMENTAIRE LIE AUX CHARGEMENTS                            ====
C==== POUT TYPCAL = 'SENS' --> ASSEMBLAGE DU PREMIER TERME DU    ====
C==== SECOND MEMBRE ELEMENTAIRE LIE AUX CHARGEMENTS              ====

C====
C 4.2 EST-CE UN CALCUL DE SENSIBILITE SENSIBLE ? (TYPESE.EQ.-1 OU
C     TYPESE.GE.3).
C     LE CHARGEMENT CONSIDERE LUI EST IL SENSIBLE (EXICHA NUL) ?
C====
          EXICHA = -1
          LPERML = .FALSE.
          IF (LSENS) THEN
C LE PARAMETRE SENSIBLE NOPASE EST T'IL CONCERNE PAS CE CHARGEMENT DE
C BASE NOMCHA. SI OUI, ILS CONSTITUENT LE CHARGEMENT DERIVE NOMCHS ET
C EXICHA = 0.
            CALL PSRENC(NOMCHA,NOPASE,NOMCHS,EXICHA)
            IF (NIV.EQ.2) WRITE (IFM,*) '   EXICHA/NOMCHS  :',EXICHA,
     &          ' ',NOMCHS

            IF (EXICHA.EQ.0) THEN
C ON CONSTRUIT LES SECONDS MEMBRES ELEM DU PB DERIVE
C IL FAUFRA PENSER A SE POSER LA QUESTION D'UNE EVENTUELE PERMUTATION
C DU LIGREL APRES LE CALCUL (LPERML=TRUE)
              NOMCH2 = NOMCHS
              LPERML = .TRUE.
            ELSE
C ON NE CONSTRUIT RIEN: CALCUL INSENSIBLE A CE CHARGEMENT
C ON EFFECTUERA EVENTUELLEMENT L'ASSEMBLAGE DU TERME COMPLEMENTAIRE
              EXICHA = -1
            END IF
          ELSE
C ON CONSTRUIT LES SECONDS MEMBRES ELEM DU PB STANDARD OU DE LA
C DERIVEE LAGRANGIENNE
            EXICHA = 0
            NOMCH2 = NOMCHA
          END IF
C====
C 4.3 SI ON DOIT ASSEMBLER, CONSTRUCTION AU CAS PAR CAS DE L'OPTION
C     DE CALCUL. BOUCLE SUR LES NBCHMX TYPES DE CL POSSIBLES =======
C====
          IF (EXICHA.EQ.0) THEN

            IF (NIV.EQ.2) WRITE (IFM,*)
     &          '     BOUCLE SUR LES TYPES DE CHARGES'
            DO 50 K = 1,NBCHMX

C ACCES A LA DESCRIPTION '.DESC' DES CHTH.NOMCHP(K) ET CHTH.COEFH DE LA
C CHARGE NOMCHA POUR DEFINIR LES CHAMPS LOCAUX DE LA CARTE DE CHARGEMENT
              LCHIN(1) = NOMCH2(1:8)//'.CHTH'//NOMCHP(K)
              LCHIN(5) = NOMCH2(1:8)//'.CHTH'//'.COEFH  '

C TEST EXISTENCE DE L'OBJET JEVEUX POUR SAVOIR SI LE CALCUL ELEMENTAIRE
C DE TYPE TYPCAL ASSOCIE A CETTE CL NOMCHP(K) POUR CE ICHA IEME AFFE_
C CHAR_THER EST NECESSAIRE
              IRET = 0
              CALL EXISD('CHAMP_GD',LCHIN(1),IRET)

C ASSEMBLAGE CAR LA CHARGE ICHA CORRESPOND A NOMCHP(K)
              IF (IRET.NE.0) THEN

C====
C 4.4 TEST ET TRAITEMENT SUPPLEMENTAIRE POUR LA CONDITION ECHANGE
C====
                IF (K.EQ.1) THEN

                  IRETH = 0
                  CALL EXISD('CHAMP_GD',LCHIN(5),IRETH)
                  IF (((IRETH.EQ.0).AND. (IRET.NE.0)) .OR.
     &                ((IRET.EQ.0).AND. (IRETH.NE.0))) CALL U2MESS('F','
     &CALCULEL4_75')

                  IF (TYPESE.EQ.7) THEN
C MODIFICATION DU TERME STD: ON "BLUFF" LE CALCUL DE CHAR_THER_TEXT
C EN CREEANT UN CHAMP T- NULLE VIA LE CHAMNO '&&VECHTH.T_MOINSNUL'
                    LCHIN(4) = '&&'//NOMPRO//'.T_MOINSNUL'
                    CALL VTDEFS(LCHIN(4),CHTN,'V',' ')
                    LCHIN(5) = NOMCHA(1:8)//'.CHTH'//'.COEFH  '
                    IF (NIV.EQ.2) THEN
                      WRITE (IFM,*) '-->  BLUFF DE L''OPTION: CHAMNO T-'
                      WRITE (IFM,*)
     &                  '-->  NUL ET CARTH DU CHARGEMENT STD'
                    END IF
                  END IF
                  IF (TYPESE.EQ.8) THEN
C MODIFICATION DU TERME STD: ON "BLUFF" LE CALCUL DE CHAR_THER_TEXT
C EN RAJOUTANT T+/T- ET LA TEMP_EXT DU CHARGEMENT STD
                    LCHIN(1) = NOMCHA(1:8)//'.CHTH'//'.T_EXT  '
                    IF (NIV.EQ.2) THEN
                      WRITE (IFM,*)
     &                  '-->  BLUFF DE L''OPTION: CHAMNO T+/-'
                      WRITE (IFM,*) '-->  ET TEXT DU CHARGEMENT STD'
                    END IF
                  END IF

                ELSE IF ((K.EQ.5) .AND. (TYPESE.EQ.8)) THEN
                  IF (NIV.EQ.2) THEN
                    WRITE (IFM,*) '-->  BLUFF DE L''OPTION: CHAMNO T+/-'
                    WRITE (IFM,*) '-->  DU CHARGEMENT STD'
                  END IF
                END IF

C====
C 4.5 TRAITEMENT EVENTUEL DU LIGREL SI ON EST EN SENSIBILITE:
C====
C ON UTILISERA LE LIGREL DU CHARGEMENT STANDARD SI ON EST DANS LE
C CAS: SOURCE AU NOEUD OU ECHANGE_PAROI. POUR CELA ON
C REMPLACE LE NOM JEVEUX STOCKE DANS LE CHARGEMENT SENSIBLE
C PAR LE NOM STANDARD, LIGREL(2). EVIDEMMENT, A LA FIN DU
C TRAITEMENT, ON REMETTRA LE VRAI NOM, SAUVEGARDE DANS LIGREL(3).
C LPEROK = TRUE SI ON DOIT PERMUTER
                IF (LPERML .AND. (NLIGR(K).EQ.2)) THEN
                  LPEROK = .TRUE.
                  CALL JELIRA(NOMCH2(1:8)//'.CHTH'//NOMCHP(K)//'.NOLI',
     &                        'LONMAX',NBNOLI,K8BID)
                  CALL JEVEUO(NOMCH2(1:8)//'.CHTH'//NOMCHP(K)//'.NOLI',
     &                        'E',JNOLI)
                  LIGREL(3) = ZK24(JNOLI)
                  DO 20 I = 0,NBNOLI - 1
                    ZK24(JNOLI+I) = LIGREL(2)
   20             CONTINUE
                  IF (NIV.EQ.2) WRITE (IFM,*) '     ! LIGREL PERMUTE !'
                ELSE
                  LPEROK = .FALSE.
                END IF

C====
C 4.6 PREPARATION FINALE DES OPTIONS DE CALCUL
C====
                IF (NUMCHM.EQ.1) THEN
C CHAMP LOCAL CONSTANT ASSOCIE A LA CARTE NOMPAR(K)//'R'

                  LPAIN(1) = NOMPAR(K)//'R'
                  LPAIN(5) = LPAIN(5) (1:6)//'R'
                  OPTION = 'CHAR_'//TYPCAL//'_'//NOMOPT(K) (1:5)//'R'
                ELSE
C CHAMP LOCAL VARIABLE (EN ESPACE 2) OU (EN TEMPS ET/OU EN ESPACE 3)

                  LPAIN(1) = NOMPAR(K)//'F'
                  LPAIN(5) = LPAIN(5) (1:6)//'F'
                  OPTION = 'CHAR_'//TYPCAL//'_'//NOMOPT(K) (1:5)//'F'
                END IF

C ON FIXE LE NBRE DE PARAMETRES DE L'OPTION EN PRENANT LE MAX DE
C L'OPTION REELLE ET CONSTANTE
                NCHIN = NBOPT(K)
C CAS PARTICULIER DE LA DERIVEE PAR RAPPORT AU COEFF. ECHANGE CONVECTIF
C QUI REUTILISE OPTION STD AVEC UN OU DEUX CHAMPS OPTIONNELS
                IF (TYPESE.EQ.8) THEN
                  IF (NRGRPA.NE.0) THEN
                    NCHIN = NCHIN + 2
                  ELSE
                    NCHIN = NCHIN + 1
                  END IF
                END IF

C RAJOUT DE QUATRE PARAMETRES DANS LE CAS DES DERIVEES LAGRANGIENNES
                IF (LDLAG) THEN
                  NCHIN = NCHIN + 1
                  LPAIN(NCHIN) = 'PTEMPEP'
                  LCHIN(NCHIN) = VAPRIN
                  NCHIN = NCHIN + 1
                  LPAIN(NCHIN) = 'PDLAGTE'
                  LCHIN(NCHIN) = CHTN
                  NCHIN = NCHIN + 1
                  LPAIN(NCHIN) = 'PVECTTH'
                  LCHIN(NCHIN) = VECTTH
                END IF

C====
C 4.7 CAS PARTICULIERS THER_NON_LINE_MO
C====
C   DANS LE CAS TRES PARTICULIER DE LA COMMANDE THER_NON_LINE_MO
C   AVEC LA CHARGE : ECHANGE_PAROI, ON ENVOIE UNE CARTE DE TEMPS
C   OU THETA A ETE REMPLACE PAR 1-THETA
                CALL GETRES(K8BID,K8BID,NOMCMD)
                IF ((NOMCMD.EQ.'THER_NON_LINE_MO') .AND.
     &              (OPTION(11:14).EQ.'PARO')) THEN
                  LPAIN(3) = 'PTEMPSR'
                  LCHIN(3) = '&&OP0171.TIMEMO'
                END IF

C====
C 4.8 PRETRAITEMENTS POUR TENIR COMPTE DE FONC_MULT
C====
                CALL GCNCO2(NEWNOM)
                RESUEL(10:16) = NEWNOM(2:8)
                CALL CORICH('E',RESUEL,ICHA,IBID)

C====
C 4.9.1 LANCEMENT DES CALCULS ELEMENTAIRES OPTION
C====
                IF (NIV.EQ.2) THEN
                  WRITE (IFM,*) '     K              :',K
                  WRITE (IFM,*) '     OPTION         :',OPTION
                  DO 30 I = 1,NCHIN
                    WRITE (IFM,*) '     LPAIN/LCHIN    :',LPAIN(I),' ',
     &                LCHIN(I)
   30             CONTINUE
                END IF
                CALL CALCUL('S',OPTION,LIGREL(NLIGR(K)),NCHIN,LCHIN,
     &                      LPAIN,1,RESUEL,PAOUT,'V')

C INCREMENTATION DE LONUTI ET STOCKAGE DU RESULTAT
                ILVE = ILVE + 1
                ZK24(JLVE-1+ILVE) = RESUEL

C====
C 4.9.2 ON REMET LE LIGREL SI NECESSAIRE (CF. 4.5)
C====
                IF (LPEROK) THEN
                  DO 40 I = 0,NBNOLI - 1
                    ZK24(JNOLI+I) = LIGREL(3)
   40             CONTINUE
                END IF
C====
C 4.9.3 DESTRUCTION DE L'OBJET JEVEUX VOLATILE SI NECESSAIRE (CF.4.4)
C==== ET ON REMET LE BON CHAMP DANS LCHIN
                IF ((TYPESE.EQ.7) .AND. (K.EQ.1)) THEN
                  CALL JEDETC('V','&&'//NOMPRO//'.T_MOINSNUL',1)
                  LCHIN(4) = CHTN
                END IF

              END IF
C FIN IF IRET
   50       CONTINUE

C====
C 4.8 FIN BOUCLE SUR LES NBCHMX CL NEUMANN POSSIBLES =======
C====
C FIN IF EXICHA
          END IF

C==== POUT TYPCAL = 'SENS' --> ASSEMBLAGE DU SECOND TERME DU     ====
C==== SECOND MEMBRE ELEMENTAIRE LIE AUX CHARGEMENTS              ====
C====
C    EN TRANSITOIRE
C 5. ASSEMBLAGE COMPLEMENTAIRE DU TERME D'ECHANGE POUR LES CALCULS DE
C    SENSIBILITE (TEXT+/- = 0 ET T- EST REMPLACE PAR (DT/DS)-
C====
          IF (LSENS .AND. (NRGRPA.GT.0)) THEN
            LCHINE = NOMCHA(1:8)//'.CHTH'//NOMCHP(1)
            LCHIN(5) = NOMCHA(1:8)//'.CHTH'//'.COEFH  '
            LCHINP = NOMCHA(1:8)//'.CHTH'//NOMCHP(5)

C====
C 5.1 TEST D'EXISTENCE DE LA CONDITION ECHANGE EXTERIEURE (IRETE,IRETH)
C     OU ECHANGE PAROI (IRETP)
C====
            IRETE = 0
            IRETH = 0
            IRETP = 0
            CALL EXISD('CHAMP_GD',LCHINE,IRETE)
            CALL EXISD('CHAMP_GD',LCHIN(5),IRETH)
            IF (((IRETH.EQ.0).AND. (IRETE.NE.0)) .OR.
     &          ((IRETE.EQ.0).AND. (IRETH.NE.0))) CALL U2MESS('F','CALCU
     &LEL4_75')
            IF (IRETE.EQ.0) CALL EXISD('CHAMP_GD',LCHINP,IRETP)

C====
C 5.2 ASSEMBLAGE COMPLENTAIRE CAR ON A AFFAIRE A L'UNE DES DEUX
C====
            IF ((IRETH.NE.0) .OR. (IRETP.NE.0)) THEN

              IF (NIV.EQ.2) THEN
                WRITE (IFM,*)
     &            '-->  CALCUL COMPLEMENTAIRE EN SENSIBILITE'
                IF (IRETH.NE.0) THEN
                  WRITE (IFM,*) '-->  ECHANGE/NUMCHM :',NUMCHM
                ELSE
                  WRITE (IFM,*) '-->  ECHANGE_PAROI/NUMCHM :',NUMCHM
                END IF
              END IF

              IF (IRETH.NE.0) THEN
C====
C 5.3 TERME COMPLENTAIRE EN ECHANGE
C ON "BLUFF" LE CALCUL DE L'OPTION CHAR_THER_TEXT EN CREEANT UN CHAMP
C TEXT NULLE VIA LA CARTE '&&VECHTH.T_EXTNUL'
C====
                OPTION = 'CHAR_THER_TEXT_'
                K = 1
                LCHIN(1) = '&&'//NOMPRO//'.T_EXTNUL'
                IF (NUMCHM.EQ.1) THEN
                  LPAIN(1) = NOMPAR(K)//'R'
                  LPAIN(5) = 'PCOEFH'//'R'
                  OPTION = OPTION(1:15)//'R'
                  NOMGDZ = 'TEMP_R'
                ELSE
                  LPAIN(1) = NOMPAR(K)//'F'
                  LPAIN(5) = 'PCOEFH'//'F'
                  OPTION = OPTION(1:15)//'F'
                  NOMGDZ = 'TEMP_F'
                END IF
                CALL MECACT(BASE,LCHIN(1),'LIGREL',LIGREL(NLIGR(K)),
     &                      NOMGDZ,NBCMP,LICMP,ICMP,RCMP,CCMP,KCMP)
                IF (NIV.EQ.2) WRITE (IFM,*)
     &              '-->  BLUFF DE L''OPTION: CARTE '//'TEXT+/- NULLE'
              ELSE
C====
C 5.4 TERME COMPLEMENTAIRE EN ECHANGE_PAROI
C OPTION CHAR_THER_PARO_F OU T- EST REMPLACE PAR (DT/DS)-
C====
                LCHIN(1) = LCHINP
                OPTION = 'CHAR_THER_PARO_'
                K = 5
                IF (NUMCHM.EQ.1) THEN
                  LPAIN(1) = NOMPAR(K)//'R'
                  LPAIN(5) = 'PHECHP'//'R'
                  OPTION = OPTION(1:15)//'R'
                ELSE
                  LPAIN(1) = NOMPAR(K)//'F'
                  LPAIN(5) = 'PHECHP'//'F'
                  OPTION = OPTION(1:15)//'F'
                END IF
                IF (NIV.EQ.2) WRITE (IFM,*)
     &              '-->  BLUFF DE L''OPTION: T- EST '//
     &              'REMPLACE PAR (DT/DS)-'
              END IF
              NCHIN = NBOPT(K)
              CALL GCNCO2(NEWNOM)
              RESUEL(10:16) = NEWNOM(2:8)
              CALL CORICH('E',RESUEL,ICHA,IBID)

C====
C 5.5 LANCEMENT DES CALCULS ELEMENTAIRES OPTION
C====
              IF (NIV.EQ.2) THEN
                WRITE (IFM,*) '-->  K              :',K
                WRITE (IFM,*) '-->  OPTION         :',OPTION
                DO 60 I = 1,NCHIN
                  WRITE (IFM,*) '     LPAIN/LCHIN    :',LPAIN(I),' ',
     &              LCHIN(I)
   60           CONTINUE
              END IF
              CALL CALCUL('S',OPTION,LIGREL(NLIGR(K)),NCHIN,LCHIN,LPAIN,
     &                    1,RESUEL,PAOUT,'V')

C INCREMENTATION DE LONUTI ET STOCKAGE DU RESULTAT
              ILVE = ILVE + 1
              ZK24(JLVE-1+ILVE) = RESUEL

C DESTRUCTION DE L'OBJET JEVEUX VOLATILE SI NECESSAIRE
              IF (IRETH.NE.0) CALL JEDETR(LCHIN(1))

C TEST SUR IRETH OU IRETP
            END IF
C FIN TEST SUR LSENS
          END IF

C FIN TEST SUR NUMCHM (GERE PARTIES 4 ET 5)
        END IF

   70 CONTINUE

C====
C 6. FIN BOUCLE SUR LES CHARGES ========================================
C====
C MODIFICATION DU NBRE DE TERMES UTILES DU VECTEUR ELEM RESULTAT
      CALL JEECRA(VECELZ,'LONUTI',ILVE,K8BID)

C SORTIE DE SECOURS EN CAS D'ABSENCE DE CHARGE
   80 CONTINUE

C ON REMET D'APLOMB CE PARAMETRAGE POUR UN EVENTUEL CALCUL NON-LINEAIRE
C A SUIVRE
      IF (LSENS) TYPCAL = 'SENS'

      CALL JEDEMA()
      END
