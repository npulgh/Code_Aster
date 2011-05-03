      SUBROUTINE INIGRL(LIGREL,IGREL,NMAX,ADTABL,K24TAB,NVAL)
      IMPLICIT NONE

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 02/05/2011   AUTEUR DELMAS J.DELMAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2011  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE PELLET J.PELLET
C TOLE CRS_513
C
C     ARGUMENTS:
C     ----------
      CHARACTER*(*) LIGREL
      INTEGER IGREL,NMAX,ADTABL(NMAX),NVAL
      CHARACTER*24 K24TAB(NMAX)
C ----------------------------------------------------------------------
C     BUT:
C     INITIALISER LE TYPE_ELEMENT ASSOCIE AU GREL  (INI00K)

C     IN:
C      LIGREL : NOM DU LIGREL A INITIALISER
C      IGREL  : NUMERO DU GREL
C      NMAX   : DIMENSION DE K24TAB ET ADTABL

C     OUT:
C         CREATION DES OBJETS JEVEUX PROPRES AU
C             TYPE_ELEMENT PRESENTS DANS LE LIGREL(IGREL).

C         NVAL  : NOMBRE DE NOMS RENDUS DANS K24TAB
C         K24TAB: TABLEAU DES NOMS DES OBJETS '&INEL.XXXX'
C         ADTABL : TABLEAU D'ADRESSES DES '&INEL.XXXXX'
C         ADTABL(I) = 0 SI L'OBJET CORRESPONDANT N'EXISTE PAS
C         SI NVAL > NMAX  : ON  S'ARRETE EN ERREUR FATALE

C ----------------------------------------------------------------------
      COMMON /IVARJE/ZI(1)
      COMMON /RVARJE/ZR(1)
      COMMON /CVARJE/ZC(1)
      COMMON /LVARJE/ZL(1)
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      INTEGER ZI
      REAL*8 ZR
      COMPLEX*16 ZC
      LOGICAL ZL
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32,JEXNUM
      CHARACTER*80 ZK80
      CHARACTER*1 K1BID
      CHARACTER*24 NOLIEL
      CHARACTER*16 NOMTE
      INTEGER LIEL,L,TE,K



      NOLIEL = LIGREL(1:19)//'.LIEL'
      CALL JEVEUO(JEXNUM(NOLIEL,IGREL),'L',LIEL)
      CALL JELIRA(JEXNUM(NOLIEL,IGREL),'LONMAX',L,K1BID)
      TE = ZI(LIEL-1+L)
      CALL JENUNO(JEXNUM('&CATA.TE.NOMTE',TE),NOMTE)

C     -- ON MET LES ADRESSES A ZERO :
      DO 10,K = 1,NMAX
        K24TAB(K) = ' '
        ADTABL(K) = 0
   10 CONTINUE

      CALL INI002(NOMTE,NMAX,ADTABL,K24TAB,NVAL)


      END
