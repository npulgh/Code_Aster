      SUBROUTINE RVREPM(MAILLA,COURBE,REPERE,SDNEWR)
      IMPLICIT REAL*8 (A-H,O-Z)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF POSTRELE  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
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
C
      INCLUDE 'jeveux.h'
      CHARACTER*19 SDNEWR
      CHARACTER*8  COURBE, MAILLA, REPERE
C
C***********************************************************************
C
C  OPERATION REALISEE
C  ------------------
C
C     CALCUL  DU REPERE LOCAL OU POLAIRE LA LONG D' UNE COURBE CHEMIN
C
C  ARGUMENTS EN ENTREE
C  -------------------
C
C     COURBE : NOM DU CONCEPT COURBE
C     MAILLA : NOM DU CONCEPT MAILLAGE
C     REPERE : VAUT 'LOCAL' OU 'POLAIRE'
C
C  ARGUMENTS EN SORTIE
C  -------------------
C
C     SDNEWR : NOM DE LA SD DU REPERE CALCULE
C              (DOC. C.F. RVCPCN)
C
C***********************************************************************
C
C  -----------------------------------------
C
C
C
C  ---------------------------------
C
C  VARIABLES LOCALES
C  -----------------
C
      CHARACTER*15 NCHMIN
      CHARACTER*24 NVEC1,NVEC2,NTABND,NKARND
      INTEGER      AVEC1,AVEC2,ATABND
      INTEGER      NBCHM,ICHM,NBM,ACHM,ACOORD,NBPT
      CHARACTER*1 K1BID
C
C====================== CORPS DE LA ROUTINE ===========================
C
      CALL JEMARQ()
C
      NVEC1  = SDNEWR//'.VEC1'
      NVEC2  = SDNEWR//'.VEC2'
      NCHMIN = COURBE//'.CHEMIN'
      NTABND = '&&RVREPM.LISTE.NOEUD'
      NKARND = '&&RVREPM.LISTE.NOMND'
C
      CALL JELIRA(NCHMIN,'NMAXOC',NBCHM,K1BID)
      CALL JEVEUO(MAILLA//'.COORDO    .VALE','L',ACOORD)
C
      CALL JECREC(NVEC1,'V V R','NU','DISPERSE','VARIABLE',NBCHM)
      CALL JECREC(NVEC2,'V V R','NU','DISPERSE','VARIABLE',NBCHM)
C
      DO 100, ICHM = 1, NBCHM, 1
C
         CALL JELIRA(JEXNUM(NCHMIN,ICHM),'LONMAX',NBM,K1BID)
         CALL JEVEUO(JEXNUM(NCHMIN,ICHM),'L',ACHM)
C
         NBM = NBM - 1
C
         CALL RVNCHM(MAILLA,ZI(ACHM),NBM,NTABND,NKARND)
         CALL JEVEUO(NTABND,'L',ATABND)
         CALL JELIRA(NTABND,'LONMAX',NBPT,K1BID)
         CALL JECROC(JEXNUM(NVEC1,ICHM))
         CALL JEECRA(JEXNUM(NVEC1,ICHM),'LONMAX',2*NBPT,' ')
         CALL JEVEUO(JEXNUM(NVEC1,ICHM),'E',AVEC1)
         CALL JECROC(JEXNUM(NVEC2,ICHM))
         CALL JEECRA(JEXNUM(NVEC2,ICHM),'LONMAX',2*NBPT,' ')
         CALL JEVEUO(JEXNUM(NVEC2,ICHM),'E',AVEC2)
C
         CALL RVRLLN(ZR(ACOORD),ZI(ATABND),NBPT,REPERE,
     +               ZR(AVEC1),ZR(AVEC2))
C
         CALL JEDETR(NTABND)
         CALL JEDETR(NKARND)
C
100   CONTINUE
C
      CALL JEDEMA()
      END
