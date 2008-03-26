      SUBROUTINE MEMAME(OPTION,MODELE,NCHAR,LCHAR,MATE,CARA,EXITIM,TIME,
     &                  COMPOR,MATEL,BASEZ)
      IMPLICIT REAL*8 (A-H,O-Z)
      INTEGER NCHAR
      REAL*8 TIME
      CHARACTER*8 LCHAR(*)
      CHARACTER*(*) OPTION,MODELE,MATE,CARA,COMPOR,MATEL,BASEZ
      LOGICAL EXITIM
C ----------------------------------------------------------------------
C MODIF CALCULEL  DATE 25/03/2008   AUTEUR REZETTE C.REZETTE 
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
C     CALCUL DES MATRICES ELEMENTAIRES DE MASSE MECA

C ----------------------------------------------------------------------
C IN  : OPTION : OPTION DE CALCUL
C IN  : MODELE : NOM DU MODELE (OBLIGATOIRE)
C IN  : NCHAR  : NOMBRE DE CHARGES
C IN  : LCHAR  : LISTE DES CHARGES
C IN  : MATE   : CARTE DE MATERIAUX
C IN  : CARA   : CHAMP DE CARAC_ELEM
C IN  : EXITIM : VRAI SI L'INSTANT EST DONNE
C IN  : TIME   : INSTANT DE CALCUL
C IN  : COMPOR : LE COMPORTEMENT
C OUT : MATEL  : NOM DU MATR_ELEM RESULTAT
C IN  : BASEZ  : NOM DE LA BASE
C ----------------------------------------------------------------------
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
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
      CHARACTER*32 JEXNUM,JEXNOM,JEXATR
C ----------------------------------------------------------------------
      CHARACTER*1 BASE
      CHARACTER*8 K8B,LPAIN(17),LPAOUT(2)
      CHARACTER*19 CHVARC
      CHARACTER*24 LIGRMO,LCHIN(17),LCHOUT(2)
      CHARACTER*24 CHGEOM,CHCARA(15),CHHARM,MATELZ,CHTREF,CHTEMP
      DATA CHVARC /'&&MEMAME.VARC'/
      CALL JEMARQ()
      MATELZ = MATEL
      BASE = BASEZ
      IF (MODELE(1:1).EQ.' ') CALL U2MESS('F','CALCULEL2_82')

      NH = 0
      CALL MECHAM(OPTION,MODELE,NCHAR,LCHAR,CARA,NH,CHGEOM,CHCARA,
     &            CHHARM,ICODE)
      CALL VRCINS(MODELE,MATE,CARA,TIME,CHVARC)

      CALL MEMARE(BASE,MATELZ(1:19),MODELE,MATE,CARA,OPTION)
      CALL JEVEUO(MATELZ(1:19)//'.RERR','E',IAREFE)
      ZK24(IAREFE-1+3) (1:3) = 'OUI'

      CALL JEEXIN(MATELZ(1:19)//'.RELR',IRET)
      IF (IRET.GT.0) CALL JEDETR(MATELZ(1:19)//'.RELR')
      IF (ICODE.EQ.2) GO TO 10

      LPAOUT(1) = 'PMATUUR'
      LCHOUT(1) = MATEL(1:8)//'.ME001'
      LPAOUT(2) = 'PMATUNS'
      LCHOUT(2) = MATEL(1:8)//'.ME002'

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
      LPAIN(15) = 'PCOMPOR'
      LCHIN(15) = COMPOR
      LPAIN(16) = 'PNBSP_I'
      LCHIN(16) = CHCARA(1) (1:8)//'.CANBSP'
      LPAIN(17) = 'PFIBRES'
      LCHIN(17) = CHCARA(1) (1:8)//'.CAFIBR'


      IF (OPTION.EQ.'MASS_MECA') THEN
        NBOUT = 2
      ELSE IF (OPTION(1:8).EQ.'MASS_ID_') THEN
        NBOUT = 1
        LPAOUT(1) = 'PMATRIC'
      ELSE
        NBOUT = 1
      END IF

      CALL CALCUL('S',OPTION,LIGRMO,17,LCHIN,LPAIN,NBOUT,LCHOUT,LPAOUT,
     &            BASE)

      CALL REAJRE(MATELZ,LCHOUT(1),BASE)
      CALL REAJRE(MATELZ,LCHOUT(2),BASE)

   10 CONTINUE
      CALL DETRSD('CHAMP_GD',CHVARC)

      CALL JEDEMA()
      END
