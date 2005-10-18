      SUBROUTINE XRELCO(FISS,MOD,MA,LISREL,NREL)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 13/10/2005   AUTEUR GENIAUT S.GENIAUT 
C ======================================================================
C COPYRIGHT (C) 1991 - 2005  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE GENIAUT S.GENIAUT

      IMPLICIT NONE

      INTEGER NREL
      CHARACTER*8  FISS,MOD,MA
      CHARACTER*19 LISREL

C     BUT: CREER DES RELATIONS ENTRE LES INCONNUES DE CONTACT POUR
C          SATISFAIRE LA LBB CONDITION

C ARGUMENTS D'ENTREE:
C      FISS       : SD FISS_XFEM
C      MOD        : NOM DU MODELE
C      MA         : NOM DU MAILLAGE

C ARGUMENTS DE SORTIE:
C      LISREL    : LISTE DES RELATIONS A IMPOSER
C      NREL      : NOMBRE DE RELATIONS A IMPOSER


C     ----------- COMMUNS NORMALISES  JEVEUX  --------------------------
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
      CHARACTER*32 JEXNOM,JEXNUM,JEXATR
C---------------- FIN COMMUNS NORMALISES  JEVEUX  ----------------------
C
C---------------- DECLARATION DES VARIABLES LOCALES  -------------------
      REAL*8      RBID,BETAR,COEFR(3)
      INTEGER     IER,JLIS1,NDIM(3),NEQ,I,NRL,JLIS2,JLIS3,K
      INTEGER     NUNO(3)
      CHARACTER*8 NOEUD(3),K8BID,DDL(3),DDLC(3)
      COMPLEX*16  CBID
      DATA        BETAR/0.D0/
      DATA        DDLC/'LAGS_C','LAGS_F1','LAGS_F2'/
C-------------------------------------------------------------



      CALL JEMARQ()

C     1) RELATIONS D'EGALITE     
C        ----------------------

      CALL JEEXIN(FISS//'.CONTACT.LISEQ',IER)
      IF (IER.EQ.0) GO TO 100

      CALL JEVEUO(FISS//'.CONTACT.LISEQ','L',JLIS1)
      CALL JELIRA(FISS//'.CONTACT.LISEQ','LONMAX',NEQ,K8BID)

      write(6,*)'neq ',NEQ/2

      DO 10 I = 1,NEQ/2
        NUNO(1) = ZI(JLIS1-1+2*(I-1)+1)
        NUNO(2) = ZI(JLIS1-1+2*(I-1)+2)
        CALL JENUNO(JEXNUM(MA//'.NOMNOE',NUNO(1)),NOEUD(1))
        CALL JENUNO(JEXNUM(MA//'.NOMNOE',NUNO(2)),NOEUD(2))
        write(6,*)' ',NUNO(1),NUNO(2)
        COEFR(1) = 1.D0
        COEFR(2) = -1.D0
        NDIM(1) = 0
        NDIM(2) = 0
        DO 20 K=1,1
          DDL(1) = DDLC(K)
          DDL(2) = DDLC(K)
          CALL AFRELA(COEFR,CBID,DDL,NOEUD,NDIM,RBID,2,BETAR,CBID,
     &                K8BID,'REEL','REEL','12',0.D0,LISREL)
          NREL = NREL + 1
 20     CONTINUE
 10   CONTINUE

 100  CONTINUE


C     2) RELATIONS LINEAIRES
C     ----------------------

      CALL JEEXIN(FISS//'.CONTACT.LISRL',IER)
      IF (IER.EQ.0) GO TO 200

      CALL JEVEUO(FISS//'.CONTACT.LISRL','L',JLIS2)
      CALL JELIRA(FISS//'.CONTACT.LISRL','LONMAX',NRL,K8BID)
      CALL JEVEUO(FISS//'.CONTACT.LISCO','L',JLIS3)
      CALL JELIRA(FISS//'.CONTACT.LISCO','LONMAX',IER,K8BID)
      CALL ASSERT(IER.EQ.NRL)


            write(6,*)'nrl ',NRL/3

      DO 30 I = 1,NRL/3
        NUNO(1) = ZI(JLIS2-1+3*(I-1)+1)
        NUNO(2) = ZI(JLIS2-1+3*(I-1)+2)
        NUNO(3) = ZI(JLIS2-1+3*(I-1)+3)
        CALL JENUNO(JEXNUM(MA//'.NOMNOE',NUNO(1)),NOEUD(1))
        CALL JENUNO(JEXNUM(MA//'.NOMNOE',NUNO(2)),NOEUD(2))
        CALL JENUNO(JEXNUM(MA//'.NOMNOE',NUNO(3)),NOEUD(3))
        COEFR(1) = ZR(JLIS3-1+3*(I-1)+1)
        COEFR(2) = ZR(JLIS3-1+3*(I-1)+2)
        COEFR(3) = ZR(JLIS3-1+3*(I-1)+3)
        NDIM(1) = 0
        NDIM(2) = 0
        NDIM(3) = 0
        DO 40 K=1,1
          DDL(1) = DDLC(K)
          DDL(2) = DDLC(K)
          DDL(3) = DDLC(K)

          CALL AFRELA(COEFR,CBID,DDL,NOEUD,NDIM,RBID,3,BETAR,CBID,
     &                K8BID,'REEL','REEL','12',0.D0,LISREL)
          NREL = NREL + 1
 40     CONTINUE
 30   CONTINUE


 200  CONTINUE

      CALL JEDEMA()
      END
