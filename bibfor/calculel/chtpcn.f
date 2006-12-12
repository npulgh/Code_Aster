      SUBROUTINE CHTPCN(CHNO1,TGEOM,TAILMI,TMIN,EPSI,BASE,CHNO2)
      IMPLICIT REAL*8  (A-H,O-Z)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 13/12/2006   AUTEUR PELLET J.PELLET 
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
      CHARACTER*(*) CHNO1,BASE,CHNO2
      REAL*8  TGEOM(6),TMIN,EPSI,TAILMI,VAL,EPS
C
C----------------------------------------------------------------------
C AUTEUR: G.ROUSSEAU
C
C BUT:
C ----
C TRANSPORTER UN CHAMNO DE TEMP_R DEFINI SUR UNE PARTIE
C DU MAILLAGE D INTERFACE SUR UNE AUTRE PARTIE DE L INTERFACE
C CORRESPONDANT AUX CONTOURS IMMERGES D UNE
C SOUS-STRUCTURE NON MAILLEES PAR UNE TRANSFORMATION GEOMETRIQUE
C----------------------------------------------------------------------
C
C ARGUMENTS:
C ----------
C IN/JXIN  CHNO1: K19 : CHAM_NO DONT ON VA RECUPERER LES VALEURS
C IN       BASE   : K1  : NOM DE LA BASE SUR LAQUELLE LE CHAM_NO DOIT
C                         ETRE CREE
C IN       TAILMI  : R   : TAILLE DE MAILLE MIN
C IN       TGEOM : L_R8: TABLE DES COMPOSANTES DE LA TRANSFORMATION
C                        GEOMETRIQUE
C          3 COMPOSANTES DE TRANSL PUIS 3 ANGLES NAUTIQUES
C          DE ROTATION
C IN       TMIN : R8 : TEMP MINIMALE EN DECA DE LAQUELLE ON PEUT
C          AFFECTER
C          AU NOEUD UNE VALEUR DU CHAMNO A TRANSPORTER
C
C IN/JXOUT CHNO2: K19 : NOM DU CHAM_NO A CREER
C
C-----------------------------------------------------------------------
C
C
C
C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------
C
      CHARACTER*32       JEXNUM , JEXNOM , JEXR8 , JEXATR
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
      INTEGER     NBANTE,INO1
      CHARACTER*8 GD1,REPK,MA,CHNO
      CHARACTER*24 VALK(2)
      CHARACTER*8 DIFF,CHNAFF
      CHARACTER*19 CN1,CN2,PCHNO1,PCHNO2
      CHARACTER*1 K1BID

      CALL JEMARQ()
      CN1 = CHNO1
      CN2 = CHNO2
      CALL COPISD('CHAMP_GD',BASE,CN1,CN2)

C
C ------------------------------ VERIFICATIONS -------------------------
C
      CALL DISMOI('F','NOM_GD',CN1,'CHAM_NO',IBID,GD1,IERD)
      CALL DISMOI('F','PROF_CHNO',CN1,'CHAM_NO',IBID,PCHNO1,IERD)
      CALL DISMOI('F','PROF_CHNO',CN2,'CHAM_NO',IBID,PCHNO2,IERD)

C
C

      CALL JEVEUO(CN1//'.VALE','L',IAVAL1)
      CALL JELIRA(CN1//'.VALE','LONMAX',NBCN1,K1BID)


      CALL JEVEUO(CN2//'.VALE','E',IAVAL2)

C
      CALL JENONU(JEXNOM(PCHNO1//'.LILI','&MAILLA'),IBID)
      CALL JEVEUO(JEXNUM(PCHNO1//'.PRNO',IBID),'L',IPRN1)
      CALL JENONU(JEXNOM(PCHNO2//'.LILI','&MAILLA'),IBID)
      CALL JEVEUO(JEXNUM(PCHNO2//'.PRNO',IBID),'L',IPRN2)
      CALL JEVEUO(PCHNO1//'.NUEQ','L',INUEQ1)
      CALL JEVEUO(PCHNO2//'.NUEQ','L',INUEQ2)
C
      CALL DISMOI('F','NOM_MAILLA',CN1,'CHAM_NO',IBID,MA,IERD)
      CALL DISMOI('F','NB_NO_MAILLA',MA,'MAILLAGE',NBNO,REPK,IERD)
C
      CALL DISMOI('F','NB_EC',GD1,'GRANDEUR',NEC,REPK,IERD)

C NOMBRE DE NOEUDS A AFFECTER

      NBNAFF = 0
      DO 10, INO1 =1,NBNO
         NCMP1= ZI(IPRN1-1+ (INO1-1)* (NEC+2)+2)
         IF (NCMP1.EQ.0) GOTO 10
         IVAL1 = ZI(IPRN1-1+ (INO1-1)* (NEC+2)+1)
         IEQ1  = ZI(INUEQ1-1+IVAL1-1+1)
         VAL = ZR(IAVAL1-1+IEQ1)
         IF (ABS(VAL).LT.TMIN) NBNAFF=NBNAFF+1
10    CONTINUE


C
      NBNRCP = 0
      DO 1, INO2=1,NBNO

        IVAL2 = ZI(IPRN2-1+ (INO2-1)* (NEC+2)+1)
        NCMP2 = ZI(IPRN2-1+ (INO2-1)* (NEC+2)+2)
        IEQ2  = ZI(INUEQ2-1+IVAL2-1+1)

        IF (NCMP2.EQ.0) GO TO 1

        CALL ANTECE(INO2,MA,TGEOM,TAILMI,EPSI,NBANTE,INO1)


        IF (NBANTE.GT.1) THEN

            CALL U2MESS('F','CALCULEL2_7')

        ELSE

           IF (NBANTE.EQ.0) THEN


              ZR(IAVAL2-1+IEQ2)=0.0D0


           ELSE

            IF (NBANTE.EQ.1) THEN


                   IVAL1 = ZI(IPRN1-1+ (INO1-1)* (NEC+2)+1)
                   NCMP1 = ZI(IPRN1-1+ (INO1-1)* (NEC+2)+2)
                   IEQ1  = ZI(INUEQ1-1+IVAL1-1+1)
                   VAL = ZR(IAVAL1-1+IEQ1)

                   IF(ABS(VAL).GT.TMIN) THEN
                     ZR(IAVAL2-1+IEQ2)=VAL
                     NBNRCP = NBNRCP+1
                   ELSE
                     ZR(IAVAL2-1+IEQ2)=0.0D0
                   ENDIF


           ENDIF

          ENDIF
        ENDIF


 1    CONTINUE

      IF ((NBNRCP.LT.NBNAFF).AND.(NBNRCP.GT.(NBNAFF/2))) THEN

       CALL CODENT((NBNAFF-NBNRCP),'D0',DIFF(1:8))
       CALL CODENT((NBNAFF),'D0',CHNAFF(1:8))

        VALK(1) = DIFF
        VALK(2) = CHNAFF
        CALL U2MESK('A','CALCULEL2_8', 2 ,VALK)

      ELSE
        IF (NBNRCP.LT.(NBNAFF/2)) THEN

          CALL U2MESS('A','CALCULEL2_9')
        ENDIF

      ENDIF


      IF (NBNRCP.GT.NBNAFF) THEN

          CALL U2MESS('F','CALCULEL2_10')

      ENDIF

C
C
      CALL JEDEMA()
      END
