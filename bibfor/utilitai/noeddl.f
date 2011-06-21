      SUBROUTINE NOEDDL(NUME,NBNOE,LNONOE,NEQ,IVEC)
      IMPLICIT REAL*8 (A-H,O-Z)
      INTEGER                NBNOE,       NEQ,IVEC(NEQ)
      CHARACTER*14      NUME
      CHARACTER*(*)                LNONOE(NBNOE)
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 21/06/2011   AUTEUR CORUS M.CORUS 
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C ----------------------------------------------------------------------
C IN : NUME   : NOM D'UN NUME_DDL
C IN : NBNOE  : NOMBRE DE NOEUD DE LA LISTE LNONOE
C IN : LNONOE : LISTE DE NOMS DE NOEUD
C IN : NEQ    : NOMBRE D'EQUATIONS DE NUME
C IN : IVEC   : VECTEUR DE POINTEURS DE DDLS DEJA ALLOUE.
C
C     OUT:
C     IVEC EST REMPLI DE 0 OU DE 1
C     IVEC(IEQ) =
C       - 1 SI LE IEQ-EME NOEUD DE NUME A POUR NOM: LNONOE(INOE)
C       - 0 SINON
C ----------------------------------------------------------------------
C---------------- COMMUNS NORMALISES  JEVEUX  --------------------------
      CHARACTER*32 JEXNUM,JEXNOM
      INTEGER        ZI
      COMMON /IVARJE/ZI(1)
      REAL*8         ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16     ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL        ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8    ZK8
      CHARACTER*16          ZK16
      CHARACTER*24                  ZK24
      CHARACTER*32                          ZK32
      CHARACTER*80                                  ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C ---------------- FIN COMMUNS NORMALISES  JEVEUX  --------------------
      INTEGER      NBEC, GD
      CHARACTER*8  NOMMA, NOMNO, K8BID
      CHARACTER*24 NOMNU
      CHARACTER*24 VALK(2)
C ----------------------------------------------------------------------
C
C     - MISE A ZERO DE IVEC:
C     - NON NECESSAIRE, L'OBJET EST CREE/DETRUIT A CHAQUE FOIS 
C     - DANS MSTGET
      CALL JEMARQ()
C      DO 10 I = 1,NEQ
C          DO 10 J = 1,NBNOE
C              IVEC(I,J) = 0
C 10   CONTINUE
C
      NOMNU(1:14)  = NUME
      NOMNU(15:19) = '.NUME'
      CALL JEVEUO(NOMNU(1:19)//'.NUEQ','L',IANUEQ)
      CALL DISMOI('F','NOM_MAILLA',NUME,'NUME_DDL',IBID,NOMMA,IERD)
      CALL DISMOI('F','NUM_GD_SI' ,NUME,'NUME_DDL',GD  ,K8BID,IERD)
      NEC = NBEC(GD)
      CALL JENONU(JEXNOM(NOMNU(1:19)//'.LILI','&MAILLA'),IBID)
      CALL JEVEUO(JEXNUM(NOMNU(1:19)//'.PRNO',IBID),'L',IAPRNO)
C
      DO 20 IN = 1,NBNOE
         NOMNO = LNONOE(IN)
         CALL JENONU(JEXNOM(NOMMA//'.NOMNOE',NOMNO),NUNOE)
         IF (NUNOE.EQ.0) THEN
           VALK (1) = NOMNO
           VALK (2) = NOMMA
           CALL U2MESG('E', 'UTILITAI6_47',2,VALK,0,0,0,0.D0)
         ENDIF
         IEQ   = ZI(IAPRNO-1+(NEC+2)*(NUNOE-1)+1)
         NBCMP = ZI(IAPRNO-1+(NEC+2)*(NUNOE-1)+2)
         DO 22 I = 1,NBCMP
            IVEC(IEQ+I-1) = 1
 22      CONTINUE
 20   CONTINUE
C
      CALL JEDEMA()
      END
