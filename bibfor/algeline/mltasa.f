      SUBROUTINE MLTASA(NBLOC,LGBLOC,ADINIT,NOMMAT,LONMAT,
     +     FACTOL,FACTOU,TYPSYM)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGELINE  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
C RESPONSABLE JFBHHUC C.ROSE
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
C     TOLE CRS_512
C COMPIL PARAL
      IMPLICIT REAL*8 (A-H,O-Z)
      INCLUDE 'jeveux.h'
      INTEGER NBLOC,LGBLOC(*),LONMAT,ADINIT(LONMAT),TYPSYM
      CHARACTER*24 FACTOL,FACTOU,VALM
      CHARACTER*(*) NOMMAT
      INTEGER FIN,DEB,MATI,MATS,  IBID , IP,IREFAC,  LGBLIB
C===============================================================
C     ASSEMBLAGE DE LA MATRICE INITIALE DANS LA MATRICE FACTOR
C     VERSION ASTER
C     ON CONSIDERE LA MATRICE INITIALE SYMETRIQUE INFERIEURE
C     --------------             PAR LIGNES
C     ----------
C     VERSION NON SYMETRIQUE
C=============================================================
      CHARACTER*8 BASE
      INTEGER I,I1,IB,IFACL,IFACU,CODE,ADPROV,VALI(3)
      DATA VALM/'                   .VALM'/
      VALM(1:19) = NOMMAT
      CALL JEMARQ()
      IF(TYPSYM.EQ.1) THEN
         IP = 1
         CALL JEVEUO(JEXNUM(VALM,IP),'L',MATI)
         DO 10 I=1,LONMAT
            IF(ADINIT(I).LE.0) ADINIT(I) =  -ADINIT(I)
 10         CONTINUE
      ELSE
         IP = 1
         CALL JEVEUO(JEXNUM(VALM,IP),'L',MATS)
         IP = 2
         CALL JEVEUO(JEXNUM(VALM,IP),'L',MATI)
      ENDIF

C===================================================================
C     CREATION D'UNE COLLECTION DISPERSEE
C
C--   DEVANT RECREER LA COLLECTION FACTOR, ON LA DETRUIT SI ELLE EXISTE
C--   DEJA
C
      CALL JEEXIN(FACTOL,IREFAC)
      IF (IREFAC.GT.0) THEN
         CALL JEDETR(FACTOL)
      END IF
      CALL JELIRA(JEXNUM(VALM,IP),'CLAS',IBID,BASE)
C
      CALL JECREC(FACTOL,BASE(1:1)//' V R ','NU','DISPERSE',
     +     'VARIABLE',NBLOC)
      DO 50 IB = 1,NBLOC
         CALL JECROC(JEXNUM(FACTOL,IB))
         LGBLIB = LGBLOC(IB)
         CALL JEECRA(JEXNUM(FACTOL,IB),'LONMAX',LGBLIB,' ')
 50   CONTINUE
      FIN =0
      IF( TYPSYM.EQ.0) THEN
C     CAS NON-SYMETRIQUE
         CALL JEEXIN(FACTOU,IREFAC)
         IF (IREFAC.GT.0) THEN
            CALL JEDETR(FACTOU)
         END IF
         CALL JELIRA(JEXNUM(VALM,IP),'CLAS',IBID,BASE)
         CALL JECREC(FACTOU,BASE(1:1)//' V R ','NU','DISPERSE',
     +        'VARIABLE',NBLOC)
         DO 51 IB = 1,NBLOC
            CALL JECROC(JEXNUM(FACTOU,IB))
            LGBLIB = LGBLOC(IB)
            CALL JEECRA(JEXNUM(FACTOU,IB),'LONMAX',LGBLIB,' ')
 51     CONTINUE
         DO 130 IB = 1,NBLOC
            CALL JEVEUO(JEXNUM(FACTOL,IB),'E',IFACL)
            CALL JEVEUO(JEXNUM(FACTOU,IB),'E',IFACU)
            DO 110 I = 1,LGBLOC(IB)
               ZR(IFACL+I-1) = 0.D0
               ZR(IFACU+I-1) = 0.D0
 110        CONTINUE
            DEB = FIN
            FIN = DEB + LGBLOC(IB)
            DEB = DEB + 1
            DO 120 I1 = 1,LONMAT
               IF( ADINIT(I1).LE.0) THEN
                  CODE =-1
                  ADPROV = - ADINIT(I1)
               ELSE
               CODE =1
                  ADPROV = ADINIT(I1)
               ENDIF
               IF (ADPROV.GT.FIN) GO TO 120
               IF (ADPROV.LT.DEB) GO TO 120
               IF( CODE.GT.0 ) THEN
                  ZR(IFACL+ADPROV-DEB) = ZR(MATI+I1-1)
                  ZR(IFACU+ADPROV-DEB) = ZR(MATS+I1-1)
               ELSE
                  ZR(IFACL+ADPROV-DEB) = ZR(MATS+I1-1)
                  ZR(IFACU+ADPROV-DEB) = ZR(MATI+I1-1)
               ENDIF
 120        CONTINUE
            CALL JELIBE(JEXNUM(FACTOL,IB))
            CALL JELIBE(JEXNUM(FACTOU,IB))
 130     CONTINUE
         DO 140 IP=1,2
            CALL JELIBE(JEXNUM(VALM,IP))
 140     CONTINUE
         ELSE
C        CAS SYMETRIQUE
         DO 135 IB = 1,NBLOC
            CALL JEVEUO(JEXNUM(FACTOL,IB),'E',IFACL)
            DO 115 I = 1,LGBLOC(IB)
               ZR(IFACL+I-1) = 0.D0
 115        CONTINUE
            DEB = FIN
            FIN = DEB + LGBLOC(IB)
            DEB = DEB + 1
            DO 125 I1 = 1,LONMAT
               ADPROV = ADINIT(I1)
               IF (ADPROV.GT.FIN) GO TO 125
               IF (ADPROV.LT.DEB) GO TO 125
                  ZR(IFACL+ADPROV-DEB) = ZR(MATI+I1-1)
 125         CONTINUE
            CALL JELIBE(JEXNUM(FACTOL,IB))
 135     CONTINUE
         IP = 1
         CALL JELIBE(JEXNUM(VALM,IP))
         ENDIF
         CALL JELIBE(VALM)
         CALL JEDEMA()
         END
