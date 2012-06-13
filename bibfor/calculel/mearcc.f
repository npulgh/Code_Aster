      SUBROUTINE  MEARCC(OPTION,MO,CHIN,CHOUT)
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      CHARACTER*8 MO
      CHARACTER*16 OPTION
      CHARACTER*24 CHIN,CHOUT
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
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
C     COMMANDE DE CALC_ELEM SPECIFIQUE A L'OPTION SIRO_ELEM
C
C     BUT: REDUIRE LE CHAMP DE CONTRAINTES (ELNO) DES ELEMENTS 3D
C          A LEURS FACES
C
C     IN  MO     : NOM DU MODELE
C     IN  OPTION : NOM DE L'OPTION
C     IN  CHIN   : CHAMP DE CONTRAINTE ELNO DES ELEMENTS 3D
C     OUT CHOUT  : CHAMP DE CONTRAINTES ELNO REDUIT AUX MAILLES DE PEAU
C

      INTEGER      NBMA2D,IBID,IRET,JTYMA,JMA2D,NUMA,JCOOR,JMA3D,NBCMP
      INTEGER      JCESV3,JCESD3,JCESK3,JCESL3,JCESC3,JCESV2,JCESD2,IMA
      INTEGER      JCESK2,JCESL2,JCESC2,JLCNX,JCNX,IPT,ICP,INO2,INO3
      INTEGER      JCO3,JCO2,NPT3,NPT2,IPT2,IPT3,JPT3D,K,NPT
      INTEGER      NBNOMX,ZERO
      INTEGER      IAD3,IAD2,INDIK8,NUCMP
      REAL*8       PREC
      PARAMETER   (PREC=1.D-10,NBCMP=6,NBNOMX=9)
      CHARACTER*8  MA,TYPMA,NOMA,COMP(NBCMP),LIMOCL(2),TYMOCL(2),K8B,
     &             VALK(2)
      CHARACTER*19 CHOUS,CHINS
      CHARACTER*24 MAIL2D,MAIL3D,LIGRMO

      DATA COMP/'SIXX','SIYY','SIZZ','SIXY','SIXZ','SIYZ'/
      DATA LIMOCL/'MAILLE','GROUP_MA'/
      DATA TYMOCL/'MAILLE','GROUP_MA'/

      CALL JEMARQ()

C --- ON RECUPERE LES MAILLES DE PEAU
      MAIL2D='&&MEARCC.MAILLE_FACE'
      CALL DISMOI('F','NOM_MAILLA',MO,'MODELE',IBID,MA,IRET)
      CALL RELIEM(MO,MA,'NU_MAILLE',' ',0,2,LIMOCL,TYMOCL,MAIL2D,NBMA2D)

C --- ON VERIFIE QUE LES MAILLES FOURNIES SONT 2D
      IF (NBMA2D.GT.0) THEN
        CALL JEVEUO(MAIL2D,'L',JMA2D)
      ELSE
        CALL U2MESS('F','CALCULEL5_54')
      ENDIF
      CALL JEVEUO( MA//'.TYPMAIL', 'L', JTYMA )
      DO 10 IMA=1,NBMA2D
         NUMA=ZI(JMA2D+IMA-1)
         CALL JENUNO(JEXNUM('&CATA.TM.NOMTM',ZI(JTYMA+NUMA-1)),TYPMA)
         IF(TYPMA(1:4).NE.'QUAD'.AND.TYPMA(1:4).NE.'TRIA')THEN
           CALL JENUNO(JEXNUM(MA//'.NOMMAI',NUMA),NOMA)
           VALK(1)=NOMA
           VALK(2)=TYPMA
           CALL U2MESK('F','CALCULEL5_55',2,VALK)
         ENDIF
 10   CONTINUE

C --- ON RECHERCHE LA MAILLES 3D SUPPORT DE CHAQUE MAILLE 2D FOURNIE
      MAIL3D='&&MEARCC.MAILLE_3D_SUPP'
      ZERO=0
      CALL JEVEUO (MA//'.COORDO    .VALE', 'L', JCOOR)
      CALL UTMASU(MA,'3D',NBMA2D,ZI(JMA2D),MAIL3D,PREC,ZR(JCOOR),
     &            ZERO,IBID)
      CALL JEVEUO(MAIL3D,'L',JMA3D)

C     =============================================================
C --- POUR CHAQUE NOEUD DE LA MAILLE 3D SUPPORT, ON RECOPIE LES
C     CONTRAINTES AUX NOEUDS DE LA MAILLE DE PEAU
C     =============================================================

C     TRANSFORMATION DU CHAMP 3D (IN) EN CHAMP SIMPLE
      CHINS='&&MEARCC.CHIN_S'
      CALL CELCES(CHIN,'V',CHINS)
      CALL JEVEUO(CHINS//'.CESV','L',JCESV3)
      CALL JEVEUO(CHINS//'.CESD','L',JCESD3)
      CALL JEVEUO(CHINS//'.CESK','L',JCESK3)
      CALL JEVEUO(CHINS//'.CESL','L',JCESL3)
      CALL JEVEUO(CHINS//'.CESC','L',JCESC3)

C     CREATION DU CHAMP 2D (OUT) SIMPLE
      CHOUS='&&MEARCC.CHOUT_S'
      CALL CESCRE('V',CHOUS,'ELNO',MA,'SIEF_R',NBCMP,COMP,-1,-1,-NBCMP)

      CALL JEVEUO(CHOUS//'.CESV','E',JCESV2)
      CALL JEVEUO(CHOUS//'.CESD','E',JCESD2)
      CALL JEVEUO(CHOUS//'.CESK','E',JCESK2)
      CALL JEVEUO(CHOUS//'.CESL','E',JCESL2)
      CALL JEVEUO(CHOUS//'.CESC','E',JCESC2)

C     CORRESPONDANCE PT_MAILLE 2D / PT_MAILLE 3D: ZI(JPT3D)
C     POUR CHAQUE POINT DE LA MAILLE 2D, ON CHERCHE LE
C     POINT DE LA MAILLE 3D CORRESPONDANT
      CALL WKVECT('&&MEARCC.PT3D','V V I',NBMA2D*NBNOMX,JPT3D)
      CALL JEVEUO(MA//'.CONNEX','L',JCNX)
      CALL JEVEUO(JEXATR(MA//'.CONNEX','LONCUM'),'L',JLCNX)
      DO 100 IMA=1,NBMA2D
        JCO3=JCNX+ZI(JLCNX-1+ZI(JMA3D+IMA-1))-1
        JCO2=JCNX+ZI(JLCNX-1+ZI(JMA2D+IMA-1))-1
        NPT3=ZI(JCESD3-1+5+4*(ZI(JMA3D+IMA-1)-1)+1)
        NPT2=ZI(JCESD2-1+5+4*(ZI(JMA2D+IMA-1)-1)+1)
        K=0
        DO 110 IPT2=1,NPT2
           INO2=ZI(JCO2+IPT2-1)
           DO 111 IPT3=1,NPT3
             INO3=ZI(JCO3+IPT3-1)
             IF(INO3.EQ.INO2)THEN
                K=K+1
                ZI(JPT3D+NBNOMX*(IMA-1)+K-1)=IPT3
                GOTO 110
             ENDIF
 111      CONTINUE
 110    CONTINUE
 100   CONTINUE


C     REMPLISSAGE DU CHAMP SIMPLE 3D
      DO 200 IMA=1,NBMA2D
        NPT=ZI(JCESD2-1+5+4*(ZI(JMA2D+IMA-1)-1)+1)
        CALL JENUNO(JEXNUM(MA//'.NOMMAI',ZI(JMA2D+IMA-1)),K8B)
        DO 210 IPT=1,NPT
          DO 220 ICP=1,NBCMP
            NUCMP=INDIK8( ZK8(JCESC3), COMP(ICP), 1, ZI(JCESD3+1) )
            CALL CESEXI('S',JCESD3,JCESL3,ZI(JMA3D+IMA-1),
     &                ZI(JPT3D+NBNOMX*(IMA-1)+IPT-1),1,NUCMP,IAD3)
            CALL CESEXI('S',JCESD2,JCESL2,ZI(JMA2D+IMA-1),
     &                  IPT,1,NUCMP,IAD2)
            ZR(JCESV2-IAD2-1)=ZR(JCESV3+IAD3-1)
            ZL(JCESL2-IAD2-1)=.TRUE.
 220     CONTINUE
 210   CONTINUE
 200  CONTINUE

      CALL CESRED(CHOUS,NBMA2D,ZI(JMA2D),0,K8B,'V',CHOUS)

      CALL DISMOI('F','NOM_LIGREL',MO,'MODELE',IBID,LIGRMO,IRET)

      CALL CESCEL(CHOUS,LIGRMO,OPTION,'PSIG3D','OUI',IBID,'V',CHOUT,'F',
     &            IBID)

      CALL JEDETR('&&MEARCC.PT3D')
      CALL JEDETR(MAIL3D)
      CALL JEDETR(MAIL2D)
      CALL DETRSD('CHAM_ELEM_S',CHOUS)
      CALL DETRSD('CHAM_ELEM_S',CHINS)

      CALL JEDEMA()

      END
