      SUBROUTINE CHCSUR ( CHCINE, CNSZ, TYPE, MO, NOMGD )
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      CHARACTER*1         TYPE
      CHARACTER*8         NOMGD
      CHARACTER*(*)       CHCINE, CNSZ, MO
C-----------------------------------------------------------------------
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C-----------------------------------------------------------------------
C OBJET : CREATION D"UNE CHARGE CINEMATIQUE.
C        1) LE .REFE DE LA CHARGE DOIT DEJA EXISTER
C        2) MISE A JOUR DE : .AFCI ET .AFCV
C-----------------------------------------------------------------------
C OUT  CHCINE  K*19    : NOM DE LA CHARGE CINEMATIQUE
C IN   CNS     K*19    : NOM D'UN CHAM_NO_S CONTENANT LES DEGRES IMPOSES
C IN   TYPE    K*1     : 'R','C' OU 'F' TYPE DE LA CHARGE
C IN   MO      K*      : NOM DU MODELE
C IN   NOMGD   K*      : NOM DE LA GRANDEUR
C-----------------------------------------------------------------------
C
      INTEGER  NBLOC, IBLOC, ICMP, NCMP, INO, NBNO, NBEC, IER, II
      INTEGER  JCNSD, JCNSV, JCNSL, JAFCI, JAFCV, IAPRNM,JCNSC,KCMP
      INTEGER  JCMP,INDIK8,NCMPMX,JCORR
      LOGICAL  EXISDG
      CHARACTER*8   K8B, NOMO
      CHARACTER*19  CHCI, CNS
      CHARACTER*24  CAFCI, CAFCV
C
      DATA CAFCI /'                   .AFCI'/
      DATA CAFCV /'                   .AFCV'/
C
C --- DEBUT -----------------------------------------------------------
C
      CALL JEMARQ()
C
      NOMO = MO
      CALL DISMOI ( 'F', 'NB_EC', NOMGD, 'GRANDEUR', NBEC, K8B, IER )
      CALL JEVEUO ( NOMO//'.MODELE    .PRNM', 'L', IAPRNM )
C
      CHCI = CHCINE
      CNS  = CNSZ
      CAFCI(1:19) = CHCI
      CAFCV(1:19) = CHCI
C
      CALL JEVEUO ( CNS//'.CNSD', 'L', JCNSD )
      CALL JEVEUO ( CNS//'.CNSC', 'L', JCNSC )
      CALL JEVEUO ( CNS//'.CNSV', 'L', JCNSV )
      CALL JEVEUO ( CNS//'.CNSL', 'L', JCNSL )
C
      NBNO = ZI(JCNSD)
      NCMP = ZI(JCNSD+1)


C     -- ON CALCULE LA CORRESPONDANCE ENTRE LES CMPS DE CNS
C        ET CELLES DE LA GRANDEUR.
      CALL JEVEUO(JEXNOM('&CATA.GD.NOMCMP',NOMGD),'L',JCMP)
      CALL JELIRA(JEXNOM('&CATA.GD.NOMCMP',NOMGD),'LONMAX',NCMPMX,K8B)
      CALL WKVECT('&&CHCSUR.CORRES','V V I',NCMPMX,JCORR)
      DO 10, KCMP=1,NCMPMX
         ICMP = INDIK8(ZK8(JCNSC),ZK8(JCMP-1+KCMP),1,NCMP)
         ZI(JCORR-1+KCMP)=ICMP
 10   CONTINUE


C     -- CALCUL DE NBLOC :
      NBLOC = 0
      DO 100 ICMP = 1, NCMP
         DO 110 INO = 1 , NBNO
            IF ( ZL(JCNSL+(INO-1)*NCMP+ICMP-1) ) NBLOC = NBLOC + 1
 110     CONTINUE
 100  CONTINUE


C     -- CREATION DE LA SD
      CALL WKVECT ( CAFCI, 'G V I', (3*NBLOC+1), JAFCI )
      IF (TYPE.EQ.'R') THEN
         CALL WKVECT ( CAFCV, 'G V R' , MAX(NBLOC,1), JAFCV )
      ELSE IF (TYPE.EQ.'C') THEN
         CALL WKVECT ( CAFCV, 'G V C' , MAX(NBLOC,1), JAFCV )
      ELSE IF (TYPE.EQ.'F') THEN
         CALL WKVECT ( CAFCV, 'G V K8', MAX(NBLOC,1), JAFCV )
      ENDIF


C     -- ON REMPLIT LES OBJETS .AFCI .AFCV
      IBLOC = 0
      DO 120 INO = 1, NBNO
         II = 0
         DO 122 KCMP = 1, NCMPMX
            IF (EXISDG(ZI(IAPRNM-1+NBEC*(INO-1)+1),KCMP)) THEN
               II = II + 1
               ICMP=ZI(JCORR-1+KCMP)
               IF (ICMP.EQ.0) GOTO 122
               IF ( ZL(JCNSL+(INO-1)*NCMP+ICMP-1) ) THEN
                  IBLOC = IBLOC + 1
                  ZI(JAFCI+3*(IBLOC-1)+1) = INO
                  ZI(JAFCI+3*(IBLOC-1)+2) = II
                  IF (TYPE.EQ.'R') THEN
                    ZR(JAFCV-1+IBLOC) = ZR(JCNSV+(INO-1)*NCMP+ICMP-1)
                  ELSE IF (TYPE.EQ.'C') THEN
                    ZC(JAFCV-1+IBLOC) = ZC(JCNSV+(INO-1)*NCMP+ICMP-1)
                  ELSE IF (TYPE.EQ.'F') THEN
                    ZK8(JAFCV-1+IBLOC) = ZK8(JCNSV+(INO-1)*NCMP+ICMP-1)
                  ELSE
                    CALL ASSERT(.FALSE.)
                  ENDIF
               ENDIF
            ENDIF
 122     CONTINUE
 120  CONTINUE

      IF (IBLOC.EQ.0) CALL U2MESS('F','CALCULEL_9')
      ZI(JAFCI) = IBLOC

      CALL JEDETR('&&CHCSUR.CORRES')
      CALL JEDEMA()
      END
