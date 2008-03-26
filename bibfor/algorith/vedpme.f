      SUBROUTINE VEDPME(MODELE,CHARGE,INFCHA,INSTAP,TYPRES,LVEDIZ)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 25/03/2008   AUTEUR REZETTE C.REZETTE 
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
      IMPLICIT REAL*8 (A-H,O-Z)
      CHARACTER*(*) TYPRES,LVEDIZ
      CHARACTER*19 LVEDIP
      CHARACTER*24 MODELE,CHARGE,INFCHA
      REAL*8 INSTAP
C ----------------------------------------------------------------------
C     CALCUL DES VECTEURS ELEMENTAIRES DES ELEMENTS DE LAGRANGE
C     POUR LES CHARGEMENTS DE DIRICHLET PILOTABLES.

C IN  MODELE  : NOM DU MODELE
C IN  CHARGE  : LISTE DES CHARGES
C IN  INFCHA  : INFORMATIONS SUR LES CHARGEMENTS
C IN  INSTAP  : INSTANT DU CALCUL
C VAR LVEDIP  : VECT_ELEM

C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------

      CHARACTER*32 JEXNUM,JEXNOM,JEXATR
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
      CHARACTER*8 NOMCHA,LPAIN(3),LPAOUT(1),K8BID,NEWNOM
      CHARACTER*16 OPTION
      CHARACTER*24 LIGRCH,LCHIN(3),LCHOUT(1),CHGEOM,CHTIME
      INTEGER IBID,IRET,NCHAR,JINF,JCHAR,ICHA
      INTEGER NUMDI,NBCHDI
      LOGICAL EXIGEO,BIDON
      COMPLEX*16 CBID

      CALL JEMARQ()
      NEWNOM = '.0000000'
      LVEDIP = LVEDIZ
      IF (LVEDIP.EQ.' ') LVEDIP = '&&VEMUPI           '
      BIDON = .TRUE.

      CALL JEEXIN(CHARGE,IRET)
      IF (IRET.NE.0) THEN
        CALL JELIRA(CHARGE,'LONMAX',NCHAR,K8BID)
        IF (NCHAR.NE.0) THEN
          BIDON = .FALSE.
          CALL JEVEUO(CHARGE,'L',JCHAR)
          CALL JEVEUO(INFCHA,'L',JINF)
        END IF
      END IF

      CALL DETRSD('VECT_ELEM',LVEDIP)
      CALL MEMARE('V',LVEDIP,MODELE(1:8),' ',' ','CHAR_MECA')
      CALL JEDETR(LVEDIP//'.RELR')
      CALL REAJRE(LVEDIP,' ','V')
      IF (BIDON)GO TO 20

      CALL MEGEOM(MODELE(1:8),ZK24(JCHAR) (1:8),EXIGEO,CHGEOM)

      IF (TYPRES.EQ.'R') THEN
        LPAOUT(1) = 'PVECTUR'
      ELSE
        LPAOUT(1) = 'PVECTUC'
      END IF
      LPAIN(2) = 'PGEOMER'
      LCHIN(2) = CHGEOM
      LPAIN(3) = 'PTEMPSR'

      CHTIME = '&&VEDPME.CH_INST_R'
      CALL MECACT('V',CHTIME,'MODELE',MODELE(1:8)//'.MODELE','INST_R  ',
     &            1,'INST',IBID,INSTAP,CBID,K8BID)
      LCHIN(3) = CHTIME

      DO 10 ICHA = 1,NCHAR
        NOMCHA = ZK24(JCHAR+ICHA-1) (1:8)
        LIGRCH = NOMCHA//'.CHME.LIGRE'
        LCHIN(1) = NOMCHA//'.CHME.CIMPO.DESC'
        NUMDI = ZI(JINF+ICHA)
        IF (NUMDI.EQ.5) THEN
          IF (TYPRES.EQ.'R') THEN
            OPTION = 'MECA_DDLI_R'
            LPAIN(1) = 'PDDLIMR'
          ELSE
            OPTION = 'MECA_DDLI_C'
            LPAIN(1) = 'PDDLIMC'
          END IF
          LCHOUT(1) = '&&VEDPME.???????'
          CALL GCNCO2(NEWNOM)
          LCHOUT(1) (10:16) = NEWNOM(2:8)
          CALL CORICH('E',LCHOUT(1),ICHA,IBID)
          CALL CALCUL('S',OPTION,LIGRCH,3,LCHIN,LPAIN,1,LCHOUT,LPAOUT,
     &                'V')
          CALL REAJRE(LVEDIP,LCHOUT,'V')
        END IF
   10 CONTINUE

   20 CONTINUE

      LVEDIZ = LVEDIP//'.RELR'
      CALL JEDEMA()
      END
