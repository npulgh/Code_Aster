      SUBROUTINE CHNUCN(CHNO1,NUMDD2,NCORR,TCORR,BASE,CHNO2)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 07/09/2010   AUTEUR DESOZA T.DESOZA 
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
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
      IMPLICIT REAL*8 (A-H,O-Z)
      CHARACTER*(*) CHNO1,NUMDD2,BASE,CHNO2,TCORR(*)
      INTEGER NCORR
C
C-----------------------------------------------------------------------
C BUT:
C ----
C CREER UN CHAM_NO S'APPUYANT SUR UN NUME_DDL
C ET CONTENANT LES VALEURS D'UN AUTRE CHAM_NO
C-----------------------------------------------------------------------
C ARGUMENTS:
C ----------
C IN/JXIN  CHNO1: K19 : CHAM_NO DONT ON VA RECUPERER LES VALEURS
C IN/JXIN  NUMDD2 : K14 : PROF_CHNO DU CHAM_NO A CREER
C IN       BASE   : K1  : NOM DE LA BASE SUR LAQUELLE LE CHAM_NO DOIT
C                         ETRE CREE
C IN       NCORR  : I   : DIMENSION DE TCORR
C IN       TCORR  : L_K8: TABLE DE CORRESPONDANCE DES COMPOSANTES
C
C IN/JXOUT CHNO2: K19 : NOM DU CHAM_NO A CREER
C
C-----------------------------------------------------------------------
C USAGE:
C ------
C CETTE ROUTINE RECOPIE LES VALEURS DU CHAM_NO (CHNO1) DANS UN NOUVEAU
C CHAM_NO (CHNO2) QUI S'APPUIE SUR LA NUMEROTATION (NUMDD2).CE CHAM_NO
C EST CREE SUR LA BASE (BASE).
C
C   CHNO2 DOIT ETRE DIFFERENT DE CHNO1.
C   CHNO2 EST ECRASE S'IL EXISTE DEJA.
C
C ON NE TRAITE QUE LES NOEUDS DU MAILLAGE (PAS LES NOEUDS DE LAGRANGE)
C ON NE TRAITE POUR L'INSTANT QUE LES CHAM_NO DE TYPE R8
C
C SI UNE COMPOSANTE DE CHNO2 N'EST PAS AFFECTEE DANS CHNO1, ON LA
C MET A ZERO.
C
C LA GRANDEUR ASSOCIEE A CHNO2 PEUT ETRE DIFFERENTE DE CELLE DE
C CHNO1. DANS CE CAS, ON UTILISE LA TABLE DE CORRESPONDANCE DES
C COMPOSANTES (TCORR)
C (ON SE SERVIRA SYSTEMATIQUEMENT DE TCORR LORSQUE NCORR /= 0)
C
C   NCORR EST UN ENTIER PAIR.
C   SI NCORR = 0 , LA GRANDEUR ASSOCIEE A CHNO1 DOIT ETRE IDENTIQUE A
C                  CELLE DE NUMDD2.
C   LA CORRESPONDANCE : TCORR(2*(I-1)+1) --> TCORR(2*(I-1)+2) DOIT ETRE
C   INJECTIVE.
C
C
C EXEMPLE 1 :
C -----------
C ON DISPOSE D'UN CHAM_NO_DEPL_R SUR L'ENSEMBLE DU MODELE GLOBAL : CHG
C ON DISPOSE D'UN SOUS-MODELE ET D'UN NUME_DDL ASSOCIE : NUL
C ON PEUT ALORS CREER LE CHAM_NO_DEPL_R "PROJETE" SUR LE SOUS-MODELE:CHL
C

C
C INVERSEMENT, ON POURRAIT "PROLONGER" (PAR DES ZEROS) UN CHAMP LOCAL :

C
C EXEMPLE 2 :
C -----------
C ON DISPOSE D'UN CHAM_NO_DEPL_R ASSOCIE A 1 MODELE MECANIQUE (CHDEPL)
C ON DISPOSE D'UN NUME_DDL ASSOCIE A 1 MODELE THERMIQUE (NUTH)
C ON PEUT ALORS CREER LE CHAM_NO_TEMP_R (CHTEMP)
C QUI CONTIENDRA COMME COMPOSANTE: 'TEMP' LES VALEURS DE CHDEPL POUR
C LA COMPOSANTE 'DY'
C
C       TCORR(1)='DY'
C       TCORR(2)='TEMP'
C

C
C EXEMPLE 3 :
C -----------
C ON DISPOSE D'UN CHAM_NO_DEPL_R (CHDEPL)
C ON DISPOSE DU NUME_DDL ASSOCIE A CE CHAM_NO : NUDEPL
C ON PEUT ALORS CREER LE CHAM_NO_DEPL_R (CHDEPL2)
C AVEC LES CORRESPONDANCES SUIVANTES :
C
C  CHNO2_DX = 0.
C  CHNO2_DY = CHNO1_DX
C  CHNO2_DZ = CHNO1_DY
C
C
C       TCORR(1)='DX'
C       TCORR(2)='DY'
C       TCORR(3)='DY'
C       TCORR(4)='DZ'
C

C
C  LA COMPOSANTE 'DX' DE CHNO2 N'ETANT PAS DANS LA TABLE DE
C  CORRESPONDANCE, ON LUI AFFECTERA LA VALEUR : 0.
C
C
C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------
C
      CHARACTER*32       JEXNUM , JEXNOM
      INTEGER            ZI
      COMMON  / IVARJE / ZI(1)
      REAL*8             ZR
      COMMON  / RVARJE / ZR(1)
      COMPLEX*16         ZC
      COMMON  / CVARJE / ZC(1)
      LOGICAL            ZL,EXISDG
      COMMON  / LVARJE / ZL(1)
      CHARACTER*8        ZK8
      CHARACTER*16                ZK16
      CHARACTER*24                          ZK24
      CHARACTER*32                                    ZK32
      CHARACTER*80                                              ZK80
      COMMON  / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) , ZK80(1)
C
C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------
C
      CHARACTER*1 BASE2
      CHARACTER*8 GD1,GD2,REPK,TYSCA1,TYSCA2,MA,CMP1,CMP2
      CHARACTER*14 NU2
      CHARACTER*19 CN1,CN2,PCHNO1,PCHNO2
      CHARACTER*1 K1BID
      CALL JEMARQ()
      BASE2 = BASE
      CN1 = CHNO1
      CN2 = CHNO2
      NU2 = NUMDD2
C
C ------------------------------ VERIFICATIONS -------------------------
C
      CALL DISMOI('F','NOM_GD',CN1,'CHAM_NO',IBID,GD1,IERD)
      CALL DISMOI('F','PROF_CHNO',CN1,'CHAM_NO',IBID,PCHNO1,IERD)
      PCHNO2=NU2//'.NUME'
      CALL DISMOI('F','NOM_GD',NU2,'NUME_DDL',IBID,GD2,IERD)
C
      CALL DISMOI('F','TYPE_SCA',GD1,'GRANDEUR',IBID,TYSCA1,IERD)
      CALL DISMOI('F','TYPE_SCA',GD2,'GRANDEUR',IBID,TYSCA2,IERD)
      IF (TYSCA1.NE.'R') CALL U2MESK('F','CALCULEL_92',1,CN1)
      IF (TYSCA2.NE.'R') CALL U2MESK('F','CALCULEL_93',1,NU2)
C
C
      CALL DISMOI('F','NB_EQUA',CN1,'CHAM_NO',NVAL1,REPK,IERD)
C
C ------------------------------- REFE --------------------------------
C
C     -- SI CN2 EXISTE DEJA, ON LE DETRUIT :
      CALL JEEXIN(CN2//'.DESC',IRET)
      IF (IRET.GT.0) CALL DETRSD('CHAMP_GD',CN2)
C
      CALL WKVECT(CN2//'.REFE',BASE2//' V K24',4,I1)
      CALL JEVEUO(NU2//'.NUME.REFN','L',I2)
      ZK24(I1  ) = ZK24(I2)
      ZK24(I1+1) = NU2//'.NUME'
C
C ------------------------------- DESC --------------------------------
C
      CALL WKVECT(CN2//'.DESC',BASE2//' V I',2,I1)
      CALL JEECRA(CN2//'.DESC','DOCU',IBID,'CHNO')
      CALL DISMOI('F','NUM_GD',GD2,'GRANDEUR',NUGD2,REPK,IERD)
      ZI(I1 ) = NUGD2
      ZI(I1+1) = 1
C
C ------------------------------- VALE --------------------------------
C
      CALL DISMOI('F','NB_EQUA',NU2,'NUME_DDL',NVAL2,REPK,IERD)
      CALL WKVECT(CN2//'.VALE',BASE2//' V R',NVAL2,IAVAL2)
      CALL JEVEUO(CN1//'.VALE','L',IAVAL1)
C
      CALL JENONU(JEXNOM(PCHNO1//'.LILI','&MAILLA'),IBID)
      CALL JEVEUO(JEXNUM(PCHNO1//'.PRNO',IBID),'L',IPRN1)
      CALL JENONU(JEXNOM(PCHNO2//'.LILI','&MAILLA'),IBID)
      CALL JEVEUO(JEXNUM(PCHNO2//'.PRNO',IBID),'L',IPRN2)
      CALL JEVEUO(PCHNO1//'.NUEQ','L',INUEQ1)
      CALL JEVEUO(PCHNO2//'.NUEQ','L',INUEQ2)
C
      CALL DISMOI('F','NOM_MAILLA',CN1,'CHAM_NO',IBID,MA,IERD)
      CALL DISMOI('F','NOM_MAILLA',NU2,'NUME_DDL',IBID,REPK,IERD)
      CALL ASSERT(MA.EQ.REPK)
      CALL DISMOI('F','NB_NO_MAILLA',MA,'MAILLAGE',NBNO,REPK,IERD)
C
      CALL DISMOI('F','NB_EC',GD1,'GRANDEUR',NEC1,REPK,IERD)
      CALL DISMOI('F','NB_EC',GD2,'GRANDEUR',NEC2,REPK,IERD)
C
      CALL JEVEUO(JEXNOM('&CATA.GD.NOMCMP',GD1),'L',IACMP1)
      CALL JEVEUO(JEXNOM('&CATA.GD.NOMCMP',GD2),'L',IACMP2)
      CALL JELIRA(JEXNOM('&CATA.GD.NOMCMP',GD1),'LONMAX',NCMMX1,K1BID)
      CALL JELIRA(JEXNOM('&CATA.GD.NOMCMP',GD2),'LONMAX',NCMMX2,K1BID)
C
C     -- REMPLISSAGE DE L'OBJET '.CORR2' :
C     ------------------------------------
      CALL WKVECT('&&CHNUCN.CORR2','V V I',NCMMX2,ICORR2)
      IF (NCORR.EQ.0) THEN
C       LES GRANDEURS G1 ET G2 DOIVENT ETRE IDENTIQUES
        CALL ASSERT(GD1.EQ.GD2)
        DO 5,I2=1,NCMMX2
          ZI(ICORR2-1+I2)=I2
 5      CONTINUE
      ELSE
        CALL ASSERT(NCORR.EQ.2*(NCORR/2))
        DO 4,I=1,NCORR/2
          CMP1=TCORR(2*(I-1)+1)
          CMP2=TCORR(2*(I-1)+2)
          J1=INDIK8(ZK8(IACMP1),CMP1,1,NCMMX1)
          J2=INDIK8(ZK8(IACMP2),CMP2,1,NCMMX2)
          IF (J2.NE.0) ZI(ICORR2-1+J2)=J1
 4      CONTINUE
      END IF
C
      DO 1, INO=1,NBNO
        IVAL1 = ZI(IPRN1-1+ (INO-1)* (NEC1+2)+1)
        IVAL2 = ZI(IPRN2-1+ (INO-1)* (NEC2+2)+1)
        NCMP1 = ZI(IPRN1-1+ (INO-1)* (NEC1+2)+2)
        NCMP2 = ZI(IPRN2-1+ (INO-1)* (NEC2+2)+2)
        IADG1 = IPRN1 - 1 + (INO-1)* (NEC1+2) + 3
        IADG2 = IPRN2 - 1 + (INO-1)* (NEC2+2) + 3
        IF (NCMP1*NCMP2.EQ.0) GO TO 1
        ICO2=0
        DO 2, I2=1,NCMMX2
          IF (EXISDG(ZI(IADG2),I2)) THEN
            ICO2=ICO2+1
            I1=ZI(ICORR2-1+I2)
C
            IF (.NOT.(EXISDG(ZI(IADG1),I1))) THEN
              ICO1=0
            ELSE
              ICO1=0
              DO 3, J1=1,I1
                IF (EXISDG(ZI(IADG1),J1)) ICO1=ICO1+1
 3            CONTINUE
            END IF
C
            IF (ICO1.GT.0) THEN
C             --RECOPIE D'UNE VALEUR :
              IEQ1 = ZI(INUEQ1-1+IVAL1-1+ICO1)
              IEQ2 = ZI(INUEQ2-1+IVAL2-1+ICO2)
              ZR(IAVAL2-1+IEQ2)=ZR(IAVAL1-1+IEQ1)
            END IF
C
          END IF
 2      CONTINUE
 1    CONTINUE
C
      CALL JEDETR('&&CHNUCN.CORR2')
C
      CALL JEDEMA()
      END
