      SUBROUTINE CFNODB(CHAR  )
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 22/03/2011   AUTEUR DESOZA T.DESOZA 
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
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C
      IMPLICIT     NONE
      CHARACTER*8  CHAR
C
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODES MAILLEES - LECTURE DONNEES - ELIMINATION)
C
C DETECTION DE NOEUDS APPARTENANT AUX DEUX SURFACES DE CONTACT
C
C ----------------------------------------------------------------------
C
C
C IN  CHAR   : NOM UTILISATEUR DU CONCEPT DE CHARGE
C
C -------------- DEBUT DECLARATIONS NORMALISEES JEVEUX -----------------
C
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
C
C ---------------- FIN DECLARATIONS NORMALISEES JEVEUX -----------------
C
      CHARACTER*24 NODBL ,CONTNO,SANSNO,PSANS ,PBARS ,PBARM
      INTEGER      JNODBL,JNOCO ,JSANS ,JPSANS,JPBARS,JPBARM
      INTEGER      IZONE,IBID,NVDBL
      INTEGER      NBNOE,JDECNE
      INTEGER      NBNOM,JDECNM
      INTEGER      NDOUBL,NSANS,JDECS
      INTEGER      NBARS,NBARM
      INTEGER      CFDISI,MMINFI,NZOCO,NNOCO
      INTEGER      IFORM
      INTEGER      VALI(2)
      LOGICAL      MMINFL,LCALC
      CHARACTER*24 DEFICO
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- INITIALISATIONS
C
      DEFICO = CHAR(1:8)//'.CONTACT'
      NZOCO  = CFDISI(DEFICO,'NZOCO' )
      NNOCO  = CFDISI(DEFICO,'NNOCO' )
      IFORM  = CFDISI(DEFICO,'FORMULATION')
C
C --- OBJETS TEMPORAIRES
C
      NODBL = '&&CFNODB.NODBL'
      CALL WKVECT(NODBL,'V V I',NNOCO,JNODBL)
C
C --- ACCES AU TABLEAU DES NOEUDS DE CONTACT
C
      CONTNO = DEFICO(1:16)//'.NOEUCO'
      CALL JEVEUO(CONTNO,'L',JNOCO)
      SANSNO = DEFICO(1:16)//'.SSNOCO'
      CALL JEVEUO(SANSNO,'L',JSANS)
      PSANS  = DEFICO(1:16)//'.PSSNOCO'
      CALL JEVEUO(PSANS ,'L',JPSANS)
C
      IF (IFORM.EQ.2) THEN
        PBARS  = DEFICO(1:16)//'.PBANOCO'
        CALL JEVEUO(PBARS,'L',JPBARS)
        PBARM  = DEFICO(1:16)//'.PBAMACO'
        CALL JEVEUO(PBARM,'L',JPBARM)
      ENDIF
C
C --- PARCOURS DES ZONES
C
      DO 100 IZONE = 1,NZOCO
        NBNOE  = MMINFI(DEFICO,'NBNOE' ,IZONE )
        NBNOM  = MMINFI(DEFICO,'NBNOM' ,IZONE )
        JDECNE = MMINFI(DEFICO,'JDECNE',IZONE )
        JDECNM = MMINFI(DEFICO,'JDECNM',IZONE )
        LCALC  = MMINFL(DEFICO,'CALCUL',IZONE )
        IF (.NOT.LCALC) THEN
          GOTO 100
        ENDIF
        CALL UTLISI('INTER',ZI(JNOCO+JDECNE),NBNOE ,
     &                      ZI(JNOCO+JDECNM),NBNOM ,
     &                      ZI(JNODBL)      ,NNOCO ,
     &                      NDOUBL)
        IF (NDOUBL.NE.0) THEN
          IF (NDOUBL.GT.0) THEN
C --------- LES NOEUDS COMMUNS SONT-ILS EXCLUS PAR SANS_NOEUD ?
            NSANS = ZI(JPSANS+IZONE) - ZI(JPSANS+IZONE-1)
            JDECS = ZI(JPSANS+IZONE-1)
            CALL UTLISI('DIFFE',ZI(JNODBL)     ,NDOUBL,
     &                          ZI(JSANS+JDECS),NSANS ,
     &                          IBID           ,1     ,
     &                          NVDBL)
C --------- NON !
            IF (NVDBL.NE.0) THEN
              VALI(1) = IZONE
              VALI(2) = ABS(NVDBL)
              IF (IFORM.EQ.1) THEN
                 CALL U2MESI('F','CONTACT2_13',2,VALI)
              ELSEIF (IFORM.EQ.2) THEN
                 NBARS = ZI(JPBARS+IZONE) - ZI(JPBARS+IZONE-1)
                 NBARM = ZI(JPBARM+IZONE) - ZI(JPBARM+IZONE-1)
                 IF (NBARS.EQ.0.AND.NBARM.EQ.0) THEN
                   CALL U2MESI('F','CONTACT2_13',2,VALI)
                 ENDIF
              ELSE
                 CALL ASSERT(.FALSE.)
              ENDIF
            ENDIF
          ELSE
            CALL ASSERT(.FALSE.)
          ENDIF
        ENDIF
 100  CONTINUE
C
C --- MENAGE
C
      CALL JEDETR(NODBL)
C
      CALL JEDEMA()
      END
