      SUBROUTINE CHCORE(CHOU)
      IMPLICIT NONE
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
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
C
C     BUT : TRANSFORMER UN CHAMP : REEL --> COMPLEXE
C
C     LE CHAMP COMPLEXE EST CONSTRUIT DE SORTE QUE:
C    - SA PARTIE REELLE CORRESPOND AUX VALEURS DU CHAMP REEL
C    - SA PARTIE IMAGINAIRE EST NULLE.
C     -----------------------------------------------------------------
      INCLUDE 'jeveux.h'
      INTEGER IRET,IBID,JVALE,NBVAL,JVALIN,I
      REAL*8 ZERO
      PARAMETER(ZERO=0.D0)
      CHARACTER*3 TSCA
      CHARACTER*4 DOCU
      CHARACTER*8 CHOU,CHIN,NOMGD,K8B
      CHARACTER*24 K24B,VALE,VALIN
      INTEGER      IARG

      CALL JEMARQ()

C     RECUPERATION DU CHAMP REEL
      CALL GETVID(' ','CHAM_GD',0,IARG,1,CHIN,IRET)

C     VERIFICATION : CHIN REEL?
      CALL DISMOI('F','NOM_GD',CHIN,'CHAMP',IBID,NOMGD,IBID)
      CALL DISMOI('F','TYPE_SCA',NOMGD,'GRANDEUR',IBID,TSCA,IBID)
      IF(TSCA.NE.'R') CALL U2MESK('F','UTILITAI_20',1,CHIN)

C     COPIE CHIN --> CHOU
      CALL COPISD('CHAMP','G',CHIN,CHOU)
C
C
C     MODIFICATIONS DE CHOU:
C    ======================
C
C --- 1. ".VALE"
C     ----------
C     CHAM_NO OU CHAM_ELEM ?
      VALE(1:19)=CHOU
      K24B=VALE(1:19)//'.DESC'
      CALL JEEXIN(K24B,IBID)
      IF (IBID.GT.0) THEN
        K24B=VALE(1:19)//'.DESC'
        CALL JELIRA(K24B,'DOCU',IBID,DOCU)
      ELSE
        K24B=VALE(1:19)//'.CELD'
        CALL JELIRA(K24B,'DOCU',IBID,DOCU)
      END IF

      IF (DOCU.EQ.'CHNO') THEN
         VALE(20:24)='.VALE'
      ELSEIF (DOCU.EQ.'CHML') THEN
         VALE(20:24)='.CELV'
      ELSE
         CALL U2MESS('F','UTILITAI_21')
      ENDIF

      CALL JELIRA(VALE,'LONMAX',NBVAL,K8B)
      CALL JEDETR(VALE)
      CALL JECREO(VALE,'G V C')
      CALL JEECRA(VALE,'LONMAX',NBVAL,K8B)
      CALL JEVEUO(VALE,'E',JVALE)

      VALIN=VALE
      VALIN(1:19)=CHIN
      CALL JEVEUO(VALIN,'L',JVALIN)

      DO 10 I=1,NBVAL
        ZC(JVALE+I-1)=DCMPLX(ZR(JVALIN+I-1),ZERO)
 10   CONTINUE
C
C --- 2. CHANGEMENT DE LA GRANDEUR
C     ----------------------------
      CALL SDCHGD(CHOU,'C')

      CALL JEDEMA()

      END
