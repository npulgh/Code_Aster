      SUBROUTINE MEFICG(OPTIOZ,RESULT,MODELE,DEPLA,THETA,MATE,NCHAR,
     &                  LCHAR,SYMECH,FONDF,EXTIM,TIME,IORD,NBPRUP,
     &                 NOPRUP,NOPASE,TYPESE,CHDESE,CHEPSE,CHSISE,
     &                 CHVITE,CHACCE)
      IMPLICIT NONE

      CHARACTER*8 MODELE,LCHAR(*),FONDF,RESULT,SYMECH
      CHARACTER*8 NOPASE
      CHARACTER*16 OPTIOZ,NOPRUP(*)
      CHARACTER*24 DEPLA,MATE,THETA
      CHARACTER*24 CHDESE,CHEPSE,CHSISE
      CHARACTER*24 CHVITE,CHACCE
      REAL*8 TIME
      INTEGER IORD,NCHAR,NBPRUP,TYPESE
      LOGICAL EXTIM
C ......................................................................
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 04/04/2007   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2004  EDF R&D                  WWW.CODE-ASTER.ORG
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
C     - FONCTION REALISEE:   CALCUL DES COEFFICIENTS D'INTENSITE DE
C                            CONTRAINTES K1 ET K2 EN 2D

C IN   OPTION  --> CALC_K_G   (SI CHARGES REELLES)
C              --> CALC_K_G_F (SI CHARGES FONCTIONS)
C IN   RESULT  --> NOM UTILISATEUR DU RESULTAT ET TABLE
C IN   MODELE  --> NOM DU MODELE
C IN   DEPLA   --> CHAMPS DE DEPLACEMENT
C IN   THETA   --> CHAMP THETA
C IN   MATE    --> CHAMP DE MATERIAUX
C IN   NCHAR   --> NOMBRE DE CHARGES
C IN   LCHAR   --> LISTE DES CHARGES
C IN   SYMECH  --> SYMETRIE DU CHARGEMENT
C IN   FONDF   --> FOND DE FISSURE
C IN   EXTIM   --> VRAI SI L'INSTANT EST DONNE
C IN   TIME    --> INSTANT DE CALCUL
C IN   IORD    --> NUMERO D'ORDRE DE LA SD
C IN   NBPRUP   --> NOMBRE DE PARAMETRES RUPTURE DANS LA TABLE
C IN   NOPRUP   --> NOMS DES PARAMETRES RUPTURE
C IN   NOPASE   --> NOM DU PARAMETRE SENSIBLE
C IN   TYPESE   --> TYPE DE SENSIBILITE (VOIR METYSE)
C IN   CHDESE   --> CHAMP DU DEPLACEMENT SENSIBLE (CALC_DK_DG_E ET _F)
C IN   CHEPSE   --> CHAMP DE DEFORMATION SENSIBLE (CALC_DK_DG_E ET _F)
C IN   CHSISE   --> CHAMP DE CONTRAINTE SENSIBLE (CALC_DK_DG_E ET _F)
C ......................................................................
C CORPS DU PROGRAMME
C TOLE CRP_21

      INTEGER I,IBID,IFIC,INORMA,INIT,IFM,NIV
      INTEGER IADRMA,IADRFF,ICOODE,IADRCO,IADRNO,ICHA,EXICHA
      INTEGER LOBJ2,NDIMTE,NUNOFF,NDIM,NCHIN,IER
      REAL*8 FIC(5),RCMP(4),VAL(5),VALPAS

      COMPLEX*16 CBID

      LOGICAL EXIGEO,FONC,EPSI

      CHARACTER*8 NOMA,FOND,LICMP(4)
      CHARACTER*8 LPAIN(13),LPAOUT(1),K8BID,NOMCHS,NOMCH0
      CHARACTER*8 LCHARS(NCHAR)
      CHARACTER*16 OPTION,OPTIO2
      CHARACTER*19 CF1D2D,CHPRES,CHROTA,CHPESA,CHVOLU,CF2D3D,CHEPSI
      CHARACTER*19 CF12SS,CF23SS,CHPRSS,CHROSS,CHPESS,CHVOSS,CHEPSS
      CHARACTER*19 CHVREF,CHVARC
      CHARACTER*24 CHGEOM,CHFOND
      CHARACTER*24 LCHIN(13),LCHOUT(1),LIGRMO,NOMNO,NORMA
      CHARACTER*24 OBJ1,OBJ2,COORD,COORN,CHTIME
      CHARACTER*24 PAVOLU,PA1D2D,PAPRES

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
      DATA CHVARC/'&&MEFICG.CH_VARC_R'/
      DATA CHVREF/'&&MEFICG.CHVREF'/

C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------

      CALL JEMARQ()
      OPTION = OPTIOZ

C- RECUPERATION DU CHAMP GEOMETRIQUE

      CALL MEGEOM(MODELE,' ',EXIGEO,CHGEOM)
      NOMA = CHGEOM(1:8)

C- RECUPERATION DE L'ETAT INITIAL

      CALL GETFAC('ETAT_INIT',INIT)
      IF (INIT.NE.0) THEN
        CALL U2MESS('F','CALCULEL3_46')
      END IF


C- RECUPERATION (S'ILS EXISTENT) DES CHAMP DE TEMPERATURES (T,TREF)
      CALL VRCINS(MODELE,MATE(1:8),'BIDON   ',NCHAR,LCHAR,TIME,CHVARC)
      CALL VRCREF(MODELE,MATE(1:8),'BIDON   ',CHVREF(1:19))

C - TRAITEMENT DES CHARGES

      CHVOLU = '&&MEFICG.VOLU'
      CF1D2D = '&&MEFICG.1D2D'
      CF2D3D = '&&MEFICG.2D3D'
      CHPRES = '&&MEFICG.PRES'
      CHEPSI = '&&MEFICG.EPSI'
      CHPESA = '&&MEFICG.PESA'
      CHROTA = '&&MEFICG.ROTA'
      CALL GCHARG(MODELE,NCHAR,LCHAR,CHVOLU,CF1D2D,CF2D3D,CHPRES,CHEPSI,
     &            CHPESA,CHROTA,FONC,EPSI,TIME,IORD)
      IF (FONC) THEN
        PAVOLU = 'PFFVOLU'
        PA1D2D = 'PFF1D2D'
        PAPRES = 'PPRESSF'
        IF (OPTION.EQ.'CALC_DK_DG_E') THEN
          OPTION = 'CALC_DK_DG_E_F'
        ELSE IF (OPTION.EQ.'CALC_DK_DG_FORC') THEN
          OPTION = 'CALC_DK_DG_FORCF'
        ELSE
          OPTION = 'CALC_K_G_F'
        END IF
        OPTIO2 = 'CALC_K_G_F'
      ELSE
        PAVOLU = 'PFRVOLU'
        PA1D2D = 'PFR1D2D'
        PAPRES = 'PPRESSR'
        OPTIO2 = 'CALC_K_G'
      END IF
C
C - RECUPERATION DES CHARGES DERIVEES DANS LE CAS DK/DF
C
      IF (OPTION(1:15).EQ.'CALC_DK_DG_FORC') THEN
        DO 70 ICHA = 1,NCHAR
          NOMCH0 = LCHAR(ICHA)(1:8)
          CALL PSRENC(NOMCH0,NOPASE,NOMCHS,EXICHA)
          IF(EXICHA.EQ.0) THEN
            LCHARS(ICHA)(1:8) = NOMCHS
            CALL FOINTE('FM',NOPASE,0,'X',0.D0,VALPAS,IER)
          ELSE IF(EXICHA.EQ.1) THEN
            LCHARS(ICHA)(1:8) = ' '
          ELSE
            CALL U2MESS('F','SENSIBILITE_16')
          ENDIF
70      CONTINUE
C - TRAITEMENT DES CHARGES DERIVEES
        CHVOSS = '&&MEFICG.VOSS'
        CF12SS = '&&MEFICG.12SS'
        CF23SS = '&&MEFICG.23SS'
        CHPRSS = '&&MEFICG.PRSS'
        CHEPSS = '&&MEFICG.EPSS'
        CHPESS = '&&MEFICG.PESS'
        CHROSS = '&&MEFICG.ROSS'
        CALL GCHARG(MODELE,NCHAR,LCHARS,CHVOSS,CF12SS,CF23SS,CHPRSS,
     &              CHEPSS,CHPESS,CHROSS,FONC,EPSI,TIME,IORD)
      ENDIF
C
C OBJET DECRIVANT LE MAILLAGE

      OBJ1 = MODELE//'.MODELE    .NOMA'
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
        CALL U2MESS('F','CALCULEL3_47')
      END IF
      CALL JEVEUO(OBJ2,'L',IADRNO)
      CALL JENONU(JEXNOM(NOMNO,ZK8(IADRNO)),NUNOFF)

C OBJET CONTENANT LA NORMALE AU FOND DE FISSURE

      NORMA = FOND//'.NORMALE'
      CALL JEVEUO(NORMA,'L',INORMA)
      IF (INORMA.EQ.0) THEN
        CALL U2MESS('F','CALCULEL3_48')
      END IF

C CREATION OBJET CONTENANT COORDONNEES DU NOEUD DE FOND
C DE FISSURE ET LA NORMALE A LA FISSURE

      CALL WKVECT('&&MEFICG.FOND','V V R8',4,IADRFF)

      LICMP(1) = 'XA'
      LICMP(2) = 'YA'
      LICMP(3) = 'XNORM'
      LICMP(4) = 'YNORM'
      RCMP(1) = ZR(IADRCO+NDIM* (NUNOFF-1))
      RCMP(2) = ZR(IADRCO+NDIM* (NUNOFF-1)+1)
      RCMP(3) = ZR(INORMA)
      RCMP(4) = ZR(INORMA+1)
      ZR(IADRFF) = RCMP(1)
      ZR(IADRFF+1) = RCMP(2)
      ZR(IADRFF+2) = RCMP(3)
      ZR(IADRFF+3) = RCMP(4)

      CHFOND = '&&MEFICG.FOND'
      CALL MECACT('V',CHFOND,'MAILLA',NOMA,'FISS_R',4,LICMP,IBID,RCMP,
     &            CBID,' ')

      NDIMTE = 5
      CALL WKVECT('&&MEFICG.VALG','V V R8',NDIMTE,IFIC)
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
      LPAIN(7) = PAVOLU(1:8)
      LCHIN(7) = CHVOLU
      LPAIN(8) = PA1D2D(1:8)
      LCHIN(8) = CF1D2D
      LPAIN(9) = PAPRES(1:8)
      LCHIN(9) = CHPRES
      LPAIN(10) = 'PPESANR'
      LCHIN(10) = CHPESA
      LPAIN(11) = 'PROTATR'
      LCHIN(11) = CHROTA
      LPAIN(12) = 'PFISSR'
      LCHIN(12) = CHFOND

      LIGRMO = MODELE//'.MODELE'
      NCHIN = 12
      CHTIME = '&&MEFICG.CH_INST_R'
      IF (OPTION.EQ.'CALC_K_G_F' .OR.(OPTION.EQ.'CALC_DK_DG_E_F')
     &.OR. (OPTION.EQ.'CALC_DK_DG_FORCF')) THEN
        CALL MECACT('V',CHTIME,'MODELE',LIGRMO,'INST_R  ',1,'INST   ',
     &              IBID,TIME,CBID,K8BID)
        LPAIN(NCHIN+1) = 'PTEMPSR'
        LCHIN(NCHIN+1) = CHTIME
        NCHIN = NCHIN + 1
      END IF
      CALL CALCUL('S',OPTIO2,LIGRMO,NCHIN,LCHIN,LPAIN,1,LCHOUT,LPAOUT,
     &            'V')

C  SOMMATION DES FIC ET G ELEMENTAIRES

      CALL MESOMM(LCHOUT(1),5,IBID,FIC,CBID,0,IBID)

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
        CALL IMPFIC(ZR(IFIC),LCHOUT(1),ZK8(IADRNO),RCMP,IFM)
      END IF

      IF (NBPRUP.EQ.4) THEN
        VAL(1) = ZR(IFIC)
        VAL(2) = ZR(IFIC+3)
        VAL(3) = ZR(IFIC+4)
        VAL(4) = ZR(IFIC+1)*ZR(IFIC+1) + ZR(IFIC+2)*ZR(IFIC+2)
      ELSE
        VAL(1) = TIME
        VAL(2) = ZR(IFIC)
        VAL(3) = ZR(IFIC+3)
        VAL(4) = ZR(IFIC+4)
        VAL(5) = ZR(IFIC+1)*ZR(IFIC+1) + ZR(IFIC+2)*ZR(IFIC+2)
      END IF
      IF (OPTION(1:15).EQ.'CALC_DK_DG_FORC') THEN
C DERIVEES DE K1,K2 PAR RAPPORT AU CHARGEMENT
        IF (NBPRUP.EQ.2) THEN
          VAL(1) = ZR(IFIC+3)/VALPAS
          VAL(2) = ZR(IFIC+4)/VALPAS
        ELSE
          VAL(1) = TIME
          VAL(2) = ZR(IFIC+3)/VALPAS
          VAL(3) = ZR(IFIC+4)/VALPAS
        END IF
      END IF
      CALL TBAJLI(RESULT,NBPRUP,NOPRUP,IORD,VAL,CBID,K8BID,0)

      CALL DETRSD('CHAMP_GD',CHTIME)
      CALL DETRSD('CHAMP_GD',CHVOLU)
      CALL DETRSD('CHAMP_GD',CF1D2D)
      CALL DETRSD('CHAMP_GD',CF2D3D)
      CALL DETRSD('CHAMP_GD',CHPRES)
      CALL DETRSD('CHAMP_GD',CHEPSI)
      CALL DETRSD('CHAMP_GD',CHPESA)
      CALL DETRSD('CHAMP_GD',CHROTA)
      CALL JEDETR('&&MEFICG.VALG')
      CALL JEDETR('&&MEFICG.FOND')

      CALL JEDEMA()
      END
