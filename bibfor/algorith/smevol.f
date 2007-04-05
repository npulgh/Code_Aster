      SUBROUTINE SMEVOL(TEMPER,MODELZ,MATE,COMPOR,OPTION,PHASIN,NUMPHA)
      IMPLICIT  NONE
      INTEGER           NUMPHA
      CHARACTER*8       TEMPER
      CHARACTER*16      OPTION
      CHARACTER*24      MATE, COMPOR, PHASIN
      CHARACTER*(*)     MODELZ
C MODIF ALGORITH  DATE 06/04/2007   AUTEUR PELLET J.PELLET 
C ======================================================================
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
C (AT YOUR OPTION) ANY LATER VERSION.

C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.

C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C ......................................................................
C     OPTION: META_ELGA_TEMP    DES COMMANDES:   THER_LINEAIRE
C             META_ELNO_TEMP                  ET THER_NON_LINE
C                          ET APPEL A CALCUL
C ......................................................................
C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------

      INTEGER         ZI
      COMMON /IVARJE/ ZI(1)
      REAL*8          ZR
      COMMON /RVARJE/ ZR(1)
      COMPLEX*16      ZC
      COMMON /CVARJE/ ZC(1)
      LOGICAL         ZL
      COMMON /LVARJE/ ZL(1)
      CHARACTER*8     ZK8
      CHARACTER*16            ZK16
      CHARACTER*24                     ZK24
      CHARACTER*32                              ZK32
      CHARACTER*80                                       ZK80
      COMMON /KVARJE/ ZK8(1), ZK16(1), ZK24(1), ZK32(1), ZK80(1)
      CHARACTER*32    JEXNOM, JEXNUM

C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------

      INTEGER       NBHIST, IADTRC(2), LONG, JORDR, NBORDR, I, IRET,
     +              VALI(2), IAD, IFM, IUNIFI, JMATE, IBID,NUM0, NUM1,
     +              NUM2, NUM3, IORD, IAINST, NUMPHI
      REAL*8        R8B, TIME(6), INST0,INST1,INST2, DT3, R8PREM,R8VIDE
      REAL*8        VALR(2)
      INTEGER       VALII
      COMPLEX*16    CBID
      CHARACTER*2   CODRET, TEST
      CHARACTER*8   K8B, MODELE, NOMCM2(2), MATER, TIMCMP(6), LPAIN(8),
     +              LPAOUT(2)
      CHARACTER*16  OPTIO2
      CHARACTER*19  SDTEMP
      CHARACTER*24  CH24, LIGRMO, TEMPE, TEMPA, NOMCH, CHTIME, KORDRE,
     +              LCHIN(8), LCHOUT(2), CHMATE, TEMPI, CHFTRC

      DATA TIMCMP/ 'INST    ', 'DELTAT  ', 'THETA   ', 'KHI     ',
     &             'R       ', 'RHO     '/
      DATA TIME   / 6*0.D0 /
      DATA NOMCM2 / 'I1  ', 'I2  ' /
C     ------------------------------------------------------------------

      CALL JEMARQ()
      MODELE = MODELZ
      IFM = IUNIFI('MESSAGE')
C
C --- RECUPERATION DE LA STRUCTURE DE DONNEES MATERIAU
C
      CH24 = MATE(1:8)//'.CHAMP_MAT'
      CHMATE = MATE(1:8)//'.MATE_CODE'
      CALL JEVEUO(CH24(1:19)//'.VALE','E',JMATE)
      CALL JELIRA(CH24(1:19)//'.VALE','LONMAX',LONG,K8B)
      LIGRMO = MODELE//'.MODELE'

      NBHIST = 0
C        TEST ='NO'
      IADTRC(1) = 0.D0
      IADTRC(2) = 0.D0

      DO 10 I = 1,LONG
        MATER = ZK8(JMATE+I-1)
        IF (MATER.NE.'        ') THEN
          CALL RCADME(MATER,'META_ACIER','TRC',IADTRC,CODRET,' ')
          IF (CODRET.EQ.'OK') TEST = 'OK'
          NBHIST = MAX(NBHIST,IADTRC(1))
        END IF
   10 CONTINUE

      IF (TEST.EQ.'OK') THEN
        CALL WKVECT('&&SMEVOL_FTRC','V V R', 9*NBHIST,VALI(1))
        CALL WKVECT('&&SMEVOL_TRC' ,'V V R',15*NBHIST,VALI(2))
        CHFTRC = '&&SMEVOL.ADRESSES'
        CALL MECACT('V',CHFTRC,'MODELE',LIGRMO,'ADRSJEVN',2,NOMCM2,VALI,
     &              R8B,CBID,K8B)
      ELSE
        CHFTRC = ' '
      END IF

C --- RECUPERATION DES PAS DE TEMPS DE LA STRUCTURE DE DONNEES EVOL_THER

      SDTEMP = TEMPER
      KORDRE = '&&SMEVOL.NUMEORDR'
      CALL RSORAC(SDTEMP,'LONUTI',IBID,R8B,K8B,CBID,R8B,K8B,NBORDR,1,
     &            IBID)
      CALL WKVECT(KORDRE,'V V I',NBORDR,JORDR)
      CALL RSORAC(SDTEMP,'TOUT_ORDRE',IBID,R8B,K8B,CBID,R8B,K8B,
     &            ZI(JORDR),NBORDR,IBID)

C CREATION CHAM_ELEM COMPOR DONNANT NOMBRE DE VARIABLE INTERNE ET
C CONSIDERE VIA LCHOUT COMME UNE DONNEE ENTREE DE CALCUL

      CALL DETRSD('CHAM_ELEM_S',COMPOR)
      CALL CESVAR(' ',COMPOR,LIGRMO,COMPOR)

C --- SI NUMPHA = 0
C --- RECUPERATION DU CHAMP INITIAL (PAS 0 ET 1) DE METALLURGIE
C --- TRANSFORMATION DE LA CARTE EN CHAM_ELEM
C --- ET STOCKAGE DU CHAMP INITIAL DANS LA S D EVOL_THER (PAS 0 ET 1)

      IF (NUMPHA.EQ.0) THEN
        NUMPHI=1
        
C NUME_ORDRE = 0
C ----------------        
        NUM0 = ZI(JORDR)
        CALL RSEXCH ( TEMPER, 'TEMP', NUM0, TEMPE, IRET )
        IF (IRET.GT.0) THEN
          VALII = NUM0
          CALL U2MESG('F', 'ALGORITH14_55',0,' ',1,VALII,0,0.D0)
        END IF
        CALL RSADPA ( TEMPER,'L',1,'INST',NUM0,0,IAINST,K8B)
        INST0 = ZR(IAINST)
        LPAIN(1) = 'PMATERC'
        LCHIN(1) = CHMATE
        LPAIN(2) = 'PCOMPOR'
        LCHIN(2) = COMPOR
        LPAIN(3) = 'PTEMPER'
        LCHIN(3) = TEMPE
        LPAIN(4) = 'PPHASIN'
        LCHIN(4) = PHASIN

C INITIALISATION AVEC 'META_INIT_ELNO'
C
        OPTIO2 = 'META_INIT_ELNO'
        LPAOUT(1) = 'PPHASNOU'
        LCHOUT(1) = '&&SMEVOL.PHAS_META1'
 
        CALL COPISD('CHAM_ELEM_S','V',COMPOR,LCHOUT(1))
        CALL CALCUL('S',OPTIO2,LIGRMO,4,LCHIN,LPAIN,2,LCHOUT,LPAOUT,
     &                'V')
 
        CALL RSEXCH(TEMPER,'META_ELNO_TEMP',NUM0,NOMCH,IRET)
        CALL COPISD('CHAMP_GD','G','&&SMEVOL.PHAS_META1',NOMCH(1:19))
        CALL RSNOCH(TEMPER,'META_ELNO_TEMP',NUM0,' ')
        WRITE(IFM,1010) 'META_ELNO_TEMP', NUM0, INST0
        
C NUME_ORDRE = 1
C ----------------
        NUM1 = ZI(JORDR+1)
        CALL RSEXCH ( TEMPER,'TEMP', NUM1,TEMPE,IRET)
        IF (IRET.GT.0) THEN
          VALII = NUM1
          CALL U2MESG('F', 'ALGORITH14_55',0,' ',1,VALII,0,0.D0)
        END IF
        CALL RSADPA ( TEMPER,'L',1,'INST',NUM1,0,IAINST,K8B)
        INST1 = ZR(IAINST)

        LPAIN(1) = 'PMATERC'
        LCHIN(1) = CHMATE
        LPAIN(2) = 'PCOMPOR'
        LCHIN(2) = COMPOR
        LPAIN(3) = 'PTEMPER'
        LCHIN(3) = TEMPE
        LPAIN(4) = 'PPHASIN'
        LCHIN(4) = PHASIN
        
C INITIALISATION AVEC 'META_INIT_ELNO'
C        
        OPTIO2 = 'META_INIT_ELNO'
        LPAOUT(1) = 'PPHASNOU'
        LCHOUT(1) = '&&SMEVOL.PHAS_META1'

        CALL COPISD('CHAM_ELEM_S','V',COMPOR,LCHOUT(1))
        CALL CALCUL('S',OPTIO2,LIGRMO,4,LCHIN,LPAIN,1,LCHOUT,LPAOUT,
     &                'V')

        CALL RSEXCH ( TEMPER, 'META_ELNO_TEMP', NUM1, NOMCH, IRET )
        CALL COPISD('CHAMP_GD','G','&&SMEVOL.PHAS_META1',NOMCH(1:19))
        CALL RSNOCH ( TEMPER, 'META_ELNO_TEMP', NUM1, ' ' )
        WRITE(IFM,1010) 'META_ELNO_TEMP', NUM1, INST1

      ELSE
        NUMPHI=0
        DO 18 IORD = 2 , NBORDR
          IF (ZI(JORDR+IORD-1).EQ.NUMPHA) NUMPHI=IORD-1
   18   CONTINUE
      END IF

C --- BOUCLE SUR LES PAS DE TEMPS DU CHAMP DE TEMPERATURE

      DO 20 IORD = 1 , NBORDR - 2
C
        IF ( ZI(JORDR+IORD-1) .LT. ZI(JORDR+NUMPHI-1) ) GOTO 20
C
        NUM1 = ZI(JORDR+IORD-1)
        NUM2 = ZI(JORDR+IORD  )
        NUM3 = ZI(JORDR+IORD+1)
C
        CALL RSEXCH ( TEMPER, 'TEMP', NUM1, TEMPA, IRET )
        IF (IRET.GT.0) THEN
          VALII = NUM1
          CALL U2MESG('F', 'ALGORITH14_55',0,' ',1,VALII,0,0.D0)
        END IF
        CALL RSEXCH ( TEMPER, 'TEMP', NUM2, TEMPE, IRET )
        IF (IRET.GT.0) THEN
          VALII = NUM2
          CALL U2MESG('F', 'ALGORITH14_55',0,' ',1,VALII,0,0.D0)
        END IF
        CALL RSEXCH ( TEMPER, 'META_ELNO_TEMP', NUM2, PHASIN, IRET )
        IF (IRET.GT.0) THEN
          VALII = NUM2
          CALL U2MESG('F', 'ALGORITH14_59',0,' ',1,VALII,0,0.D0)
        END IF
        CALL RSEXCH ( TEMPER, 'TEMP', NUM3, TEMPI, IRET )
        IF (IRET.GT.0) THEN
          VALII = NUM3
          CALL U2MESG('F', 'ALGORITH14_55',0,' ',1,VALII,0,0.D0)
        END IF

C --- RECUPERATION DE L'INSTANT DE CALCUL ET DES DELTAT -> CHAMP(INST_R)
C
        CALL RSADPA(SDTEMP,'L',1,'INST',NUM1,0,IAINST,K8B)
        INST0 = ZR(IAINST)
C
        CALL RSADPA(SDTEMP,'L',1,'INST',NUM2,0,IAINST,K8B)
        INST1 = ZR(IAINST)
C
        CALL RSADPA(SDTEMP,'L',1,'INST',NUM3,0,IAINST,K8B)
        INST2 = ZR(IAINST)
C
        TIME(1) = INST1
        TIME(2) = INST1 - INST0
        TIME(3) = INST2 - INST1
C
        CALL JENONU(JEXNOM(SDTEMP//'.NOVA','DELTAT'),IAD)
        IF (IAD.NE.0) THEN
          CALL RSADPA ( SDTEMP, 'L', 1, 'DELTAT', NUM3, 0, IAD, K8B )
          DT3 = ZR(IAD)
          IF (DT3.NE.R8VIDE()) THEN
          IF ( ABS(DT3-TIME(3)) .GT. R8PREM() ) THEN
            VALII = NUM3
            VALR (1) = DT3
            VALR (2) = TIME(3)
            CALL U2MESG('A', 'ALGORITH14_61',0,' ',1,VALII,2,VALR)
          ENDIF
          ENDIF
        ENDIF
C
        CHTIME = '&&SMEVOL.CH_INST_R'
        CALL MECACT('V',CHTIME,'MODELE',LIGRMO,'INST_R  ',6,TIMCMP,IBID,
     &              TIME,CBID,K8B)

C CALCUL DE META_ELNO_TEMP
C ------------------------

        LPAOUT(1) = 'PPHASNOU'
        LCHOUT(1) = '&&SMEVOL.PHAS_META3'

        LPAIN(1) = 'PMATERC'
        LCHIN(1) = CHMATE
        LPAIN(2) = 'PCOMPOR'
        LCHIN(2) = COMPOR
        LPAIN(3) = 'PTEMPAR'
        LCHIN(3) = TEMPA
        LPAIN(4) = 'PTEMPER'
        LCHIN(4) = TEMPE
        LPAIN(5) = 'PTEMPIR'
        LCHIN(5) = TEMPI
        LPAIN(6) = 'PTEMPSR'
        LCHIN(6) = CHTIME
        LPAIN(7) = 'PPHASIN'
        LCHIN(7) = PHASIN
        LPAIN(8) = 'PFTRC'
        LCHIN(8) = CHFTRC

        CALL COPISD('CHAM_ELEM_S','V',COMPOR,LCHOUT(1))
        CALL CALCUL('S',OPTION,LIGRMO,8,LCHIN,LPAIN,1,LCHOUT,LPAOUT,
     &              'V')

C ----- STOCKAGE DU CHAMP DANS LA S D EVOL_THER

        CALL RSEXCH ( TEMPER, 'META_ELNO_TEMP', NUM3, NOMCH, IRET )
        CALL COPISD('CHAMP_GD','G','&&SMEVOL.PHAS_META3',NOMCH(1:19))
        CALL RSNOCH ( TEMPER, 'META_ELNO_TEMP', NUM3, ' ' )
        WRITE(IFM,1010) 'META_ELNO_TEMP', NUM3, INST2

   20 CONTINUE

      CALL JEDETC(' ','&&SMEVOL',1)

C
 1010 FORMAT (1P,3X,'CHAMP    STOCKE   :',1X,A14,' NUME_ORDRE:',I8,
     >       ' INSTANT:',D12.5)
C
      CALL JEDEMA()
      END
