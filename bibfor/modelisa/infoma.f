      SUBROUTINE INFOMA ( NOMU )
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
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
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      CHARACTER*8 NOMU

C     IMPRESSION DES INFOS (1 OU 2)


      CHARACTER*32 LISNOE,LISMAI,LISGRN,LISGRM
      CHARACTER*32 COMNOE,COMMAI,COMGRN,COMGRM
      CHARACTER*24 CONXV,GRPNOV,GRPMAV,NOMNOE,TITRE,COOVAL
      CHARACTER*24 NOMMAI
      CHARACTER*8 NOM,TYPE,KBID
      INTEGER NIV,IFM,NN,NBNO,J,IDEC,IAD1,NBCOOR,JTYMA,NBMA
      INTEGER NBLTIT,IAD,I,NBNOEU,NBMAIL,NBGRNO,NBGRMA
      INTEGER NBMMAI,N1,NBMMAX,ITYP
      PARAMETER (NBMMAX=100)
      INTEGER DIMMAI(NBMMAX), JDIME,IRET
      CHARACTER*8 MCLMAI(NBMMAX)



      DATA LISNOE/'LISTE DES NOEUDS                '/
      DATA LISMAI/'LISTE DES MAILLES               '/
      DATA LISGRN/'LISTE DES GROUPES DE NOEUDS     '/
      DATA LISGRM/'LISTE DES GROUPES DE MAILLES    '/
      DATA COMNOE/'NOMBRE DE NOEUDS                '/
      DATA COMMAI/'NOMBRE DE MAILLES               '/
      DATA COMGRN/'NOMBRE DE GROUPES DE NOEUDS     '/
      DATA COMGRM/'NOMBRE DE GROUPES DE MAILLES    '/

      CALL JEMARQ()


      CONXV  = NOMU//'.CONNEX'
      GRPNOV = NOMU//'.GROUPENO'
      GRPMAV = NOMU//'.GROUPEMA'
      NOMNOE = NOMU//'.NOMNOE'
      NOMMAI = NOMU//'.NOMMAI'
      TITRE  = NOMU//'           .TITR'
      COOVAL = NOMU//'.COORDO    .VALE'



      CALL INFNIV(IFM,NIV)

      CALL JEEXIN(GRPMAV,IRET)
      IF (IRET.GT.0) THEN
         CALL JELIRA(GRPMAV,'NMAXOC',NBGRMA,KBID)
      ELSE
         NBGRMA=0
      END IF
      CALL JEEXIN(GRPNOV,IRET)
      IF (IRET.GT.0) THEN
         CALL JELIRA(GRPNOV,'NMAXOC',NBGRNO,KBID)
      ELSE
         NBGRNO=0
      END IF


      CALL JELIRA(TITRE,'LONMAX',NBLTIT,KBID)
      CALL JELIRA(NOMNOE,'NOMMAX',NBNOEU,KBID)
      CALL JELIRA(NOMMAI,'NOMMAX',NBMAIL,KBID)
      CALL JEVEUO(NOMU//'.DIME','L',JDIME)
      CALL JEVEUO(NOMU//'.TYPMAIL','L',JTYMA)
      NBCOOR=ZI(JDIME-1+6)


      CALL JELIRA('&CATA.TM.NOMTM','NOMMAX',NBMMAI,KBID)
      DO 20 I = 1,NBMMAI
        DIMMAI(I) = 0
        CALL JENUNO(JEXNUM('&CATA.TM.NOMTM',I),MCLMAI(I))
   20 CONTINUE
      DO 21 I = 1,NBMAIL
        ITYP=ZI(JTYMA-1+I)
        CALL ASSERT((ITYP.GT.0).AND.(ITYP.LT.100))
        DIMMAI(ITYP)=DIMMAI(ITYP)+1
   21 CONTINUE




C -     ECRITURE DE L EN TETE
C ----------------------------------
      IF (NIV.GE.1) THEN
        WRITE (IFM,802) NOMU,NIV
        CALL JEVEUO(TITRE,'L',IAD)
        DO 40 I = 1,NBLTIT
          WRITE (IFM,801) ZK80(IAD+I-1)
   40   CONTINUE
        WRITE (IFM,804) COMNOE,NBNOEU
        WRITE (IFM,804) COMMAI,NBMAIL
        DO 50 I = 1,NBMMAI
          IF (DIMMAI(I).NE.0)  WRITE (IFM,806) MCLMAI(I),DIMMAI(I)
   50   CONTINUE

        IF (NBGRNO.NE.0) THEN
          WRITE (IFM,804) COMGRN,NBGRNO
          DO 60 I = 1,NBGRNO
            CALL JEEXIN(JEXNUM(GRPNOV,I),IRET)
            IF (IRET.EQ.0) GOTO 60
            CALL JENUNO(JEXNUM(GRPNOV,I),NOM)
            CALL JELIRA(JEXNUM(GRPNOV,I),'LONUTI',N1,KBID)
            WRITE (IFM,808) NOM,N1
   60     CONTINUE
        END IF

        IF (NBGRMA.NE.0) THEN
          WRITE (IFM,804) COMGRM,NBGRMA
          DO 70 I = 1,NBGRMA
            CALL JEEXIN(JEXNUM(GRPMAV,I),IRET)
            IF (IRET.EQ.0) GOTO 70
            CALL JENUNO(JEXNUM(GRPMAV,I),NOM)
            CALL JELIRA(JEXNUM(GRPMAV,I),'LONUTI',N1,KBID)
            WRITE (IFM,808) NOM,N1
   70     CONTINUE
        END IF
      END IF



      IF (NIV.GE.2) THEN

        WRITE (IFM,803) LISNOE
        CALL JEVEUO(COOVAL,'L',IAD)
        DO 80 I = 1,NBNOEU
          CALL JENUNO(JEXNUM(NOMNOE,I),NOM)
          IDEC = IAD + (I-1)*3
          WRITE (IFM,701) I,NOM, (ZR(IDEC+J-1),J=1,NBCOOR)
   80   CONTINUE

        WRITE (IFM,803) LISMAI
        DO 90 I = 1,NBMAIL
          CALL JENUNO(JEXNUM(NOMMAI,I),NOM)
          CALL JEVEUO(JEXNUM(CONXV,I),'L',IAD1)
          CALL JELIRA(JEXNUM(CONXV,I),'LONMAX',NBNO,KBID)
          ITYP=ZI(JTYMA-1+I)
          CALL JENUNO(JEXNUM('&CATA.TM.NOMTM',ITYP),TYPE)
          IF (NBNO.LE.5) THEN
            WRITE (IFM,702) I,NOM,TYPE, (ZI(IAD1+J-1),J=1,NBNO)
          ELSE
            WRITE (IFM,702) I,NOM,TYPE, (ZI(IAD1+J-1),J=1,5)
            WRITE (IFM,703) (ZI(IAD1+J-1),J=6,NBNO)
          END IF
   90   CONTINUE

        IF (NBGRNO.NE.0) THEN
          WRITE (IFM,803) LISGRN
          DO 100 I = 1,NBGRNO
            CALL JEEXIN(JEXNUM(GRPNOV,I),IRET)
            IF (IRET.EQ.0) GOTO 100
            CALL JENUNO(JEXNUM(GRPNOV,I),NOM)
            CALL JEVEUO(JEXNUM(GRPNOV,I),'L',IAD)
            CALL JELIRA(JEXNUM(GRPNOV,I),'LONUTI',NBNO,KBID)
            NN = NBNO
            IF (NN.LE.5) THEN
              WRITE (IFM,704) I,NOM,NBNO, (ZI(IAD+J-1),J=1,NN)
            ELSE
              WRITE (IFM,704) I,NOM,NBNO, (ZI(IAD+J-1),J=1,5)
              WRITE (IFM,703) (ZI(IAD+J-1),J=6,NN)
            END IF
  100     CONTINUE
        END IF

        IF (NBGRMA.NE.0) THEN
          WRITE (IFM,803) LISGRM
          DO 110 I = 1,NBGRMA
            CALL JEEXIN(JEXNUM(GRPMAV,I),IRET)
            IF (IRET.EQ.0) GOTO 110
            CALL JENUNO(JEXNUM(GRPMAV,I),NOM)
            CALL JEVEUO(JEXNUM(GRPMAV,I),'L',IAD)
            CALL JELIRA(JEXNUM(GRPMAV,I),'LONUTI',NBMA,KBID)
            NN = NBMA
            IF (NBMA.LE.5) THEN
              WRITE (IFM,704) I,NOM,NBMA, (ZI(IAD+J-1),J=1,NN)
            ELSE
              WRITE (IFM,704) I,NOM,NBMA, (ZI(IAD+J-1),J=1,5)
              WRITE (IFM,703) (ZI(IAD+J-1),J=6,NN)
            END IF
  110     CONTINUE
        END IF
      END IF
      WRITE (IFM,809)

      CALL JEDEMA()


  701 FORMAT (2X,I8,2X,A8,10X,3 (D14.5,2X))
  702 FORMAT (2X,I8,2X,A8,2X,A8,5 (2X,I8))
  703 FORMAT (100 (30X,5 (2X,I8),/))
  704 FORMAT (2X,I8,2X,A8,2X,I8,5 (2X,I8))
  801 FORMAT (A80)
  802 FORMAT (/,'------------ MAILLAGE ',A8,
     &       ' - IMPRESSIONS NIVEAU ',I2,' ------------',/)
  803 FORMAT (/,15X,'------  ',A32,'  ------',/)
  804 FORMAT (/,A32,I12)
  806 FORMAT (30X,A8,5X,I12)
  808 FORMAT (30X,A8,2X,I12)
  809 FORMAT (/,80('-'),/)

      END
