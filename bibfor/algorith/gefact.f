      SUBROUTINE GEFACT (DUREE,NOMINF)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 03/09/2012   AUTEUR ANDRIAM H.ANDRIAMBOLOLONA 
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
C ----------------------------------------------------------------------
C
C GENERATION DE FCT ALEATOIRES :
C        - PREPARATION (DISCRETISATION-PROLONGEMENT) DE L INTERSPECTRE
C            (EN FONCTION DES CARACTERISTIQUES DU TEMPOREL A GENERER)
C        - FACTORISATION DE L INTERSPECTRE
C
C ----------------------------------------------------------------------
C
C      IN   :
C             DUREE : DUREE DU TEMPOREL A SIMULER (NEGATIVE SI ELLE
C                     N'EST PAS UNE DONNEE)
C      OUT  :
C             NOMINF : NOM DE L'INTERSPECTRE FACTORISE
C
C ----------------------------------------------------------------------
C
C
      IMPLICIT NONE
C
C 0.1. ==> ARGUMENTS
C
      INCLUDE 'jeveux.h'
      REAL*8        DUREE

C
C 0.2. ==> COMMUNS
C
C 0.3. ==> VARIABLES LOCALES
C
C
      INTEGER      L, N1, NBPOIN, NBPINI, IRET, IER
      INTEGER      DIM, LONG, DIM2, DIM3, DIM4
      INTEGER      NNN, NBMR, NBPT1, NBPT2, LONGH
      INTEGER      NBFC, NBVAL,NBVAL1,INDICE
      INTEGER      I, II, JJ, J, K, KF, LVAL2, LVALC, IPAS
      INTEGER      IINF, ISUP, LS, LR, LD, LU, LV, LW, IX, IY
      INTEGER      LVAL, LVAL1, LCHDES, INUOR, LNUOR, JNUOR
      INTEGER VALI

      REAL*8       PREC,R8B,EPSI
      REAL*8       FREQI, FREQF, FREQ, FRINIT, FMAX, FMIN
      REAL*8       PMIN, DFREQ, DIFPAS, DT
      REAL*8       PAS, PAS1,RESURE, RESUIM,X1,Y1,X2,Y2,R8PREM
      REAL*8       PUI2, PUI2D, PUI3D
      REAL*8 VALR

      CHARACTER*1  COLI
      CHARACTER*3  INTERP
      CHARACTER*8  K8B,INTESP
      CHARACTER*16 K16BID, NOMCMD,PROLGD
      CHARACTER*19 K19BID, NOMINF, NOMINT
      CHARACTER*24 CHVALE, CHDESC, CHNUOR,NOMOBJ
      CHARACTER*24  CHNUMI,CHNUMJ,CHFREQ,CHVAL
      LOGICAL       LFREQF, LFREQI, LNBPN, LINTER, LPREM,DIAG
      INTEGER      IARG
      INTEGER I1,LNUMI,LNUMJ,LFREQ,NBFREQ
C
C     ----------------------------------------------------------------
C     --- INITIALISATION  ---
C
      CALL JEMARQ()
C
      CALL GETRES ( K19BID, K16BID, NOMCMD )

C===============
C 1. LECTURE DES DONNEES LIEES A L INTERSPECTRE ET VERIFS
C===============

      CALL GETVID (' ', 'INTE_SPEC'     , 1,IARG,1, NOMINT, L )

      CALL GETVTX ( ' ', 'INTERPOL'   , 1,IARG,2, INTERP     , N1 )
      LINTER = (INTERP.EQ.'NON')

      CALL GETVIS ( ' ', 'NB_POIN', 0,IARG,1, NBPOIN, L )
      LNBPN = L .NE. 0
      NBPINI = NBPOIN
C
C=====
C  1.1  RECUPARATION DES DIMENSIONS, DES NUMEROS D'ORDRE, ...
C=====
      INTESP = NOMINT(1:8)
      CHNUMI = INTESP//'.NUMI'
      CHNUMJ = INTESP//'.NUMJ'
      CHFREQ = INTESP//'.FREQ'
      CHVAL = INTESP//'.VALE'
      CALL JEVEUO(CHNUMI,'L',LNUMI)
      CALL JEVEUO(CHNUMJ,'L',LNUMJ)
      CALL JEVEUO(CHFREQ,'L',LFREQ)
      CALL JELIRA(CHNUMI,'LONMAX',NBMR,K8B)
      CALL JELIRA(CHFREQ,'LONMAX',NBFREQ,K8B)

      NOMOBJ = '&&GEFACT.TEMP.NUOR'
      CALL WKVECT ( NOMOBJ, 'V V I', NBMR, JNUOR )
      DO 150 I1 = 1,NBMR
        ZI(JNUOR-1+I1) = ZI(LNUMI-1+I1)
150   CONTINUE
      CALL ORDIS  ( ZI(JNUOR) , NBMR )
      CALL WKVECT ( '&&GEFACT.MODE', 'V V I', NBMR, INUOR )
      NNN = 1
      ZI(INUOR) = ZI(JNUOR)
      DO 10 I = 2 , NBMR
         IF ( ZI(JNUOR+I-1) .EQ. ZI(INUOR+NNN-1) ) GOTO 10
         NNN = NNN + 1
         ZI(INUOR+NNN-1) = ZI(JNUOR+I-1)
 10   CONTINUE
C
C=====
C 1.2 DONNEES ECHANTILLONNAGE FREQUENTIEL, DEDUCTION DES DONNEES
C     MANQUANTES (POUR RESPECTER ENTRE AUTRE LE TH. DE SHANNON)
C=====
        DIM = NNN
        NBFC = DIM * ( DIM + 1 ) / 2
        CALL ASSERT(NBFC.EQ.NBMR)

C 1.2.1 CAS OU ON UTILISE LA DISCRETISATION DE L INTERSPECTRE :
C     VERIFICATION DE LA COHERENCE DE LA DISCRETISATION DES FONCTIONS
C     DANS LE CAS OU CETTE DISCRETISATION EST CONSERVEE
      IF (LINTER) THEN
        NBVAL = NBFREQ
        PAS = (ZR(LFREQ+NBVAL-1)-ZR(LFREQ))/ (NBVAL-1)
        PREC = 1.D-06
        DO 100 II = 1,NBVAL-1
          PAS1 = ZR(LFREQ+II) - ZR(LFREQ+II-1)
          DIFPAS = ABS(PAS1-PAS)
          IF (DIFPAS.GT.PREC) THEN
            CALL U2MESS('F','ALGORITH3_78')
          ENDIF
  100   CONTINUE

        IF (( LNBPN ).AND.(NBPINI.LT.NBVAL)) THEN
          FREQF =  ZR(LFREQ+NBPINI-1)
          VALR = FREQF
          CALL U2MESG('A','ALGORITH15_11',0,' ',0,0,1,VALR)
        ELSE
          FREQF =  ZR(LFREQ+NBVAL-1)
        ENDIF
        DFREQ = PAS
        DUREE = 1.D0 / DFREQ
        FREQI = ZR(LFREQ)
        FRINIT = FREQI

        NBPOIN = 2**(INT(LOG(FREQF/DFREQ)/LOG(2.D0))+1)
        IF (LNBPN) THEN
          IF (NBPOIN.GT.NBPINI ) THEN
        VALI = NBPOIN
        R8B = 0.D0
        CALL U2MESG('A','ALGORITH15_12',0,' ',1,VALI,0,R8B)
          ELSE
            PUI2  = LOG(DBLE(NBPINI))/LOG(2.D0)
            PUI2D = ABS( PUI2 - AINT( PUI2 ))
            PUI3D = ABS( 1.D0 - PUI2D )
            IF (PUI2D.GE.1.D-06 .AND. PUI3D.GE.1.D-06) THEN
              NBPOIN = 2**(INT(PUI2)+1)
              CALL U2MESS('A','ALGORITH3_80')
            ENDIF
          ENDIF
        ENDIF

      ELSE
C 1.2.2 CAS OU ON PEUT INTERPOLER L INTERSPECTRE

        CALL GETVR8(' ','FREQ_FIN',0,IARG,1,FREQF,L)
        LFREQF = L .NE. 0
C
        CALL GETVR8(' ','FREQ_INIT',0,IARG,1,FREQI,L)
        LFREQI = L .NE. 0

C      RECHERCHE DES FREQUENCES MIN ET MAX ET DU PAS EN FREQUENCE MIN
C      DE L INTERSPECTRE
        PMIN=1.D+10
        FMAX = 0.D0
        FMIN = 1.D+10
          NBVAL = NBFREQ
          DO 35 J = 1,NBVAL-1
            PAS= ABS(ZR(LFREQ+J) - ZR(LFREQ+J-1))
            IF (PAS .LT. PMIN ) PMIN = PAS
   35     CONTINUE
          FREQ = ZR(LFREQ+NBVAL-1)
          IF (FREQ .GT. FMAX ) FMAX = FREQ
          FREQ = ZR(LFREQ)
          IF (FREQ .LT. FMIN ) FMIN = FREQ

        IF ( .NOT.  LFREQF)  FREQF = FMAX
        IF ( .NOT.  LFREQI)  FREQI = FMIN

C     DETERMINATION DES PARAMETRES DE L ALGO.
        IF (DUREE .GT. 0.D0) THEN
C     LA DUREE EST UNE DONNEE
          DFREQ = 1.D0 / DUREE
          IF ( LNBPN ) THEN
            DT = DUREE/NBPOIN/2.D0
            IF (1.D0/DT . LT. 2.D0*FREQF) THEN
              NBPOIN = 2**(INT(LOG(2.D0*FREQF*DUREE)/LOG(2.D0)))
              VALI = NBPOIN
              R8B = 0.D0
              CALL U2MESG('A','ALGORITH15_13',0,' ',1,VALI,0,R8B)
            ENDIF
          ELSE
            NBPOIN = 2**(INT(LOG(2.D0*FREQF*DUREE)/LOG(2.D0)))
            IF (( DFREQ. GT. 2*PMIN).AND. (PMIN.GT.0.D0) ) THEN
             VALR = 1.D0/PMIN
             CALL U2MESG('A','ALGORITH15_14',0,' ',0,0,1,VALR)
            ENDIF
          ENDIF
        ELSE
C     LA DUREE EST UNE INCONNUE
          IF ( LNBPN ) THEN
            PUI2  = LOG(DBLE(NBPOIN))/LOG(2.D0)
            PUI2D = ABS( PUI2 - AINT( PUI2 ))
            PUI3D = ABS( 1.D0 - PUI2D )
            IF (PUI2D.GE.1.D-06 .AND. PUI3D.GE.1.D-06) THEN
              CALL U2MESS('A','ALGORITH3_80')
              NBPOIN = 2**(INT(PUI2)+1)
            ENDIF
             DFREQ=FREQF/(NBPOIN-1)
             FRINIT = FREQF - DBLE(NBPOIN)*DFREQ
             IF (FRINIT . LT. 0.D0) FRINIT =0.D0
             IF ((DFREQ . GT. PMIN ).AND. (PMIN.GT.0.D0)) THEN
              VALI = NBPOIN
              VALR = (FREQF-FREQI)/PMIN+1
              CALL U2MESG('A','ALGORITH15_15',0,' ',1,VALI,1,VALR)
            ENDIF
          ELSE
            IF (PMIN.GT.0.D0) THEN
              DFREQ=PMIN
              NBPOIN = 2**(INT(LOG(2.D0*FREQF/PMIN)/LOG(2.D0)))
              IF ( NBPOIN .LT. 256 ) NBPOIN =256
            ELSE
              NBPOIN =256
              DFREQ = (FREQF-FREQI)/DBLE(NBPOIN-1)
            ENDIF
          ENDIF
          DUREE = 1.D0 / DFREQ
        ENDIF

        IF (DBLE(NBPOIN-1)*DFREQ .GT. (FREQF-FREQI)) THEN
          FRINIT = FREQF - DBLE(NBPOIN)*DFREQ
          IF (FRINIT . LT. 0.D0) FRINIT =0.D0
        ELSE
          FRINIT = FREQI
        ENDIF
      ENDIF

C
C===============
C 3. LECTURE DES VALEURS DES FONCTIONS ET/OU INTERPOLATION-PROLONGEMENT
C===============

      NBPT1 = NBPOIN
      NBPT2 = NBPOIN*2
      LONG  = NBFC*NBPT2 + NBPT1
      LONGH = DIM*DIM*NBPT2 + NBPT1
C
C     --- CREATION D'UN VECTEUR TEMP.VALE POUR STOCKER LES VALEURS
C           DES FONCTIONS  ---
C
      CALL WKVECT('&&GEFACT.TEMP.VALE','V V R',LONG,LVAL)

C
C     --- ON STOCKE LES FREQUENCES ET ON RECHERCHE LES INDICES AU
C         DE LA DES QUELLES LA MATRICE EST NULLE---
      LPREM = .TRUE.
      IINF = 0
      ISUP = NBPT1+1
      DO 70 K = 1,NBPT1
        FREQ = FRINIT + (K-1)*DFREQ
        ZR(LVAL+K-1) = FREQ
        IF (FREQ.LT.FREQI) IINF= K
        IF ((FREQ.GT.FREQF) .AND. LPREM) THEN
          ISUP = K
          LPREM = .FALSE.
        ENDIF
   70 CONTINUE
      LVAL1 = LVAL + NBPT1
C
C     --- POUR CHAQUE FONCTION CALCUL DE X,Y POUR CHAQUE FREQ.
C     (ON PROLONGE PAR 0 EN DEHORS DE (FREQI,FREQF)), PUIS ON STOCKE ---

      DO 80 KF = 1,NBFC
        CALL JEVEUO(JEXNUM(CHVAL,KF),'L',LVAL2)
        DIAG = .FALSE.
        IF (ZI(LNUMI-1+KF) .EQ. ZI(LNUMJ-1+KF)) DIAG = .TRUE.

        K8B = ' '
        DO 120 IPAS = 1,NBPT1
          FREQ = FRINIT + (IPAS-1)*DFREQ
          IX = LVAL1 + (KF-1)*NBPT2 + IPAS - 1
          IY = LVAL1 + (KF-1)*NBPT2 + IPAS - 1 + NBPT1
          IF ((IPAS.LE.IINF) .OR. (IPAS.GE.ISUP)) THEN
            ZR(IX) = 0.D0
            ZR(IY) = 0.D0
          ELSE
            IF (LINTER) THEN
              IF (DIAG) THEN
                RESURE = ZR(LVAL2+IPAS-1)
                RESUIM = 0.D0
              ELSE
                RESURE = ZR(LVAL2+2*(IPAS-1))
                RESUIM = ZR(LVAL2+2*(IPAS-1)+1)
              ENDIF
            ELSE
C ON INTERPOLLE
              PROLGD = 'CC      '
              EPSI   = SQRT ( R8PREM() )
              CALL FOLOCX(ZR(LFREQ),NBFREQ,FREQ,PROLGD,
     &                    INDICE,EPSI,COLI,IER)
              IF (COLI.EQ.'C') THEN
                IF (DIAG) THEN
                  RESURE=ZR(LVAL2+INDICE-1)
                  RESUIM = 0.D0
                ELSE
                  RESURE=ZR(LVAL2+2*(INDICE-1))
                  RESUIM=ZR(LVAL2+2*(INDICE-1)+1)
                ENDIF
              ELSE IF ((COLI.EQ.'I') .OR. (COLI.EQ.'E')) THEN
                X1 = ZR(LFREQ+INDICE-1)
                X2 = ZR(LFREQ+INDICE)
                IF (DIAG) THEN
                  Y1 = ZR(LVAL2+INDICE-1)
                  Y2 = ZR(LVAL2+INDICE)
                  RESURE= Y1+(FREQ-X1)*(Y2-Y1)/(X2-X1)
                  RESUIM = 0.D0
                ELSE
                  Y1 = ZR(LVAL2+2*(INDICE-1))
                  Y2 = ZR(LVAL2+2*INDICE)
                  RESURE= Y1+(FREQ-X1)*(Y2-Y1)/(X2-X1)
                  Y1 = ZR(LVAL2+2*(INDICE-1)+1)
                  Y2 = ZR(LVAL2+2*INDICE+1)
                  RESUIM= Y1+(FREQ-X1)*(Y2-Y1)/(X2-X1)
                ENDIF
              ELSE
                CALL U2MESK('A','PREPOST3_6',1,COLI)
              ENDIF
            ENDIF
            ZR(IX) = RESURE
            ZR(IY) = RESUIM
          ENDIF
  120   CONTINUE
   80 CONTINUE
      NBVAL1 = NBPT1

C===============
C 4. FACTORISATION DES MATRICES INTERSPECTRALES (UNE PAR FREQ.)
C===============

C               1234567890123456789
      NOMINF = '&&INTESPECFACT     '
C
C     --- CREATION DE L'OBJET NOMINF//'.VALE'
      CHVALE = NOMINF//'.VALE'
      CALL WKVECT(CHVALE,'V V R',LONGH,LVALC)
C
C     --- CREATION DE L'OBJET NOMINF//'.DESC'
      CHDESC = NOMINF//'.DESC'
      CALL WKVECT(CHDESC,'V V I',3,LCHDES)
      ZI(LCHDES) = NBVAL1
      ZI(LCHDES+1) = DIM
      ZI(LCHDES+2) = DIM*DIM
C
C     --- CREATION DE L'OBJET NOMINF//'.NUOR'
      CHNUOR = NOMINF//'.NUOR'
      CALL WKVECT(CHNUOR,'V V I',DIM,LNUOR)
      CALL JEVEUO('&&GEFACT.MODE','L',INUOR)
      DO 125 I=1,DIM
        ZI(LNUOR-1+I) = ZI(INUOR-1+I)
  125 CONTINUE
C
      DIM2 = DIM*DIM
      DIM3 = DIM2 + DIM
      DIM4 = 2*DIM
      CALL WKVECT('&&GEFACT.TEMP.VALS','V V C',DIM2,LS)
      CALL WKVECT('&&GEFACT.TEMP.VALR','V V C',DIM2,LR)
      CALL WKVECT('&&GEFACT.TEMP.VALD','V V R',DIM,LD)
      CALL WKVECT('&&GEFACT.TEMP.VALU','V V C',DIM2,LU)
      CALL WKVECT('&&GEFACT.TEMP.VALV','V V R',DIM3,LV)
      CALL WKVECT('&&GEFACT.TEMP.VALW','V V C',DIM4,LW)
C
      CALL FACINT(NBVAL1,DIM,LONGH,ZR(LVAL),ZR(LVALC),LONG,ZC(LS),
     &            ZC(LR),ZR(LD),ZC(LU),ZR(LV),ZC(LW))
C
      NBPT1 = NBVAL1
      DO 130 JJ = 1,NBPT1
        ZR(LVALC+JJ-1) = ZR(LVAL+JJ-1)
  130 CONTINUE
C
      CALL TITRE
C
      CALL JEDETR( '&&GEFACT.MODE' )
      CALL JEDETR( NOMOBJ )
      CALL JEEXIN('&&GEFACT.FONCTION',IRET)
      IF (IRET.NE.0) CALL JEDETR('&&GEFACT.FONCTION')
      CALL JEDETR('&&GEFACT.TEMP.VALE')
      CALL JEDETR('&&GEFACT.TEMP.VALD')
      CALL JEDETR('&&GEFACT.TEMP.VALR')
      CALL JEDETR('&&GEFACT.TEMP.VALS')
      CALL JEDETR('&&GEFACT.TEMP.VALU')
      CALL JEDETR('&&GEFACT.TEMP.VALV')
      CALL JEDETR('&&GEFACT.TEMP.VALW')
      CALL JEDETR('&&GEFACT.TEMP.FONC')
      CALL JEDEMA()
      END
