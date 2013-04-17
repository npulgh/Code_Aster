      SUBROUTINE DLTLEC ( RESULT, MODELE, NUMEDD, MATERI,   MATE,
     &                    CARAEL, CARELE,
     &                    IMAT, MASSE, RIGID, AMORT, LAMORT,
     &                    NCHAR, NVECA, LISCHA, CHARGE, INFOCH, FOMULT,
     &                    IAADVE, IALIFO, NONDP, IONDP,
     &                    SOLVEU, IINTEG, T0, NUME,BASENO,NUMREP)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 15/04/2013   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2013  EDF R&D                  WWW.CODE-ASTER.ORG
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
C TOLE CRP_21
C ----------------------------------------------------------------------
C
C       DYNAMIQUE LINEAIRE TRANSITOIRE - LECTURE DES DONNEES
C       -         -        -             ---
C
C ----------------------------------------------------------------------
C
C      OUT RESULT : NOM UTILISATEUR DU RESULTAT DE STAT_NON_LINE
C      OUT MODELE : NOM DU MODELE
C      OUT NUMEDD : NUME_DDL DE LA MATR_ASSE RIGID
C      OUT MATERI : NOM DU CHAMP DE MATERIAU
C      OUT MATE   : NOM DU CHAMP DE MATERIAU CODE
C      OUT CARELE : CARACTERISTIQUES DES ELEMENTS DE STRUCTURE
C      OUT MASSE  : MATRICE DE MASSE
C      OUT RIGID  : MATRICE DE RIGIDITE
C      OUT AMORT  : MATRICE D'AMORTISSEMENT
C      OUT LAMORT : LOGIQUE INDIQUANT SI IL Y A AMORTISSEMENT
C      OUT IMAT   : TABLEAU D'ADRESSES POUR LES MATRICES
C      OUT NCHAR  : NOMBRE D'OCCURENCES DU MOT CLE CHARGE
C      OUT NVECA  : NOMBRE D'OCCURENCES DU MOT CLE VECT_ASSE
C      OUT LISCHA : INFO SUR LES CHARGES
C      OUT CHARGE : LISTE DES CHARGES
C      OUT INFOCH : INFO SUR LES CHARGES
C      OUT FOMULT : LISTE DES FONC_MULT ASSOCIES A DES CHARGES
C      OUT IAADVE : ADRESSE
C      OUT IAADVE : ADRESSE
C      OUT NONDP  : NOMBRE D'ONDES PLANES
C      OUT IONDP  : ADRESSE
C      OUT SOLVEU : NOM DU SOLVEUR
C      OUT IINTEG : TYPE D'INTEGRATION
C                   1 : NEWMARK
C                   2 : WILSON
C                   3 : DIFF_CENTRE
C                   4 : ADAPT
C      OUT T0     : INSTANT INITIAL
C      OUT NUME   : NUMERO D'ORDRE DE REPRISE
C      IN  BASENO : BASE DU NOM DES STRUCTURES
C      OUT NUMREP : NUMERO DE REUSE POUR LA TABLE PARA_CALC
C ----------------------------------------------------------------------
C
      IMPLICIT NONE
C
      INCLUDE 'jeveux.h'
      INTEGER IMAT(3)
      INTEGER NVECA, NCHAR
      INTEGER IAADVE, IALIFO, IONDP, IENER
      INTEGER IINTEG, NONDP
      INTEGER NUME,NUMREP
C
      REAL*8  T0
C
      LOGICAL LAMORT
C
      CHARACTER*8 RESULT,BASENO
      CHARACTER*8 MASSE, RIGID, AMORT
      CHARACTER*8 MATERI, CARAEL
      CHARACTER*19 LISCHA, SOLVEU
      CHARACTER*24 MODELE, NUMEDD, MATE, CARELE
      CHARACTER*24 CHARGE, INFOCH, FOMULT
C
C

      INTEGER NIV, IFM
      INTEGER NR, NM, NA, NVECT, IVEC, IE, N1
      INTEGER IAUX, IBID
      INTEGER INDIC, NOND, JINF, IALICH, ICH

      REAL*8 RVAL

      CHARACTER*8 K8B
      CHARACTER*8 BLAN8
      CHARACTER*16 METHOD
      CHARACTER*16 K16BID, NOMCMD
      CHARACTER*19 CHANNO
      INTEGER      IARG
C
C     -----------------------------------------------------------------
C
C====
C 1. PREALABLES
C====
C
      MODELE = ' '
      BLAN8  = ' '
C
      LAMORT = .TRUE.
      AMORT = ' '
C
      CALL INFNIV(IFM,NIV)
C
C====
C 2. LES DONNEES DU CALCUL
C====
C
C 2.1. ==> LE CONCEPT RESULTAT CREE PAR LA COMMANDE
C
      CALL GETRES(RESULT,K16BID,NOMCMD)

C 2.3. ==> CALCUL DES ENERGIES
C
      CALL WKVECT(BASENO//'.ENER      .VALE','V V R',6,IENER)

C 2.4. ==> --- LES MATRICES ---
      CALL GETVID(' ','MATR_RIGI',0,IARG,1,RIGID,NR)
      CALL GETVID(' ','MATR_MASS',0,IARG,1,MASSE,NM)
      CALL GETVID(' ','MATR_AMOR',0,IARG,1,AMORT,NA)
      IF ( NA.LE.0 ) THEN
        WRITE(IFM,*)'PAS DE MATRICE D''AMORTISSEMENT'
        LAMORT = .FALSE.
      ENDIF
      CALL MTDSCR(RIGID)
      CALL JEVEUO(RIGID//'           .&INT','E',IMAT(1))
      CALL MTDSCR(MASSE)
      CALL JEVEUO(MASSE//'           .&INT','E',IMAT(2))
      IF ( LAMORT ) THEN
        CALL MTDSCR(AMORT)
        CALL JEVEUO(AMORT//'           .&INT','E',IMAT(3))
      ENDIF
C
C====
C 3. LE CHARGEMENT
C====
C
C 3.1. ==> DECODAGE DU CHARGEMENT
C
      CALL GETFAC('EXCIT',NVECT)
C
      IF ( NVECT.GT.0 ) THEN
C
C 3.1.1. ==> DECODAGE DU CHARGEMENT
C
        NVECA = 0
        NCHAR = 0
        DO 311 , IVEC = 1 , NVECT
          CALL GETVID('EXCIT','VECT_ASSE',IVEC,IARG,1,CHANNO,IAUX)
          IF ( IAUX.EQ.1 ) THEN
            NVECA = NVECA + 1
          ENDIF
          CALL GETVID('EXCIT','CHARGE',   IVEC,IARG,1,CHANNO,IAUX)
          IF ( IAUX.EQ.1 ) THEN
            NCHAR = NCHAR + 1
          ENDIF
  311   CONTINUE
C
C 3.1.2. ==> LISTE DE VECT_ASSE DECRIVANT LE CHARGEMENT
C
        IF ( NVECA.NE.0 ) THEN
C
          CALL WKVECT(BASENO//'.LIFONCT'   ,'V V K24',NVECA,IALIFO)
          CALL WKVECT(BASENO//'.ADVECASS','V V I  ',NVECA,IAADVE)
C
          INDIC = 0
          DO 312 IVEC= 1, NVECA
            INDIC = INDIC + 1
 3121       CONTINUE
            CALL GETVID('EXCIT','VECT_ASSE',INDIC,IARG,1,CHANNO,IAUX)
            IF ( IAUX.EQ.0 ) THEN
               INDIC = INDIC + 1
               GOTO 3121
            ENDIF
            CALL CHPVER('F',CHANNO,'NOEU','DEPL_R', IBID )
            CALL JEVEUO(CHANNO//'.VALE','L',ZI(IAADVE+IVEC-1))
            CALL GETVID('EXCIT','FONC_MULT',INDIC,IARG,1
     &                  ,ZK24(IALIFO+IVEC-1), IAUX)
            IF ( IAUX.EQ.0 ) THEN
              CALL GETVID('EXCIT','ACCE',INDIC,IARG,1
     &                  ,ZK24(IALIFO+IVEC-1),IAUX)
              IF ( IAUX.EQ.0) THEN
                 RVAL = 1.D0
                 CALL GETVR8('EXCIT','COEF_MULT',INDIC,IARG,1,RVAL,IAUX)
                 ZK24(IALIFO+IVEC-1) = BASENO//'.F_'
                 CALL CODENT(IVEC,'G',ZK24(IALIFO+IVEC-1)(12:19))
                 CALL FOCSTE(ZK24(IALIFO+IVEC-1),'INST',RVAL,'V')
              ENDIF
            ENDIF
  312     CONTINUE


        ENDIF
C
C 3.1.3. ==> LISTE DES CHARGES
C
        IF ( NCHAR.NE.0 ) THEN
          CALL GETVID(' ','MODELE',0,IARG,1,K8B, IAUX)
          IF ( IAUX.EQ.0 ) THEN
            CALL U2MESS('F','ALGORITH9_26')
          ENDIF
          CALL NMDOME ( MODELE, MATE, CARELE, LISCHA,BLAN8,
     &                   IBID )
          FOMULT = LISCHA//'.FCHA'
        ENDIF
C
C 3.1.4. ==> PAS DE CHARGES
C
      ELSE
C
        NVECA=0
        NCHAR=0
C
      ENDIF

C 3.2. ==> TEST DE LA PRESENCE DE CHARGES DE TYPE 'ONDE_PLANE'

      NONDP = 0
      IF ( NCHAR.NE.0 ) THEN
         CALL JEVEUO(INFOCH,'L',JINF)
         CALL JEVEUO(CHARGE,'L',IALICH)
         DO 32 ICH = 1,NCHAR
            IF (ZI(JINF+NCHAR+ICH).EQ.6) THEN
               NONDP = NONDP + 1
            ENDIF
   32    CONTINUE
      ENDIF

      IF ( NVECA.NE.0 .AND. NCHAR.NE.0 ) THEN
        IF ( NCHAR.NE.NONDP ) THEN
          CALL U2MESS('F','ALGORITH9_27')
        ENDIF
      ENDIF

C 3.3. ==> RECUPERATION DES DONNEES DE CHARGEMENT PAR ONDE PLANE

      IF ( NONDP.EQ.0 ) THEN
         CALL WKVECT(BASENO//'.ONDP','V V K8',1,IONDP)
      ELSE
        CALL WKVECT(BASENO//'.ONDP','V V K8',NONDP,IONDP)
        NOND = 0
        DO 33 ICH = 1,NCHAR
          IF ( ZI(JINF+NCHAR+ICH).EQ.6 ) THEN
            NOND = NOND + 1
            ZK8(IONDP+NOND-1) = ZK24(IALICH+ICH-1)(1:8)
          ENDIF
   33   CONTINUE
      ENDIF

C
C====
C 4. AUTRES DONNEES
C====
C
C 4.1. ==>
C
      CALL DISMOI('F','NOM_NUME_DDL',RIGID,'MATR_ASSE',IBID,NUMEDD,IE)
      CALL DISMOI('F','NOM_MODELE',RIGID,'MATR_ASSE',IBID,MODELE,IE)
      CALL DISMOI('F','CARA_ELEM',RIGID,'MATR_ASSE',IBID,CARAEL,IE)
      MATERI = ' '
      CALL DISMOI('F','CHAM_MATER',RIGID,'MATR_ASSE',IBID,MATERI,IE)
      IF ( MATERI.NE.' ' ) THEN
        CALL RCMFMC( MATERI , MATE )
      ENDIF
C
C 4.2. ==> LECTURE DES PARAMETRES DU MOT CLE FACTEUR SOLVEUR ---

      CALL CRESOL (SOLVEU)
C
C 4.3. ==> TYPE D'INTEGRATION
C
      CALL GETVTX('SCHEMA_TEMPS','SCHEMA',1,IARG,1,METHOD,N1)
C
      IF ( METHOD.EQ.'NEWMARK' ) THEN
        IINTEG = 1
      ELSE
        IF (  METHOD.EQ.'WILSON' ) THEN
          IINTEG=2
        ELSE
          IF (  METHOD.EQ.'DIFF_CENTRE' ) THEN
            IINTEG=3
          ELSE
            IF (  METHOD.EQ.'ADAPT_ORDRE2') THEN
              IINTEG=4
            ENDIF
          ENDIF
        ENDIF
      ENDIF
C
C 4.4. ==> L'INSTANT INITIAL ET SON NUMERO D'ORDRE SI REPRISE
C
      CALL DLTP0(T0,NUME)
C
C --- CREATION DE LA TABLE DES PARAMETRES A SAUVEGARDER
C
      CALL NMCRPC(RESULT)
C
C --- RECUPERATION NUMERO REUSE - TABLE PARA_CALC
C
      CALL NMARNR(RESULT,'PARA_CALC',NUMREP)
C
      END
