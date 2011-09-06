      SUBROUTINE MEMOKG(OPTIOZ,RESULT,MODELE,DEPLA,THETA,MATE,NCHAR,
     &                  LCHAR,SYMECH,FONDF,IORD,PULS,NBPRUP,NOPRUP)
      IMPLICIT NONE

      CHARACTER*8 MODELE,LCHAR(*),FONDF,RESULT,SYMECH
      CHARACTER*16 OPTIOZ,NOPRUP(*)
      CHARACTER*24 DEPLA,MATE,THETA
      REAL*8 TIME
      INTEGER IORD,NCHAR,NBPRUP
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 06/09/2011   AUTEUR GENIAUT S.GENIAUT 
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
C     - FONCTION REALISEE:   CALCUL DU TAUX DE RESTITUTION D'ENERGIE
C                             ET DES FACTEURS D'INTENSITE DE CONTRAINTES
C                            EN 2D POUR UN MODE PROPRE DE LA STRUCTURE

C IN   OPTION  --> K_G_MODA
C IN   RESULT  --> NOM UTILISATEUR DU RESULTAT ET TABLE
C IN   MODELE  --> NOM DU MODELE
C IN   DEPLA   --> CHAMPS DE DEPLACEMENT
C IN   THETA   --> CHAMP THETA
C IN   MATE    --> CHAMP DE MATERIAUX
C IN   NCHAR   --> NOMBRE DE CHARGES
C IN   LCHAR   --> LISTE DES CHARGES
C IN   SYMECH  --> SYMETRIE DU CHARGEMENT
C IN   FONDF   --> FOND DE FISSURE
C IN   IORD    --> NUMERO D'ORDRE DE LA SD
C IN   PULS    --> PULSATION PROPRE DU MODE IORD
C ......................................................................

      INTEGER I,IBID,IFIC,INORMA,INIT,IFM,NIV
      INTEGER IADRMA,IADRFF,ICOODE,IADRCO,IADRNO,JBASFO
      INTEGER LOBJ2,NDIMTE,NUNOFF,NDIM,NCHIN,IRET

      REAL*8 FIC(5),RCMP(4),VAL(5),PULS

      COMPLEX*16 CBID

      LOGICAL EXIGEO

      CHARACTER*2 CODRET
      CHARACTER*8 NOMA,FOND,LICMP(4),K8B
      CHARACTER*8 LPAIN(14),LPAOUT(1)
      CHARACTER*16 OPTION,VALK
      CHARACTER*19 CHVARC,CHVREF,BASEFO
      CHARACTER*24 CHGEOM,CHFOND,CHPULS
      CHARACTER*24 LCHIN(14),LCHOUT(1),LIGRMO,NOMNO,NORMA
      CHARACTER*24 OBJ1,OBJ2,COORD,COORN

C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------

      CHARACTER*32 JEXNOM
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
      CHARACTER*1 K1BID
      DATA CHVARC,CHVREF/'&&MEMOKG.VARC','&&CHVREF.VARC_REF'/

C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------

      CALL JEMARQ()
      OPTION = OPTIOZ
      TIME = 0.D0

C- RECUPERATION DU CHAMP GEOMETRIQUE

      CALL MEGEOM(MODELE,' ',EXIGEO,CHGEOM)
      NOMA = CHGEOM

C- RECUPERATION DE L'ETAT INITIAL

      CALL GETFAC('ETAT_INIT',INIT)
      IF (INIT.NE.0) THEN
        VALK='CALC_K_G'
        CALL U2MESK('F','RUPTURE1_13',1,VALK)
      END IF

C- RECUPERATION (S'ILS EXISTENT) DES CHAMP DE TEMPERATURES (T,TREF)

      CALL VRCINS(MODELE,MATE,' ',TIME,CHVARC,CODRET)
      CALL VRCREF(MODELE,MATE(1:8),'        ',CHVREF(1:19))

C OBJET DECRIVANT LE MAILLAGE

      OBJ1 = MODELE//'.MODELE    .LGRF'
      CALL JEVEUO(OBJ1,'L',IADRMA)
      NOMA = ZK8(IADRMA)
      NOMNO = NOMA//'.NOMNOE'
      COORN = NOMA//'.COORDO    .VALE'
      COORD = NOMA//'.COORDO    .DESC'
      CALL JEVEUO(COORN,'L',IADRCO)
      CALL JEVEUO(COORD,'L',ICOODE)
      NDIM = -ZI(ICOODE-1+2)

C OBJET CONTENANT LES NOEUDS DU FOND DE FISSURE

      FOND = FONDF(1:8)
      OBJ2 = FOND//'.FOND      .NOEU'
      CALL JELIRA(OBJ2,'LONMAX',LOBJ2,K1BID)
      IF (LOBJ2.NE.1) THEN
        CALL U2MESS('F','RUPTURE1_10')
      END IF
      CALL JEVEUO(OBJ2,'L',IADRNO)
      CALL JENONU(JEXNOM(NOMNO,ZK8(IADRNO)),NUNOFF)

C     OBJET CONTENANT LA BASE LOCALE AU FOND DE FISSURE
C     SI L'OBJET NORMALE EXISTE, ON LE PREND
C     SINON, ON PREND BASEFOND
      NORMA = FOND//'.NORMALE'
      CALL JEEXIN(NORMA,IRET)
      IF (IRET.NE.0) THEN
        CALL JEVEUO(NORMA,'L',INORMA)
        RCMP(3) = ZR(INORMA-1+1)
        RCMP(4) = ZR(INORMA-1+2)
      ELSEIF (IRET.EQ.0) THEN
        BASEFO = FOND//'.BASEFOND'
        CALL JEVEUO(BASEFO,'L',JBASFO)
        RCMP(3) = ZR(JBASFO-1+4)
        RCMP(4) = ZR(JBASFO-1+5)
      END IF

C CREATION OBJET CONTENANT COORDONNEES DU NOEUD DE FOND
C DE FISSURE ET LA NORMALE A LA FISSURE

      CALL WKVECT('&&MEMOKG.FOND','V V R8',4,IADRFF)

      LICMP(1) = 'XA'
      LICMP(2) = 'YA'
      LICMP(3) = 'XNORM'
      LICMP(4) = 'YNORM'
      RCMP(1) = ZR(IADRCO+NDIM* (NUNOFF-1))
      RCMP(2) = ZR(IADRCO+NDIM* (NUNOFF-1)+1)
      ZR(IADRFF) = RCMP(1)
      ZR(IADRFF+1) = RCMP(2)
      ZR(IADRFF+2) = RCMP(3)
      ZR(IADRFF+3) = RCMP(4)

      CHFOND = '&&MEMOKG.FOND'
      CALL MECACT('V',CHFOND,'MAILLA',NOMA,'FISS_R',4,LICMP,IBID,RCMP,
     &            CBID,' ')

      LIGRMO = MODELE//'.MODELE'

      CHPULS = '&&MEMOKG.PULS'
      CALL MECACT('V',CHPULS,'MODELE',LIGRMO,'FREQ_R  ',1,'FREQ   ',
     &            IBID,PULS,CBID,' ')

      NDIMTE = 5
      CALL WKVECT('&&MEMOKG.VALG','V V R8',NDIMTE,IFIC)
      LPAOUT(1) = 'PGTHETA'
      LCHOUT(1) = '&&FICGELE'

      LPAIN(1) = 'PGEOMER'
      LCHIN(1) = CHGEOM
      LPAIN(2) = 'PDEPLAR'
      LCHIN(2) = DEPLA
      LPAIN(3) = 'PTHETAR'
      LCHIN(3) = THETA
      LPAIN(4) = 'PMATERC'
      LCHIN(4) = MATE
      LPAIN(5) = 'PVARCPR'
      LCHIN(5) = CHVARC
      LPAIN(6) = 'PVARCRR'
      LCHIN(6) = CHVREF
      LPAIN(7) = 'PFISSR'
      LCHIN(7) = CHFOND
      LPAIN(8) = 'PPULPRO'
      LCHIN(8) = CHPULS

      NCHIN = 8

      CALL CALCUL('S',OPTION,LIGRMO,NCHIN,LCHIN,LPAIN,1,LCHOUT,LPAOUT,
     &            'V','OUI')

C  SOMMATION DES FIC ET G ELEMENTAIRES

      CALL MESOMM(LCHOUT(1),5,IBID,FIC,CBID,0,IBID)

C      FIC(4) = ABS(FIC(4))
C      FIC(2) = ABS(FIC(4))

      DO 20 I = 1,5
        ZR(IFIC+I-1) = FIC(I)
   20 CONTINUE

      IF (SYMECH.EQ.'SYME') THEN
        ZR(IFIC) = 2.D0*FIC(1)
        ZR(IFIC+1) = 2.D0*FIC(2)
        ZR(IFIC+2) = 0.D0
        ZR(IFIC+3) = 2.D0*FIC(4)
        ZR(IFIC+4) = 0.D0
      ELSE IF (SYMECH.EQ.'ANTI') THEN
        ZR(IFIC) = 2.D0*FIC(1)
        ZR(IFIC+1) = 0.D0
        ZR(IFIC+2) = 2.D0*FIC(3)
        ZR(IFIC+3) = 0.D0
        ZR(IFIC+4) = 2.D0*FIC(5)
      END IF

C IMPRESSION DE K1,K2,G ET ECRITURE DANS LA TABLE RESU

      CALL INFNIV(IFM,NIV)
      IF (NIV.GE.2) THEN
        CALL IMPFIC(ZR(IFIC),ZK8(IADRNO),RCMP,IFM,0)
      END IF

      VAL(1) = ZR(IFIC)
      VAL(2) = ZR(IFIC+3)
      VAL(3) = ZR(IFIC+4)
      VAL(4) = ZR(IFIC+1)*ZR(IFIC+1) + ZR(IFIC+2)*ZR(IFIC+2)

      CALL TBAJLI(RESULT,NBPRUP,NOPRUP,IORD,VAL,CBID,K8B,0)

      CALL DETRSD('CHAMP_GD',CHVARC)
      CALL DETRSD('CHAMP_GD',CHVREF)
      CALL JEDETR('&&MEMOKG.VALG')
      CALL JEDETR('&&MEMOKG.FOND')

      CALL JEDEMA()
      END
