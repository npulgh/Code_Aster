      SUBROUTINE CAGENE ( CHAR, OPER, LIGRMZ, NOMA, NDIM )
      IMPLICIT REAL*8 (A-H,O-Z)
      CHARACTER*(*)       LIGRMZ
      CHARACTER*8         CHAR, NOMA
      CHARACTER*16        OPER
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 19/06/2007   AUTEUR PELLET J.PELLET 
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
C
C     BUT: RECUPERE LES NOMS DE MODELE, MAILLAGE ET LA DIMENSION DU PB
C
C ARGUMENTS D'ENTREE:
C      CHAR   : NOM UTILISATEUR DE LA CHARGE
C      OPER   : NOM DE LA COMMANDE (AFFE_CHAR_XXXX)
C ARGUMENTS DE SORTIE:
C      LIGRMZ : NOM DU LIGREL DU MODELE
C      NOMA   : NOM DU MAILLAGE
C      NDIM   : DIMENSION DU MAILLAGE ( 2 SI COOR_2D, 3 SI COOR_3D)
C
C ----------------------------------------------------------------------
C --------------- COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER           ZI
      COMMON / IVARJE / ZI(1)
      REAL*8            ZR
      COMMON / RVARJE / ZR(1)
      COMPLEX*16        ZC
      COMMON / CVARJE / ZC(1)
      LOGICAL           ZL
      COMMON / LVARJE / ZL(1)
      CHARACTER*8       ZK8
      CHARACTER*16              ZK16
      CHARACTER*24                       ZK24
      CHARACTER*32                                ZK32
      CHARACTER*80                                         ZK80
      COMMON / KVARJE / ZK8(1), ZK16(1), ZK24(1), ZK32(1), ZK80(1)
      CHARACTER*32      JEXNOM, JEXNUM
C     ----------- COMMUNS NORMALISES  JEVEUX  --------------------------
      CHARACTER*4   CDIM
      CHARACTER*8   K8BID, MOD
      CHARACTER*24  NOMO
      CHARACTER*19  LIGRMO
C     ------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL GETVID (' ', 'MODELE', 0, 1, 1, MOD, N)
C
C     RECUPERATION DU LIGREL DE MODELE ET DU NOM DU MAILLAGE
C
      LIGRMO = MOD//'.MODELE'
C
      CALL JEVEUO (LIGRMO//'.NOMA','L',JNOMA)
      NOMA = ZK8(JNOMA)
C
C     RECUPERATION DE LA DIMENSION REELLE DU PROBLEME
C
CC      CALL JELIRA (NOMA//'.COORDO    .VALE','DOCU',IBID,CDIM)
CC      READ(CDIM(1:1),'(I1)') NDIM
      CALL DISMOI('F','DIM_GEOM',MOD,'MODELE',NDIM,K8BID,IER)
C
C     CREATION DE .NOMO
C
      NOMO = CHAR//'.CH'//OPER(11:12)//'.MODEL.NOMO'
      CALL WKVECT ( NOMO, 'G V K8',1, JNOMO )
      ZK8(JNOMO) = MOD
      LIGRMZ=LIGRMO
C
      CALL JEDEMA()
      END
