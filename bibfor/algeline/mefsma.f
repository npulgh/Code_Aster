      SUBROUTINE MEFSMA ( MATM, MATA, MATR, NUGENE,
     +                                         MASGEN, AMOGEN, RIGGEN )
      IMPLICIT   NONE
      REAL*8              MATM(*), MATA(*), MATR(*)
      CHARACTER*19          MASGEN, AMOGEN, RIGGEN
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGELINE  DATE 18/04/2005   AUTEUR VABHHTS J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2003  EDF R&D                  WWW.CODE-ASTER.ORG
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
C-----------------------------------------------------------------------
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER          ZI
      COMMON  /IVARJE/ ZI(1)
      REAL*8           ZR
      COMMON  /RVARJE/ ZR(1)
      COMPLEX*16       ZC
      COMMON  /CVARJE/ ZC(1)
      LOGICAL          ZL
      COMMON  /LVARJE/ ZL(1)
      CHARACTER*8      ZK8
      CHARACTER*16            ZK16
      CHARACTER*24                    ZK24
      CHARACTER*32                            ZK32
      CHARACTER*80                                    ZK80
      COMMON  /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      CHARACTER*32     JEXNUM
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C
      INTEGER       LDESC, LDREF, NBMODE, NTERM, NBLOC
      CHARACTER*1   BASE
      CHARACTER*14 NUGENE
      CHARACTER*19  NOMNUM, NOMSTO
C DEB------------------------------------------------------------------
C
      CALL JEMARQ()
C
      NOMNUM = NUGENE//'.NUME'
      NOMSTO = NUGENE//'.SLCS'
C
      CALL JEVEUO ( NOMSTO//'.DESC', 'L', LDESC )
      NBMODE = ZI(LDESC  )
      NTERM  = ZI(LDESC+1)
      NBLOC  = ZI(LDESC+2)
C
      CALL JEVEUO ( NOMNUM//'.REFN', 'L', LDREF )
      BASE = ZK24(LDREF)
C
      CALL MEFSM1 ( MATM, MASGEN, BASE, NOMNUM, NOMSTO, NBMODE, NBLOC,
     +                                                          NTERM )
C
      CALL MEFSM1 ( MATA, AMOGEN, BASE, NOMNUM, NOMSTO, NBMODE, NBLOC,
     +                                                          NTERM )
C
      CALL MEFSM1 ( MATR, RIGGEN, BASE, NOMNUM, NOMSTO, NBMODE, NBLOC,
     +                                                          NTERM )
C
      CALL JEDEMA()
C
      END
