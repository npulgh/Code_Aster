      SUBROUTINE MECACT(BASE,NOMCAR,MOCLEZ,NOMCO,NOMGDZ,NCMP,LICMP,
     &                  ICMP,RCMP,CCMP,KCMP)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 18/12/2012   AUTEUR SELLENET N.SELLENET 
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
C-----------------------------------------------------------------------
      IMPLICIT NONE
C     CREER 1 CARTE CONSTANTE SUR 1 MODELE.
C-----------------------------------------------------------------------
C
C     ARGUMENTS:
C     ----------
      INCLUDE 'jeveux.h'
      CHARACTER*(*) BASE,NOMCAR,NOMCO
      CHARACTER*(*) NOMGDZ, MOCLEZ
      CHARACTER*8 NOMGD
      CHARACTER*6 MOCLE
      INTEGER NCMP
      CHARACTER*(*) LICMP(NCMP)
      CHARACTER*(*) KCMP(NCMP)
      INTEGER ICMP(NCMP)
      REAL*8 RCMP(NCMP)
      COMPLEX*16 CCMP(NCMP)
C ----------------------------------------------------------------------
C     ENTREES:
C      BASE   : BASE DE CREATION POUR LA CARTE (G/V/L)
C      NOMCAR : NOM DE LA CARTE A CREER (SI ELLE EXISTE ON LA DETRUIT).
C      MOCLEZ : 'MAILLA' , 'MODELE' OU 'LIGREL'
C      NOMCO  : NOM DU MAILLAGE SUPPORT DE LA CARTE (SI MOCLE='MAILLA')
C             : NOM DU MODELE SUPPORT DE LA CARTE (SI MOCLE='MODELE')
C             : NOM DU LIGREL SUPPORT DE LA CARTE.(SI MOCLE= 'LIGREL')
C             : K19 SI MOCLEZ = LIGREL, K8 SINON
C      NOMGDZ : NOM DE LA GRANDEUR ASSOCIEE A LA CARTE.
C      NCMP   : NOMBRE DE CMP A EDITER SUR LA CARTE.
C      LICMP  : LISTE DES NOMS DE CMP A EDITER.
C      ICMP   : LISTE DES VALEURS ENTIERES DES CMP A EDITER.(EVENTUEL).
C      RCMP   : LISTE DES VALEURS REELLES  DES CMP A EDITER.(EVENTUEL).
C      CCMP   : LISTE DES VALEURS COMPLEX  DES CMP A EDITER.(EVENTUEL).
C      KCMP   : LISTE DES VALEURS CHAR*8,16,24  DES CMP A EDITER.(EVT).
C
C     SORTIES:
C       NOMCAR : EST REMPLI.
C
C ----------------------------------------------------------------------
C
C     FONCTIONS EXTERNES:
C     -------------------
      CHARACTER*24 NOMMO2,NOMCA2
C
C     VARIABLES LOCALES:
C     ------------------
      CHARACTER*1 TYPE,BAS2
      CHARACTER*8 NOMA
      CHARACTER*1 K1BID
C
C-----------------------------------------------------------------------
      INTEGER I ,IANOMA ,IBID ,IRET ,JNCMP ,JVALV ,LTYP 

C-----------------------------------------------------------------------
      CALL JEMARQ()
      MOCLE = MOCLEZ
      NOMGD = NOMGDZ
C
      BAS2=BASE
C
C     -- RECUPERATION DU NOM DU MAILLAGE:
      NOMMO2 = NOMCO
      NOMCA2 = NOMCAR
      IF (MOCLE(1:6).EQ.'MAILLA') THEN
         NOMA = NOMMO2(1:8)
      ELSEIF (MOCLE(1:6).EQ.'MODELE') THEN
         CALL JEVEUO(NOMMO2(1:8)//'.MODELE    .LGRF','L',IANOMA)
         NOMA = ZK8(IANOMA-1+1)
      ELSEIF (MOCLE(1:6).EQ.'LIGREL') THEN
         CALL JEVEUO(NOMMO2(1:19)//'.LGRF','L',IANOMA)
         NOMA = ZK8(IANOMA-1+1)
      ELSE
         CALL ASSERT(.FALSE.)
      ENDIF
C
C     -- SI LA CARTE EXISTE DEJA , ON LA DETRUIT COMPLETEMENT:
C
      CALL JEEXIN(NOMCA2(1:19)//'.NOMA',IRET)
      IF (IRET.GT.0) CALL JEDETR(NOMCA2(1:19)//'.NOMA')
      CALL JEEXIN(NOMCA2(1:19)//'.NOLI',IRET)
      IF (IRET.GT.0) CALL JEDETR(NOMCA2(1:19)//'.NOLI')
      CALL JEEXIN(NOMCA2(1:19)//'.DESC',IRET)
      IF (IRET.GT.0) CALL JEDETR(NOMCA2(1:19)//'.DESC')
      CALL JEEXIN(NOMCA2(1:19)//'.LIMA',IRET)
      IF (IRET.GT.0) CALL JEDETR(NOMCA2(1:19)//'.LIMA')
      CALL JEEXIN(NOMCA2(1:19)//'.VALE',IRET)
      IF (IRET.GT.0) CALL JEDETR(NOMCA2(1:19)//'.VALE')
      CALL JEEXIN(NOMCA2(1:19)//'.NCMP',IRET)
      IF (IRET.GT.0) CALL JEDETR(NOMCA2(1:19)//'.NCMP')
      CALL JEEXIN(NOMCA2(1:19)//'.VALV',IRET)
      IF (IRET.GT.0) CALL JEDETR(NOMCA2(1:19)//'.VALV')
C
C     -- ON ALLOUE LA CARTE:
C
      CALL ALCART(BAS2,NOMCA2,NOMA,NOMGD)
      CALL JEVEUO(NOMCA2(1:19)//'.NCMP','E',JNCMP)
      CALL JEVEUO(NOMCA2(1:19)//'.VALV','E',JVALV)
      CALL JELIRA(NOMCA2(1:19)//'.VALV','TYPE',IBID,TYPE)
      CALL JELIRA(NOMCA2(1:19)//'.VALV','LTYP',LTYP,K1BID)
      DO 1,I = 1,NCMP
         ZK8(JNCMP-1+I) = LICMP(I)
         IF (TYPE(1:1).EQ.'R') THEN
            ZR(JVALV-1+I) = RCMP(I)
         END IF
         IF (TYPE(1:1).EQ.'C') THEN
            ZC(JVALV-1+I) = CCMP(I)
         END IF
         IF (TYPE(1:1).EQ.'I') THEN
            ZI(JVALV-1+I) = ICMP(I)
         END IF
         IF (TYPE(1:1).EQ.'K') THEN
            IF (LTYP.EQ.8) THEN
               ZK8(JVALV-1+I) = KCMP(I)
            ELSE IF (LTYP.EQ.16) THEN
               ZK16(JVALV-1+I) = KCMP(I)
            ELSE IF (LTYP.EQ.24) THEN
               ZK24(JVALV-1+I) = KCMP(I)
            ELSE
               CALL ASSERT(.FALSE.)
            END IF
         END IF
    1 CONTINUE
C
C     -- ON NOTE DANS LA CARTE LES VALEURS VOULUES :
C
      CALL NOCART(NOMCA2,1,' ','NOM',0,' ',0,' ',NCMP)
C
      CALL JEDETR(NOMCA2(1:19)//'.VALV')
      CALL JEDETR(NOMCA2(1:19)//'.NCMP')
      CALL JEDEMA()
      END
