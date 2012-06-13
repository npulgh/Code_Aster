      SUBROUTINE MDCHAN ( MOTFAC, IOC, ILIAI, MDGENE, TYPNUM, REPERE,
     &                    XJEU, NBNLI, NOECHO, PARCHO )
      IMPLICIT  NONE
      INCLUDE 'jeveux.h'
      INTEGER             IOC, ILIAI, NBNLI
      REAL*8              XJEU, PARCHO(NBNLI,*)
      CHARACTER*8         REPERE, NOECHO(NBNLI,*)
      CHARACTER*10        MOTFAC
      CHARACTER*16        TYPNUM
      CHARACTER*24        MDGENE
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
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
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C
C     ROUTINE APPELEE PAR MDCHOC
C     RECHERCHE DES ANGLES NAUTIQUES
C
C IN  : MOTFAC : 'CHOC', 'FLAMBAGE', 'ANTI_SISM'
C IN  : IOC    : NUMERO D'OCCURENCE
C IN  : ILIAI  : NUMERO DE LA LIAISON TRAITEE
C IN  : MDGENE : MODELE GENERALISE
C IN  : TYPNUM : TYPE DE LA NUMEROTATION
C IN  : REPERE : REPERE DU NOEUD DE CHOC = 'GLOBAL' OU 'LOCAL'
C IN  : XJEU   : JEU INITIAL
C IN  : NBNLI  : DIMENSION DES TABLEAUX (NBCHOC+NBSISM+NBFLAM)
C IN  : NOECHO : (ILIAI,9) = TYPE D'OBSTACLE
C OUT : PARCHO : PARAMETRE DE CHOC:
C                PARCHO(ILIAI,17)= SIN A
C                PARCHO(ILIAI,18)= COS A
C                PARCHO(ILIAI,19)= SIN B
C                PARCHO(ILIAI,20)= COS B
C                PARCHO(ILIAI,21)= SIN G
C                PARCHO(ILIAI,22)= COS G
C     ------------------------------------------------------------------
      INTEGER      N1, JNORM
      REAL*8       TXLOC(3), TZLOC(3), TYLOC(3), ANG(3), ALPHA, BETA
      REAL*8       NORMX(3), NORMY(3),  ANGL, RNORM, RAD, R8DGRD
      INTEGER      IARG
C     ------------------------------------------------------------------
C
      RAD = R8DGRD()
C
      IF ( MOTFAC.EQ.'CHOC' .OR. MOTFAC.EQ.'FLAMBAGE' ) THEN
C          ------------------------------------------
      CALL GETVR8 ( MOTFAC, 'NORM_OBST', IOC,IARG,3, TXLOC, N1 )
      CALL GETVR8 ( MOTFAC, 'ANGL_VRIL', IOC,IARG,1, ANGL , N1 )
C
      IF (N1.NE.0) THEN
         IF (TYPNUM.EQ.'NUME_DDL_SDASTER' .OR. REPERE.EQ.'GLOBAL') THEN
            CALL ANGVX ( TXLOC, ALPHA, BETA )
            PARCHO(ILIAI,17) = SIN(ALPHA)
            PARCHO(ILIAI,18) = COS(ALPHA)
            PARCHO(ILIAI,19) = SIN(BETA)
            PARCHO(ILIAI,20) = COS(BETA)
         ELSE
            CALL WKVECT('&&MDCHAN.NORM','V V R',3,JNORM)
            ZR(JNORM)   = TXLOC(1)
            ZR(JNORM+1) = TXLOC(2)
            ZR(JNORM+2) = TXLOC(3)
            CALL ORIENT ( MDGENE, REPERE, JNORM, 1, NORMX, 0 )
            CALL ANGVX ( NORMX, ALPHA, BETA )
            PARCHO(ILIAI,17) = SIN(ALPHA)
            PARCHO(ILIAI,18) = COS(ALPHA)
            PARCHO(ILIAI,19) = SIN(BETA)
            PARCHO(ILIAI,20) = COS(BETA)
            CALL JEDETR('&&MDCHAN.NORM')
         ENDIF
         PARCHO(ILIAI,21) = SIN(ANGL*RAD)
         PARCHO(ILIAI,22) = COS(ANGL*RAD)
C
      ELSEIF (NOECHO(ILIAI,9).EQ.'BI_PLANY') THEN
         TYLOC(1) = (PARCHO(ILIAI,11) - PARCHO(ILIAI,8))
         TYLOC(2) = (PARCHO(ILIAI,12) - PARCHO(ILIAI,9))
         TYLOC(3) = (PARCHO(ILIAI,13) - PARCHO(ILIAI,10))
         IF (TYPNUM.EQ.'NUME_DDL_SDASTER' .OR. REPERE.EQ.'GLOBAL') THEN
            CALL ANGVXY ( TXLOC, TYLOC, ANG )
            PARCHO(ILIAI,17) = SIN(ANG(1))
            PARCHO(ILIAI,18) = COS(ANG(1))
            PARCHO(ILIAI,19) = SIN(ANG(2))
            PARCHO(ILIAI,20) = COS(ANG(2))
            PARCHO(ILIAI,21) = SIN(ANG(3))
            PARCHO(ILIAI,22) = COS(ANG(3))
         ELSE
            CALL WKVECT ( '&&MDCHAN.NORM', 'V V R', 3, JNORM )
            ZR(JNORM)   = TXLOC(1)
            ZR(JNORM+1) = TXLOC(2)
            ZR(JNORM+2) = TXLOC(3)
            CALL ORIENT ( MDGENE, REPERE, JNORM, 1, NORMX, 0 )
            ZR(JNORM)   = TYLOC(1)
            ZR(JNORM+1) = TYLOC(2)
            ZR(JNORM+2) = TYLOC(3)
            CALL ORIENT ( MDGENE, REPERE, JNORM, 1, NORMY, 0 )
            CALL ANGVXY ( NORMX, NORMY, ANG )
            PARCHO(ILIAI,17) = SIN(ANG(1))
            PARCHO(ILIAI,18) = COS(ANG(1))
            PARCHO(ILIAI,19) = SIN(ANG(2))
            PARCHO(ILIAI,20) = COS(ANG(2))
            PARCHO(ILIAI,21) = SIN(ANG(3))
            PARCHO(ILIAI,22) = COS(ANG(3))
            CALL JEDETR ('&&MDCHAN.NORM')
         ENDIF
C
      ELSEIF (NOECHO(ILIAI,9).EQ.'BI_PLANZ') THEN
         TZLOC(1) = (PARCHO(ILIAI,11) - PARCHO(ILIAI,8))
         TZLOC(2) = (PARCHO(ILIAI,12) - PARCHO(ILIAI,9))
         TZLOC(3) = (PARCHO(ILIAI,13) - PARCHO(ILIAI,10))
         CALL PROVEC ( TZLOC, TXLOC, TYLOC )
         IF (TYPNUM.EQ.'NUME_DDL_SDASTER' .OR. REPERE.EQ.'GLOBAL') THEN
            CALL ANGVXY ( TXLOC, TYLOC, ANG )
            PARCHO(ILIAI,17) = SIN(ANG(1))
            PARCHO(ILIAI,18) = COS(ANG(1))
            PARCHO(ILIAI,19) = SIN(ANG(2))
            PARCHO(ILIAI,20) = COS(ANG(2))
            PARCHO(ILIAI,21) = SIN(ANG(3))
            PARCHO(ILIAI,22) = COS(ANG(3))
         ELSE
            CALL WKVECT ( '&&MDCHAN.NORM', 'V V R', 3, JNORM )
            ZR(JNORM)   = TXLOC(1)
            ZR(JNORM+1) = TXLOC(2)
            ZR(JNORM+2) = TXLOC(3)
            CALL ORIENT ( MDGENE, REPERE, JNORM, 1, NORMX, 0 )
            ZR(JNORM)   = TZLOC(1)
            ZR(JNORM+1) = TZLOC(2)
            ZR(JNORM+2) = TZLOC(3)
            CALL ORIENT ( MDGENE, REPERE, JNORM, 1, NORMY, 0 )
            CALL ANGVXY ( NORMX, NORMY, ANG )
            PARCHO(ILIAI,17) = SIN(ANG(1))
            PARCHO(ILIAI,18) = COS(ANG(1))
            PARCHO(ILIAI,19) = SIN(ANG(2))
            PARCHO(ILIAI,20) = COS(ANG(2))
            PARCHO(ILIAI,21) = SIN(ANG(3))
            PARCHO(ILIAI,22) = COS(ANG(3))
            CALL JEDETR ( '&&MDCHAN.NORM' )
         ENDIF
C
      ELSE
         CALL U2MESS('I','ALGORITH5_25')
         ANGL = 0.D0
         IF (TYPNUM.EQ.'NUME_DDL_SDASTER' .OR. REPERE.EQ.'GLOBAL') THEN
            CALL ANGVX ( TXLOC, ALPHA, BETA )
            PARCHO(ILIAI,17) = SIN(ALPHA)
            PARCHO(ILIAI,18) = COS(ALPHA)
            PARCHO(ILIAI,19) = SIN(BETA)
            PARCHO(ILIAI,20) = COS(BETA)
         ELSE
            CALL WKVECT('&&MDCHAN.NORM','V V R',3,JNORM)
            ZR(JNORM)   = TXLOC(1)
            ZR(JNORM+1) = TXLOC(2)
            ZR(JNORM+2) = TXLOC(3)
            CALL ORIENT(MDGENE,REPERE,JNORM,1,NORMX,0)
            CALL ANGVX(NORMX,ALPHA,BETA)
            PARCHO(ILIAI,17) = SIN(ALPHA)
            PARCHO(ILIAI,18) = COS(ALPHA)
            PARCHO(ILIAI,19) = SIN(BETA)
            PARCHO(ILIAI,20) = COS(BETA)
            CALL JEDETR('&&MDCHAN.NORM')
         ENDIF
         PARCHO(ILIAI,21) = SIN(ANGL*RAD)
         PARCHO(ILIAI,22) = COS(ANGL*RAD)
      ENDIF
C
      ELSEIF ( MOTFAC.EQ.'ANTI_SISM' ) THEN
C              ---------------------
C
      PARCHO(ILIAI,30)= SQRT(XJEU)/2.D0
      PARCHO(ILIAI,31)= SQRT(XJEU)/2.D0
C
C --- VECTEUR NOEUD1 VERS NOEUD2
      TYLOC(1) = (PARCHO(ILIAI,11) - PARCHO(ILIAI,8))
      TYLOC(2) = (PARCHO(ILIAI,12) - PARCHO(ILIAI,9))
      TYLOC(3) = (PARCHO(ILIAI,13) - PARCHO(ILIAI,10))
      CALL NORMEV ( TYLOC, RNORM )
      IF (RNORM .EQ. 0.0D0) THEN
         CALL U2MESS('F','ALGORITH5_26')
      ENDIF
C
C --- DETERMINATION DES AXES LOCAUX
      IF ( ABS(TYLOC(3)).LE.ABS(TYLOC(1)) .AND.
     &     ABS(TYLOC(3)).LE.ABS(TYLOC(2)) ) THEN
         TZLOC(1) = -TYLOC(2)
         TZLOC(2) =  TYLOC(1)
         TZLOC(3) =  0.D0
      ELSEIF ( ABS(TYLOC(2)).LE.ABS(TYLOC(1)) .AND.
     &         ABS(TYLOC(2)).LE.ABS(TYLOC(3)) ) THEN
         TZLOC(1) = -TYLOC(3)
         TZLOC(2) =  0.D0
         TZLOC(3) =  TYLOC(1)
      ELSE
         TZLOC(1) =  0.D0
         TZLOC(2) = -TYLOC(3)
         TZLOC(3) =  TYLOC(2)
      ENDIF
      CALL PROVEC ( TYLOC, TZLOC, TXLOC )
      IF (TYPNUM.EQ.'NUME_DDL_SDASTER' .OR. REPERE.EQ.'GLOBAL') THEN
         CALL ANGVXY ( TXLOC, TYLOC, ANG )
         PARCHO(ILIAI,17) = SIN(ANG(1))
         PARCHO(ILIAI,18) = COS(ANG(1))
         PARCHO(ILIAI,19) = SIN(ANG(2))
         PARCHO(ILIAI,20) = COS(ANG(2))
         PARCHO(ILIAI,21) = SIN(ANG(3))
         PARCHO(ILIAI,22) = COS(ANG(3))
      ELSE
         CALL WKVECT ( '&&MDCHAN.NORM', 'V V R', 3, JNORM )
         ZR(JNORM)   = TXLOC(1)
         ZR(JNORM+1) = TXLOC(2)
         ZR(JNORM+2) = TXLOC(3)
         CALL ORIENT ( MDGENE, REPERE, JNORM, 1, NORMX, 0 )
         ZR(JNORM)   = TYLOC(1)
         ZR(JNORM+1) = TYLOC(2)
         ZR(JNORM+2) = TYLOC(3)
         CALL ORIENT ( MDGENE, REPERE, JNORM, 1, NORMY, 0 )
         CALL ANGVXY ( NORMX, NORMY, ANG )
         PARCHO(ILIAI,17) = SIN(ANG(1))
         PARCHO(ILIAI,18) = COS(ANG(1))
         PARCHO(ILIAI,19) = SIN(ANG(2))
         PARCHO(ILIAI,20) = COS(ANG(2))
         PARCHO(ILIAI,21) = SIN(ANG(3))
         PARCHO(ILIAI,22) = COS(ANG(3))
         CALL JEDETR ( '&&MDCHAN.NORM' )
      ENDIF
C
      ENDIF
C
      END
