      SUBROUTINE NMDETE ( MODELZ, MATE, CHARGE, INFCHA, INSTAN,
     &                    TYPESE, STYPSE, NOPASE,
     &                    TEMMOZ, EXITMP )
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 16/05/2007   AUTEUR COURTOIS M.COURTOIS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
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
C    DETERMINATION DU CHAMP DE TEMPERATURE OU DE SA DERIVEE
C IN  MODELE  : NOM DU MODELE
C IN  MATE    : CHAMP DE MATERIAU
C IN  CHARGE  : LISTE DES CHARGES
C IN  INFCHA  : INFORMATIONS SUR LES CHARGEMENTS
C IN  INSTAM  : INSTAM DE LA DETERMINATION
C IN  TYPESE  : TYPE DE SENSIBILITE
C IN  TYPESE  : TYPE DE SENSIBILITE
C                0 : CALCUL STANDARD, NON DERIVE
C                SINON : DERIVE (VOIR METYSE)
C IN  STYPSE  : SOUS-TYPE DE SENSIBILITE (VOIR NTTYSE)
C IN  NOPASE  : NOM DU PARAMETRE SENSIBLE LE CAS ECHEANT
C VAR TEMMOI  : CHAM_NO_TEMP_R (OU CARTE_TEMP_F(INST,EPAIS))
C OUT EXITMP  : TRUE SI LE CHAMP N'EST PAS CONSTRUIT PAR DEFAUT
C ----------------------------------------------------------------------
C
      IMPLICIT NONE
C
C 0.1. ==> ARGUMENTS
C
      INTEGER TYPESE
      LOGICAL     EXITMP
      CHARACTER*8  MODELE
      CHARACTER*19 TEMMOI
      CHARACTER*24 CHARGE,INFCHA
      CHARACTER*24 STYPSE
      CHARACTER*(*) NOPASE
      CHARACTER*(*)      MODELZ,       MATE, TEMMOZ
C
      REAL*8 INSTAN
C
C 0.2. ==> COMMUNS
C
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER            ZI
      COMMON  / IVARJE / ZI(1)
      CHARACTER*8        ZK8
      CHARACTER*16                ZK16
      CHARACTER*24                          ZK24
      CHARACTER*32                                    ZK32
      CHARACTER*80                                              ZK80
      COMMON  / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) , ZK80(1)
C
C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------
C
C 0.3. ==> VARIABLES LOCALES
C
      INTEGER NCHAR, NUCHTH, NBCHAM
      INTEGER VALI
      INTEGER JCHAR, JINF, JTEMP
      INTEGER IERD, ICORET, IRET, IBID
C
      REAL*8 TIME
      REAL*8 VALR
      REAL*8 ZERO
C
      CHARACTER*1        BASE
      CHARACTER*8        TEMPE,K8BID
      CHARACTER*16       NOMCHA
      CHARACTER*16       TYSD
      CHARACTER*19       CH19
      CHARACTER*24       NOM24,LIGRMO
      CHARACTER*24       VALK(2)
C
      COMPLEX*16         CBID
C
      LOGICAL CHPNUL
C
C DEB ------------------------------------------------------------------
C
C====
C 1. DECODAGE
C====
C
      CALL JEMARQ()
      EXITMP = .FALSE.
      MODELE = MODELZ
      TEMMOI = TEMMOZ
C
C 1.1. ==> LA BASE
C
      BASE   = 'V'
      LIGRMO = MODELE//'.MODELE'
      CHPNUL = .TRUE.
C
C 1.2. ==> LE NOMBRE DE CHARGES
C
      CALL JEEXIN(CHARGE,IRET)
C
      IF ( IRET .NE. 0 ) THEN
        CALL JELIRA(CHARGE,'LONMAX',NCHAR,K8BID)
        CALL JEVEUO(CHARGE,'L',JCHAR)
        CALL JEVEUO(INFCHA,'L',JINF)
        NUCHTH = ZI(JINF+2*NCHAR+1)
      ELSE
        NUCHTH = 0
      ENDIF
C
C====
C 2. AVEC DES CHARGES
C====
C
      IF ( NUCHTH .GT. 0 ) THEN
C
C 2.1. ==> ON RECUPERE LE NOM DE LA STRUCTURE THERMIQUE ASSOCIE AU
C          CALCUL MECANIQUE
C
C 2.1.1. ==> POUR LA REFERENCE
C
        NOM24 = ZK24(JCHAR+NUCHTH-1)(1:8)//'.CHME.TEMPE.TEMP'
        CALL JEVEUO(NOM24,'L',JTEMP)
        TEMPE = ZK8(JTEMP)
C
        CALL GETTCO (TEMPE,TYSD)
C
C 2.1.2. ==> DANS LE CAS D'UN CALCUL DERIVE
C            REMARQUE : IL FAUT APPLIQUER GETTCO SUR LA STRUCTURE
C            PREMIERE CAR LE TYPE DES STRUCTURES DERIVEES EST INCONNU
C            PAR GETTCO, FONCTION SUPERVISEUR
C
        IF ( TYPESE.EQ.-1 ) THEN
          K8BID = TEMPE
          CALL PSGENC ( K8BID, NOPASE, TEMPE, IRET )
          IF ( IRET.NE.0 ) THEN
             VALK(1) = K8BID
             VALK(2) = NOPASE(1:8)
             CALL U2MESK('F','ALGORITH7_17', 2 ,VALK)
          ENDIF
        ENDIF
C
C 2.2. ==> SI LE CHAMP FINAL EXISTE DEJA, ON LE DETRUIT:
C
        CALL DETRSD('CHAMP_GD',TEMMOI)
C
C 2.3. ==> CHOIX SELON LE TYPE DE DONNEES
C
        IF ( TYPESE.LE.0 ) THEN
C
C 2.3.1. ==> ON RECUPERE UN CALCUL THERMIQUE PREALABLE
C
        IF ( TYSD(1:9).EQ.'EVOL_THER' ) THEN
C
          CALL DISMOI('F','NB_CHAMP_UTI',TEMPE,'RESULTAT',NBCHAM,
     &                K8BID,IERD)
C
C --------- RECUPERATION DU CHAMP DE TEMPERATURE DANS TEMPE
C
          IF ( NBCHAM.GT.0 ) THEN
C
            TIME = INSTAN
            NOMCHA = 'TEMP'
            CALL RSINCH(TEMPE,NOMCHA,'INST',TIME,TEMMOI,
     &                  'CONSTANT','CONSTANT',1,BASE,ICORET)
C
            IF (ICORET.GE.10) THEN
              VALK(1) = TEMPE
              VALR    = TIME
              VALI    = ICORET
              CALL U2MESG('F', 'ALGORITH13_64',1,VALK,1,VALI,1,VALR)
            ENDIF
            EXITMP = .TRUE.
            CHPNUL = .FALSE.
          ELSE
            CALL U2MESK('F','ALGORITH7_18',1,TEMPE)
          ENDIF
C
C 2.3.2. ==> C'EST UNE CARTE, UN CHAM_NO OU UN CHAM_ELEM
C
         ELSE IF ((TYSD(1:8).EQ.'CHAM_NO_') .OR.
     &            (TYSD(1:6).EQ.'CARTE_') .OR.
     &            (TYSD(1:10).EQ.'CHAM_ELEM_')) THEN
C
          CH19 = TEMPE
          CALL COPISD('CHAMP_GD','V',CH19(1:19),TEMMOI)
          EXITMP = .TRUE.
          CHPNUL = .FALSE.
C
C 2.3.3. ==> C'EST PAS PREVU ...
C
        ELSE
          CALL U2MESK('F','ALGORITH7_19',1,TEMPE)
C
        ENDIF
C
        ENDIF
C
      ELSE
C
C====
C 3. IL N'Y A PAS DE CHARGES THERMIQUES
C    CREATION D'UNE CARTE CONSTANTE AFFECTEE A TREF
C    LE NOM DU CHAMP DE TEMPERATURE EST BIDONIFIE
C====
C
        CALL EXISD('CHAMP_GD',MATE(1:8)//'.TEMPE_REF',IRET)
C
        IF (IRET.NE.0) THEN
          CALL COPISD('CHAMP_GD','V',MATE(1:8)//'.TEMPE_REF ',TEMMOI)
          CHPNUL = .FALSE.
        ENDIF
C
      ENDIF
C
C====
C 4. ON REGROUPE ICI TOUS LES CAS OU ON AFFECTE UNE VALEUR NULLE
C    AU CHAMP :
C    SI C'EST UNE TEMPERATURE, QUAND RIEN N'A ETE DIT DANS LES
C    COMMANDES
C    SI C'EST UNE DERIVEE DE LA TEMPERATURE, QUAND CE
C    N'EST PAS LA RECUPERATION D'UN CALCUL THERMIQUE PREALABLE
C    LE NOM DU CHAMP DE TEMPERATURE EST BIDONIFIE
C===
C
      IF ( CHPNUL ) THEN
C
        ZERO = 0.D0
        CALL MECACT('V',TEMMOI,'MODELE',LIGRMO,'TEMP_R',1,'TEMP',IBID,
     &               ZERO,CBID,K8BID)
C
      ENDIF
C
C FIN ------------------------------------------------------------------
      CALL JEDEMA()
      END
