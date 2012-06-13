      SUBROUTINE PCLDLT(MATF,MAT,NIREMP,BAS)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGELINE  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C TOLE CRP_4
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      CHARACTER*(*) MATF,MAT,BAS
C-----------------------------------------------------------------------
C  FONCTION  :
C     CREATION D'UNE MATRICE DE PRECONDITIONNEMENT MATF
C     PAR FACTORISATION LDLT PLUS OU MOINS COMPLETE DE LA MATRICE MAT
C     STOCKEE SOUS FORME MORSE.
C     ON PEUT CHOISIR LE DEGRE DE REMPLISSAGE : NIREMP

C-----------------------------------------------------------------------
C OUT K*  MATF   : NOM DE LA MATR_ASSE DE PRECONDITIONNEMENT
C                  REMARQUE : CE N'EST PAS VRAIMENT UNE MATR_ASSE :
C                             ELLE A UN STOCKAGE MORSE "ETENDU"
C                             ET ELLE CONTIENT UNE FACTORISEE LDLT !
C IN  K*  MAT    : NOM DE LA MATR_ASSE A PRECONDITIONNER
C IN  I   NIREMP : NIVEAU DE REMPLISSAGE VOULU POUR MATF
C IN  K*  BAS    : NOM DE LA BASE SUR LAQUELLE ON CREE MATF 'G' OU 'V'
C-----------------------------------------------------------------------
C     FONCTIONS JEVEUX
C-----------------------------------------------------------------------
C-----------------------------------------------------------------------
C-----------------------------------------------------------------------
C----------------------------------------------------------------------
C     VARIABLES LOCALES
C----------------------------------------------------------------------
      LOGICAL COMPLT
      CHARACTER*1 BASE
      INTEGER IRET,JSMDI,JSMHC,JSMDE,NEQU,NCOEF,NBLC,IBID
      INTEGER JVALM,IDV,I,NZMAX,JICPD,JICPLX,NIREMP
      INTEGER JICPCX,JSMDI1,JSMHC1,IER,K,JSMDIF,JSMHCF,JVALF,JVECT
      INTEGER JREFA,JREFAF
      REAL*8 DNORM,EPSI
      CHARACTER*19 MATFAC,MATAS
      CHARACTER*1 TYSCA
      CHARACTER*14 NU,NUF
      CHARACTER*24 NOOBJ
      CHARACTER*8 MA
C----------------------------------------------------------------------
C     DEBUT DES INSTRUCTIONS
      CALL JEMARQ()

      MATAS = MAT
      MATFAC = MATF
      BASE = BAS


C     -- DDLS ELIMINES :
      CALL JEVEUO(MATAS//'.REFA','L',JREFA)
      CALL ASSERT(ZK24(JREFA-1+3).NE.'ELIMF')
      IF (ZK24(JREFA-1+3).EQ.'ELIML') CALL MTMCHC(MATAS,'ELIMF')
      CALL ASSERT(ZK24(JREFA-1+3).NE.'ELIML')



C     1. CALCUL DE : MA,NU,JSMDI,JSMHC,JSMDE
C         NEQU,NCOEF
C         + QQUES VERIFS
C     ------------------------------------------
      CALL JEVEUO(MATAS//'.REFA','L',JREFA)
      MA = ZK24(JREFA-1+1)(1:8)
      NU = ZK24(JREFA-1+2)(1:14)

      CALL JEEXIN(NU//'.SMOS.SMDI',IRET)
      IF (IRET.EQ.0) CALL U2MESK('F','ALGELINE3_21',1,MATAS)

      CALL JEVEUO(NU//'.SMOS.SMDI','L',JSMDI)
      CALL JEVEUO(NU//'.SMOS.SMHC','L',JSMHC)
      CALL JEVEUO(NU//'.SMOS.SMDE','L',JSMDE)
      NEQU = ZI(JSMDE-1+1)
      NCOEF = ZI(JSMDE-1+2)

      NBLC = ZI(JSMDE-1+3)
      IF (NBLC.NE.1) CALL U2MESS('F','ALGELINE3_22')

      CALL JELIRA(JEXNUM(MATAS//'.VALM',1),'TYPE',IBID,TYSCA)
      IF (TYSCA.EQ.'C') CALL U2MESS('F','ALGELINE3_23')



C     1. CREATION DU NUME_DDL ASSOCIE A MATFAC :
C     ------------------------------------------

C     DETERMINATION DU NOM DE LA SD CACHEE NUME_DDL
      NOOBJ ='12345678.NU000.NUME.PRNO'
      CALL GNOMSD(NOOBJ,12,14)
      NUF=NOOBJ(1:14)
      CALL COPISD('NUME_DDL',BASE,NU,NUF)


C     2. CREATION DE MATFAC.REFA
C     ---------------------------
      CALL JEDETR(MATFAC//'.REFA')
      CALL WKVECT(MATFAC//'.REFA',BASE//' V K24 ',11,JREFAF)
      ZK24(JREFAF-1+11)='MPI_COMPLET'
      ZK24(JREFAF-1+1) = MA
      ZK24(JREFAF-1+2) = NUF
      ZK24(JREFAF-1+9) = 'MS'
      ZK24(JREFAF-1+10) = 'NOEU'


C     2. CALCUL DE EPSI POUR PCFACT ET ALLOCATION DE .VTRAVAIL:
C     ---------------------------------------------------------
      CALL JEVEUO(JEXNUM(MATAS//'.VALM',1),'L',JVALM)
      CALL WKVECT('&&PCLDLT.VTRAVAIL','V V R',NEQU,IDV)
      DNORM = 0.D0
      DO 10 I = 1,NEQU
        DNORM = MAX(ABS(ZR(JVALM-1+ZI(JSMDI-1+I))),DNORM)
   10 CONTINUE
      EPSI = 1.D-16*DNORM
      CALL JELIBE(JEXNUM(MATAS//'.VALM',1))


C     3. ON BOUCLE SUR PCSTRU JUSQU'A TROUVER LA TAILLE DE LA
C        FUTURE FACTORISEE :
C     ------------------------------------------------
      NZMAX = NCOEF
      CALL WKVECT('&&PCLDLT.SMDIF','V V I',NEQU+1,JSMDI1)

      DO 7778,K=1,2*NIREMP+2
        CALL WKVECT('&&PCLDLT.ICPD','V V I',NEQU,JICPD)
        CALL WKVECT('&&PCLDLT.ICPLX','V V I',NEQU+1,JICPLX)
        CALL JEDETR('&&PCLDLT.SMHCF')
        CALL WKVECT('&&PCLDLT.SMHCF','V V S',2*NZMAX,JSMHC1)
        CALL WKVECT('&&PCLDLT.ICPCX','V V I',NZMAX,JICPCX)

        CALL PCSTRU(NEQU,ZI(JSMDI),ZI4(JSMHC),ZI(JSMDI1),ZI4(JSMHC1),
     &      ZI(JICPD),ZI(JICPCX),ZI(JICPLX),NIREMP,COMPLT,NZMAX,0,
     &            IER)

        CALL JEDETR('&&PCLDLT.ICPLX')
        CALL JEDETR('&&PCLDLT.ICPCX')
        CALL JEDETR('&&PCLDLT.ICPD')
        IF (IER.EQ.0) GO TO 7779
        NZMAX=IER
7778  CONTINUE
      CALL U2MESS('F','ALGELINE3_24')
7779  CONTINUE


C     -- ON MET A JOUR NUF.SMDI ET NUF.SMHC  :
C     ------------------------------------------------
      CALL JEVEUO(NUF//'.SMOS.SMDI','E',JSMDIF)
      DO 20,K = 1,NEQU
        ZI(JSMDIF-1+K) = ZI(JSMDI1-1+K)
   20 CONTINUE
      CALL JEDETR('&&PCLDLT.SMDIF')

      CALL JEDETR(NUF//'.SMOS.SMHC')
      CALL WKVECT(NUF//'.SMOS.SMHC',BASE//' V S',NZMAX,JSMHCF)
      DO 30,K = 1,NZMAX
        ZI4(JSMHCF-1+K) = ZI4(JSMHC1-1+K)
   30 CONTINUE
      CALL JEDETR('&&PCLDLT.SMHCF')



C     -- ON ALLOUE MATFAC.VALM :
C     ------------------------------------------------
      CALL JEDETR(MATFAC//'.VALM')
      CALL JECREC(MATFAC//'.VALM',BASE//' V '//TYSCA,'NU','DISPERSE',
     &            'CONSTANT',1)
      CALL JEECRA(MATFAC//'.VALM','LONMAX',NZMAX,' ')
      CALL JECROC(JEXNUM(MATFAC//'.VALM',1))


C     -- ON INJECTE MATAS.VALM DANS MATFAC.VALM :
C     ------------------------------------------------
      CALL JEVEUO(JEXNUM(MATAS//'.VALM',1),'L',JVALM)
      CALL JEVEUO(JEXNUM(MATFAC//'.VALM',1),'E',JVALF)
      CALL PCCOEF(NEQU,ZI(JSMDI),ZI4(JSMHC),ZR(JVALM),ZI(JSMDIF),
     &            ZI4(JSMHCF),ZR(JVALF),ZR(IDV))
      CALL JELIBE(JEXNUM(MATAS//'.VALM',1))


C     -- ON FACTORISE MATFAC.VALM :
C     ------------------------------------------------
      CALL WKVECT('&&PCLDLT.VECT','V V R',NEQU,JVECT)
      CALL PCFACT(MATAS,NEQU,ZI(JSMDIF),ZI4(JSMHCF),ZR(JVALF),ZR(JVALF),
     &            ZR(JVECT),EPSI)
      CALL JEDETR('&&PCLDLT.VECT')

      CALL JEDETR('&&PCLDLT.VTRAVAIL')
      CALL JEDEMA()
      END
