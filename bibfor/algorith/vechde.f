      SUBROUTINE VECHDE(TYPCAL,MODELZ,NCHAR,LCHAR,MATE,CARELZ,PARTPS,
     &                  DEPLAZ,CONTRZ,CHVARC,DERITZ,LIGREZ,NOPASZ,
     &                  LVECHZ)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 08/11/2010   AUTEUR PELLET J.PELLET 
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

C     TERMES DUS A LA DERIVATION DE L'EQUATION DE LA MECANIQUE

C IN  TYPCAL : TYPE DU CALCUL :
C               'DLAG', POUR LE CALCUL DE LA DERIVEE LAGRANGIENNE
C               'MECA', POUR LE CALCUL DE LA DERIVEE MATERIAU K
C               'MECM', POUR LE CALCUL DE LA DERIVEE MATERIAU M
C               'DYNK', POUR LE CALCUL DE LA DERIVEE RAIDEUR
C               'DYNM', POUR LE CALCUL DE LA DERIVEE MASSE
C               'DYNC', POUR LE CALCUL DE LA DERIVEE AMORTISSEMENT
C IN  MODELZ : NOM DU MODELE
C IN  NCHAR  : NOMBRE DE CHARGES
C IN  LCHAR  : LISTE DES CHARGES
C IN  MATE   : MATERIAU
C IN  CARELZ : CARACTERISTIQUES DES POUTRES ET COQUES
C IN  PARTPS : TABLEAU DONNANT T+, DELTAT ET THETA (POUR LE THM)
C IN  DEPLAZ : CHAMP DE DEPLACEMENT
C IN  CONTRZ : CHAMP DE CONTRAINTES
C IN  CHVARC : CHAMP DE VARIABLE DE COMMANDE
C IN  DERITZ : DERIVEE DE LA TEMPERATURE
C IN  LIGRMO : (SOUS-)LIGREL DE MODELE POUR CALCUL REDUIT
C                 SI ' ', ON PREND LE LIGREL DU MODELE
C IN  NOPASE : PARAMETRE SENSIBLE
C              . POUR LA DERIVEE LAGRANGIENNE, C'EST UN CHAMP THETA
C VAR LVECHZ : LISTE DES VECTEURS ELEMENTAIRES
C ----------------------------------------------------------------------

C TOLE  CRP_20

      IMPLICIT NONE

C 0.1. ==> ARGUMENTS

      CHARACTER*4 TYPCAL
      CHARACTER*(*) MODELZ,CARELZ,MATE,DEPLAZ,CONTRZ
      CHARACTER*(*) DERITZ,NOPASZ
      CHARACTER*(*) LVECHZ,LIGREZ,LCHAR(*)

      REAL*8 PARTPS(3)

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
      INTEGER NCHINX,NCHOUX
      PARAMETER (NOMPRO='VECHDE')
      PARAMETER (NCHINX=30,NCHOUX=1)

      INTEGER IBID
      CHARACTER*8 K8BID
      COMPLEX*16 CBID

      INTEGER IRET,JLVE,ICHA
      INTEGER NUMORD,NH,ICODE
      INTEGER NCHIN,NCHOUT,NCHAR,IFM,NIV

      CHARACTER*2 CODRET
      CHARACTER*7 NOMCMP(3)
      CHARACTER*8 LPAIN(NCHINX),LPAOUT(NCHOUX)
      CHARACTER*8 NEWNOM,CARA,NOMCHA
      CHARACTER*8 NOPASE,MATERS
      CHARACTER*16 OPTION
      CHARACTER*19 CHVARC,VECEL
      CHARACTER*24 MODELE,CARELE,LVECHP
      CHARACTER*24 LIGRMO,CHCHAR,LCH24
      CHARACTER*24 CHGEOM,CHCARA(18),CHTIME,CHCARS(18)
      CHARACTER*24 LCHIN(NCHINX),LCHOUT(NCHOUX)
      CHARACTER*24 DEPLA,CONTRR,DERITE
      CHARACTER*24 VECTTH,MATSEN,MATERI,CHHARM

      REAL*8 TIME

      LOGICAL EXIGEO,ZFAT,EXICAR


C DEB ------------------------------------------------------------------

      CALL INFNIV(IFM,NIV)
      CALL JEMARQ()
      NEWNOM = '.0000000'
      CHCHAR = ' '
      TIME = PARTPS(1)

      IF (TYPCAL(1:4).NE.'DLAG' .AND. TYPCAL(1:4).NE.'MECA' .AND.
     &    TYPCAL(1:4).NE.'MECM' .AND.
     &    TYPCAL(1:4).NE.'DYNK' .AND. TYPCAL(1:4).NE.'DYNM') THEN
        CALL ASSERT(.FALSE.)
      ENDIF

C====
C 1. PREPARATIONS GENERALES
C====

C 1.1. ==> SAUVEGARDE DES ARGUMENTS

      MODELE = MODELZ
      CARELE = CARELZ
      DEPLA = DEPLAZ
      CONTRR = CONTRZ
      DERITE = DERITZ
      LVECHP = LVECHZ
      LIGRMO = LIGREZ
      NOPASE = NOPASZ

C 1.2. ==> VECTEUR DES TERMES ELEMENTAIRES

      VECEL = '&&'//NOMPRO
      CALL JEEXIN(LVECHP,IRET)
      IF (IRET.EQ.0) THEN
        LVECHP = VECEL//'.RELR'
        CALL MEMARE('V',VECEL,MODELE(1:8),MATE,CARELE,'CHAR_MECA')
        CALL WKVECT(LVECHP,'V V K24',1,JLVE)
      ELSE
        CALL JEVEUO(LVECHP,'E',JLVE)
      END IF

C====
C 2. PREPARATIONS PROPRES A LA DERIVEE LAGRANGIENNE
C====
      IF (TYPCAL.EQ.'DLAG') THEN

C 2.1. ==> LA GEOMETRIE

        CALL MEGEOM(MODELE,'      ',EXIGEO,CHGEOM)

        IF (LIGRMO.EQ.' ') THEN
          LIGRMO = MODELE(1:8)//'.MODELE'
        END IF

C 2.2. ==> LE CHAMP THETA POUR LA DERIVEE LAGRANGIENNE

        NUMORD = 0
        CALL RSEXCH(NOPASE,'THETA',NUMORD,VECTTH,IRET)

C 2.3. ==> LES PARAMETRES TEMPORELS

        CHTIME = '&&'//NOMPRO//'.CH_INST_R'
        NOMCMP(1) = 'INST   '
        NOMCMP(2) = 'DELTAT '
        NOMCMP(3) = 'THETA  '

        CALL MECACT('V',CHTIME,'LIGREL',LIGRMO,'INST_R  ',3,NOMCMP,IBID,
     &              PARTPS,CBID,K8BID)

C 2.4. ==> DEFINITION DES ARGUMENTS DE CALCUL

        LPAIN(1) = 'PGEOMER'
        LCHIN(1) = CHGEOM
        LPAIN(2) = 'PMATERC'
        LCHIN(2) = MATE
        LPAIN(3) = 'PTEMPSR'
        LCHIN(3) = CHTIME
        LPAIN(4) = 'PDEPLAR'
        LCHIN(4) = DEPLA
        LPAIN(5) = 'PCONTRR'
        LCHIN(5) = CONTRR
        LPAIN(6) = 'PVARCPR'
        LCHIN(6) = CHVARC
        LPAIN(7) = 'PVECTTH'
        LCHIN(7) = VECTTH
        LPAIN(8) = 'PVARCMR'
        LCHIN(8) = DERITE
        NCHIN = 8

        OPTION = 'CHAR_DLAG_MECAST'

        LPAOUT(1) = 'PVECTUR'

      END IF


C====
C 3. PREPARATIONS PROPRES AUX DERIVEES MATERIAU
C====
      IF (TYPCAL.NE.'DLAG') THEN

C 3.1. ==> DEFINITION DU MATERIAU DERIVE CODE

C      DETERMINATION DU CHAMP MATERIAU A PARTIR DE LA CARTE CODEE
        MATERI = MATE(1:8)
        CARA = CARELE(1:8)
        OPTION = ' '

C      DETERMINATION DE CARA_ELEM DERIVE NON CODE MATSEN
        CALL PSGENC(CARA,NOPASE,MATERS,IRET)
        IF (IRET.EQ.0) THEN
C CAS ELEMENTS DISCRETS
          CALL MECARA(MATERS,EXICAR,CHCARS)
          MATSEN(1:24) = MATERI(1:8)//MATE(9:24)

        ELSE

C      DETERMINATION DU CHAMP MATERIAU DERIVE NON CODE MATSEN
         CALL PSGENC(MATERI,NOPASE,MATERS,IRET)
         IF (IRET.NE.0) THEN
          CALL U2MESK('F','CALCULEL2_87',1,MATERI)
         END IF
C      TRANSFORMATION EN CHAMP MATERIAU DERIVE CODE
         MATSEN = '                        '
         MATSEN(1:24) = MATERS(1:8)//MATE(9:24)
         CALL MECARA(CARELE,EXICAR,CHCARS)

        ENDIF

C 3.2. ==> LES DONNEES MECANIQUES

C------DETECTION D'UN CHARGEMENT EN DEFORMATIONS INITIALES ET
C------EMISSION D'UN MESSAGE D'ERREUR FATALE DANS CE CAS
        IF (NCHAR.NE.0) THEN
          ZFAT = .FALSE.
          DO 10 ICHA = 1,NCHAR
            NOMCHA = LCHAR(ICHA) (1:8)
            LCH24 = NOMCHA//'.CHME.EPSIN.DESC'
            CALL JEEXIN(LCH24,IRET)
            IF (IRET.NE.0) ZFAT = .TRUE.
   10     CONTINUE
          IF (ZFAT) THEN
            CALL U2MESS('F','SENSIBILITE_11')
          ENDIF
        ENDIF
C------
C------
        NH = 0
        CALL MECHAM(OPTION,MODELE,NCHAR,LCHAR,CARA,NH,CHGEOM,CHCARA,
     &              CHHARM,ICODE)


C 3.3. ==> LES CHARGEMENTS DE PESANTEUR
        CALL MECHPE(NCHAR,LCHAR,CHCHAR)

C 3.4. ==> LES PARAMETRES TEMPORELS

        CHTIME = '&&MERIME.CHAMP_INST'
        CALL MECACT('V',CHTIME,'MODELE',MODELE//'.MODELE','INST_R',1,
     &              'INST',IBID,TIME,CBID,K8BID)

      END IF

C====
C 4. PREPARATIONS PROPRES A LA DERIVEE EN STATIQUE
C====
      IF (TYPCAL(1:4).EQ.'MECA') THEN

C 4.1. ==> LES VARIABLES DE COMMANDES
        CALL VRCINS(MODELE,MATE,CARELE,TIME,CHVARC(1:19),CODRET)

C 4.2.=>  DEFINITION DES ARGUMENTS DE CALCUL

        LIGRMO = MODELE(1:8)//'.MODELE'
        LPAIN(1) = 'PGEOMER'
        LCHIN(1) = CHGEOM
        LPAIN(2) = 'PMATERC'
        LCHIN(2) = MATE
        LPAIN(3) = 'PCAORIE'
        LCHIN(3) = CHCARA(1)
        LPAIN(4) = 'PCADISK'
        LCHIN(4) = CHCARA(2)
        LPAIN(5) = 'PCAGNPO'
        LCHIN(5) = CHCARA(6)
        LPAIN(6) = 'PCACOQU'
        LCHIN(6) = CHCARA(7)
        LPAIN(7) = 'PCASECT'
        LCHIN(7) = CHCARA(8)
        LPAIN(8) = 'PVARCPR'
        LCHIN(8) = CHVARC
        LPAIN(9) = 'PCAARPO'
        LCHIN(9) = CHCARA(9)
        LPAIN(10) = 'PHARMON'
        LCHIN(10) = CHHARM
        LPAIN(11) = 'PPESANR'
        LCHIN(11) = CHCHAR
        LPAIN(12) = 'PCINFDI'
        LCHIN(12) = CHCARA(15)
        LPAIN(13) = ' '
        LCHIN(13) = ' '
        LPAIN(14) = 'PCAGNBA'
        LCHIN(14) = CHCARA(11)
        LPAIN(15) = 'PCAMASS'
        LCHIN(15) = CHCARA(12)
        LPAIN(16) = 'PCAPOUF'
        LCHIN(16) = CHCARA(13)
        LPAIN(17) = 'PCAGEPO'
        LCHIN(17) = CHCARA(5)
        LPAIN(18) = 'ZVARIPG'
        LCHIN(18) = CHVARC
        LPAIN(19) = 'PTEMPSR'
        LCHIN(19) = CHTIME
        LPAIN(20) = 'PNBSP_I'
        LCHIN(20) = CHCARA(16)
        LPAIN(21) = 'PFIBRES'
        LCHIN(21) = CHCARA(17)
C ... LA CARTE MATERIAU DERIVEE
        LPAIN(22) = 'PMATSEN'
        LCHIN(22) = MATSEN
C ... CHAMPS DE DEPLACEMENTS A T+/T-
        LPAIN(23) = 'PVAPRIN'
        LCHIN(23) = DEPLA
C ... LA CARTE MATRICE RAIDEUR ELEMENTAIRE DISCRETE DERIVEE
        LPAIN(24) = 'PSEDISK'
        LCHIN(24) = CHCARS(2)
        NCHIN = 24

        OPTION = 'RIGI_MECA_SENSI'

        LPAOUT(1) = 'PVECTUR'

      END IF

C====
C 5. PREPARATIONS PROPRES A LA DERIVEE RAIDEUR EN DYNAMIQUE
C====
      IF (TYPCAL.EQ.'DYNK') THEN

C 5.1. ==>  DEFINITION DES ARGUMENTS DE CALCUL

        LIGRMO = MODELE(1:8)//'.MODELE'
        LPAIN(1) = 'PGEOMER'
        LCHIN(1) = CHGEOM
        LPAIN(2) = 'PMATERC'
        LCHIN(2) = MATE
        LPAIN(3) = 'PCAORIE'
        LCHIN(3) = CHCARA(1)

        LPAIN(4) = 'PCADISK'
        LCHIN(4) = CHCARA(2)

        LPAIN(5) = 'PCAGNPO'
        LCHIN(5) = CHCARA(6)
        LPAIN(6) = 'PCACOQU'
        LCHIN(6) = CHCARA(7)
        LPAIN(7) = 'PCASECT'
        LCHIN(7) = CHCARA(8)
        LPAIN(8) = 'PVARCPR'
        LCHIN(8) = CHVARC
        LPAIN(9) = 'PCAARPO'
        LCHIN(9) = CHCARA(9)
        LPAIN(10) = 'PHARMON'
        LCHIN(10) = CHHARM
        LPAIN(11) = 'PPESANR'
        LCHIN(11) = CHCHAR
        LPAIN(12) = 'PGEOME2'
        LCHIN(12) = CHGEOM
        LPAIN(13) = ' '
        LCHIN(13) = ' '
        LPAIN(14) = 'PCAGNBA'
        LCHIN(14) = CHCARA(11)
        LPAIN(15) = 'PCAMASS'
        LCHIN(15) = CHCARA(12)
        LPAIN(16) = 'PCAPOUF'
        LCHIN(16) = CHCARA(13)
        LPAIN(17) = 'PCAGEPO'
        LCHIN(17) = CHCARA(5)
        LPAIN(18) = 'PTEMPSR'
        LCHIN(18) = CHTIME
        LPAIN(19) = 'PNBSP_I'
        LCHIN(19) = CHCARA(16)
        LPAIN(20) = 'PFIBRES'
        LCHIN(20) = CHCARA(17)
C ... LA CARTE MATERIAU DERIVEE
        LPAIN(21) = 'PMATSEN'
        LCHIN(21) = MATSEN
C ... CHAMPS DE DEPLACEMENTS A T+/T-
        LPAIN(22) = 'PVAPRIN'
        LCHIN(22) = DEPLA
C ... LA CARTE MATRICE RAIDEUR ELEMENTAIRE DISCRETE DERIVEE
        LPAIN(23) = 'PSEDISK'
        LCHIN(23) = CHCARS(2)
        LPAIN(24) = 'PCINFDI'
        LCHIN(24) = CHCARA(15)
        NCHIN = 24

        OPTION = 'RIGI_MECA_SENS_C'

        LPAOUT(1) = 'PVECTUC'


      END IF

C====
C 5.2. PREPARATIONS PROPRES A LA DERIVEE MASSE (HARMONIQUE)
C====
      IF (TYPCAL.EQ.'DYNM') THEN

        LIGRMO = MODELE(1:8)//'.MODELE'
        LPAIN(1) = 'PGEOMER'
        LCHIN(1) = CHGEOM
        LPAIN(2) = 'PMATERC'
        LCHIN(2) = MATE
        LPAIN(3) = 'PCAORIE'
        LCHIN(3) = CHCARA(1)
        LPAIN(4) = 'PCADISM'
        LCHIN(4) = CHCARA(3)
        LPAIN(5) = 'PCAGNPO'
        LCHIN(5) = CHCARA(6)
        LPAIN(6) = 'PCACOQU'
        LCHIN(6) = CHCARA(7)
        LPAIN(7) = 'PCASECT'
        LCHIN(7) = CHCARA(8)
        LPAIN(8) = 'PVARCPR'
        LCHIN(8) = CHVARC
        LPAIN(9) = 'PCAARPO'
        LCHIN(9) = CHCARA(9)
        LPAIN(10) = 'PCACABL'
        LCHIN(10) = CHCARA(10)
        LPAIN(11) = 'PCAGEPO'
        LCHIN(11) = CHCARA(5)
        LPAIN(12) = 'PABSCUR'
        LCHIN(12) = CHGEOM(1:8)//'.ABS_CURV'
        LPAIN(13) = 'PCAGNBA'
        LCHIN(13) = CHCARA(11)
        LPAIN(14) = 'PCAPOUF'
        LCHIN(14) = CHCARA(13)
        LPAIN(15) = 'PNBSP_I'
        LCHIN(15) = CHCARA(16)
        LPAIN(16) = 'PFIBRES'
        LCHIN(16) = CHCARA(17)
        LPAIN(17) = 'PVAPRIN'
        LCHIN(17) = DEPLA
        LPAIN(18) = 'PSEDISM'
        LCHIN(18) = CHCARS(3)
C ... LA CARTE MATERIAU DERIVEE
        LPAIN(19) = 'PMATSEN'
        LCHIN(19) = MATSEN
        LPAIN(20) = 'PCINFDI'
        LCHIN(20) = CHCARA(15)

        NCHIN = 20

        OPTION = 'MASS_MECA_SENS_C'

        LPAOUT(1) = 'PVECTUC'

      END IF

C====
C 5.3. PREPARATIONS PROPRES A LA DERIVEE MASSE (TRANSITOIRE)
C====
      IF (TYPCAL.EQ.'MECM') THEN

        LIGRMO = MODELE(1:8)//'.MODELE'
        LPAIN(1) = 'PGEOMER'
        LCHIN(1) = CHGEOM
        LPAIN(2) = 'PMATERC'
        LCHIN(2) = MATE
        LPAIN(3) = 'PCAORIE'
        LCHIN(3) = CHCARA(1)
        LPAIN(4) = 'PCADISM'
        LCHIN(4) = CHCARA(3)
        LPAIN(5) = 'PCAGNPO'
        LCHIN(5) = CHCARA(6)
        LPAIN(6) = 'PCACOQU'
        LCHIN(6) = CHCARA(7)
        LPAIN(7) = 'PCASECT'
        LCHIN(7) = CHCARA(8)
        LPAIN(8) = 'PVARCPR'
        LCHIN(8) = CHVARC
        LPAIN(9) = 'PCAARPO'
        LCHIN(9) = CHCARA(9)
        LPAIN(10) = 'PCACABL'
        LCHIN(10) = CHCARA(10)
        LPAIN(11) = 'PCAGEPO'
        LCHIN(11) = CHCARA(5)
        LPAIN(12) = 'PABSCUR'
        LCHIN(12) = CHGEOM(1:8)//'.ABS_CURV'
        LPAIN(13) = 'PCAGNBA'
        LCHIN(13) = CHCARA(11)
        LPAIN(14) = 'PCAPOUF'
        LCHIN(14) = CHCARA(13)
        LPAIN(15) = 'PNBSP_I'
        LCHIN(15) = CHCARA(16)
        LPAIN(16) = 'PFIBRES'
        LCHIN(16) = CHCARA(17)
        LPAIN(17) = 'PVAPRIN'
        LCHIN(17) = DEPLA
        LPAIN(18) = 'PSEDISM'
        LCHIN(18) = CHCARS(3)
C ... LA CARTE MATERIAU DERIVEE
        LPAIN(19) = 'PMATSEN'
        LCHIN(19) = MATSEN
        LPAIN(20) = 'PCINFDI'
        LCHIN(20) = CHCARA(15)

        NCHIN = 20

        OPTION = 'MASS_MECA_SENSI'

        LPAOUT(1) = 'PVECTUR'

      END IF

C ==========
C 6. LANCEMENT DES CALCULS ELEMENTAIRES
C ==========

      NCHOUT = 1
      LCHOUT(1) = '&&'//NOMPRO//'.???????'
      CALL GCNCO2(NEWNOM)
      LCHOUT(1) (10:16) = NEWNOM(2:8)
      CALL CORICH('E',LCHOUT(1),-1,IBID)
      CALL CALCUL('S',OPTION,LIGRMO,NCHIN,LCHIN,LPAIN,NCHOUT,LCHOUT,
     &            LPAOUT,'V','OUI')

      ZK24(JLVE) = LCHOUT(1)
      CALL JEECRA(LVECHP,'LONUTI',1,K8BID)

      LVECHZ = LVECHP

C FIN ------------------------------------------------------------------
      CALL JEDEMA()

      END
