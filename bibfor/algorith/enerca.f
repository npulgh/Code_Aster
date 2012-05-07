      SUBROUTINE ENERCA (VALINC,DEP0 ,VIT0 ,DEPL1,VITE1,
     &                   MASSE,AMORT,RIGID,FEXTE,FAMOR,FLIAI,FNODA,
     &                   FCINE,LAMORT,LDYNA,LEXPL,SDENER,SCHEMA)
      IMPLICIT NONE
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 07/05/2012   AUTEUR SELLENET N.SELLENET 
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
C RESPONSABLE IDOUX L.IDOUX
C ----------------------------------------------------------------------
C     CALCUL DES ENERGIES
C     DONNEES (IN) :
C     VALINC : NECESSAIRE A LA RECUPERATION DU NOM DES GRANDEURS
C              NODALES DANS MECA_NON_LINE.
C     FEXTE  : TABLEAU DE TAILLE 2*NEQ.
C              LES FORCES EXTERIEURES A L INSTANT N SONT STOCKEES
C              DE 1 A NEQ.
C              LES FORCES EXTERIEURES A L INSTANT N+1 SONT STOCKEES
C              DE NEQ+1 A 2*NEQ.
C     FAMOR  : MEME PRINCIPE. CONTIENT LES FORCES D AMORTISSEMENT
C              MODAL UNIQUEMENT.
C     FLIAI  : MEME PRINCIPE. CONTIENT LES FORCES D IMPEDANCE POUR
C              LES FRONTIERES ABSORBANTES (A ENRICHIR PAR LA SUITE).
C     FNODA  : MEME PRINCIPE. CONTIENT LES FORCES INTERNES.
C     FCINE  : DE DIMENSION NEQ. CONTIENT LES INCREMENTS DE
C              DEPLACEMENT IMPOSE A L INSTANT N.
C     LAMORT : INDIQUE SI UNE MATRICE D AMORTISSEMENT EXISTE.
C              UNIQUEMENT SI AMORTISSEMENT DE RAYLEIGH.
C     LDYNA  : INDIQUE SI LE CALCUL EST DYNAMIQUE. DECLENCHE LA
C              LECTURE DE LA MATRICE MASSE ET DE LA VITESSE,
C              ET LE CALCUL DE ECIN.
C     LEXPL  : INDIQUE SI LE CALCUL EST UN DYNA_NON_LINE EN
C              EXPLICITE (DIFF_CENTRE OU TCHAMWA).
C              LES LAGRANGES SONT ALORS PORTES PAR LA MATRICE MASSE.
C ----------------------------------------------------------------------
C  IN  : VALINC    : VARIABLE CHAPEAU POUR INCREMENTS VARIABLES
C  IN  : DEP0      : TABLEAU DES DEPLACEMENTS A L INSTANT N
C  IN  : VIT0      : TABLEAU DES VITESSES A L INSTANT N
C  IN  : DEPL1     : TABLEAU DES DEPLACEMENTS A L INSTANT N+1
C  IN  : VITE1     : TABLEAU DES VITESSES A L INSTANT N+1
C  IN  : MASSE     : MATRICE DE MASSE
C  IN  : AMORT     : MATRICE D AMORTISSEMENT
C  IN  : RIGID     : MATRICE DE RIGIDITE
C  IN  : FEXTE     : VECTEUR DES FORCES EXTERIEURES
C  IN  : FAMOR     : VECTEUR DES FORCES D AMORTISSEMENT MODAL
C  IN  : FLIAI     : VECTEUR DES FORCES DE LIAISON
C  IN  : FNODA     : VECTEUR DES FORCES NODALES
C  IN  : FCINE     : VECTEUR DES INCREMENTS DE DEPLACEMENT IMPOSE
C  IN  : LAMORT    : LOGICAL .TRUE. SI LA MATRICE AMORTISSEMENT EXISTE
C  IN  : LDYNA     : LOGICAL .TRUE. SI CALCUL DYNAMIQUE
C  IN  : LEXPL     : LOGICAL .TRUE. SI CALCUL EXPLICITE DANS DNL
C  IN  : SDENER    : SD ENERGIE
C  IN  : SCHEMA    : NOM DU SCHEMA POUR DYNA_LINE_TRAN
C
C ----------------------------------------------------------------------
C DECLARATION PARAMETRES D'APPELS
C ----------------------------------------------------------------------
      CHARACTER*19 VALINC(*), MASSE, AMORT, RIGID, SDENER
      REAL*8 DEP0(*), VIT0(*), DEPL1(*), VITE1(*)
      REAL*8 FEXTE(*), FAMOR(*), FLIAI(*), FNODA(*), FCINE(*)
      LOGICAL LAMORT, LDYNA, LEXPL
      CHARACTER*8  SCHEMA
C
C    ----- DEBUT COMMUNS NORMALISES  JEVEUX  ---------------------------
C
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C
C     ----- FIN COMMUNS NORMALISES  JEVEUX  ----------------------------
C
C ----------------------------------------------------------------------
C DECLARATION VARIABLES LOCALES
C ----------------------------------------------------------------------
      INTEGER      IAUX,NEQ,IBID,IE,IRET,NBCOL,LONG
      INTEGER      JDEEQ,JCONL,IMDV,ICVMOZ,IENER
      INTEGER      IMASSE,IAMORT,IRIGID
      INTEGER      IUMOY,IUPMUM,IUMOYZ,IUPMUZ
      INTEGER      IVMOY,IVPMVM,IVMOYZ,IVPMVZ
      INTEGER      IKUMOY,IKUMOZ,IMUMOY,IMUMOZ,IFMOY,IDESC
      CHARACTER*24 NUMEDD
      CHARACTER*19 DEPPLU
      CHARACTER*11 FORMA
      CHARACTER*40 FORMB,FORMC
      REAL*8       COEFL,DDOT
      REAL*8       WINT,WEXT,LIAI,ECIN,AMOR,WSCH

C ----------------------------------------------------------------------
C CORPS DU PROGRAMME
C ----------------------------------------------------------------------

      CALL JEMARQ()

      WINT=0.D0
      WEXT=0.D0
      LIAI=0.D0
      ECIN=0.D0
      AMOR=0.D0
      WSCH=0.D0


      IF (LDYNA) THEN
C ----------------------------------------------------------------------
C CALCUL DYNAMIQUE (DYNA_NON_LINE OU DYNA_LINE_TRAN)
C - RECUPERATION DE LA MATRICE DE MASSE
C - RECUPERATION DE LA MATRICE D AMORTISSEMENT SI ELLE EXISTE
C - CREATION DES VECTEURS DE DEPLACEMENT MOYEN ET D INCREMENT
C   DE DEPLACEMENT
C - CREATION DES VECTEURS DE VITESSE MOYENNE ET D INCREMENT DE VITESSE
C - RECUPERATION DE LA MATRICE DE RIGIDITE SI ELLE PORTE LES LAGRANGE
C ----------------------------------------------------------------------
        CALL JEVEUO(MASSE//'.&INT','L',IMASSE)
        IF (LAMORT) THEN
          CALL JEVEUO(AMORT//'.&INT','L',IAMORT)
        ENDIF
        NEQ=ZI(IMASSE+2)
        IF (.NOT.LEXPL) THEN
          CALL JEVEUO(RIGID//'.&INT','L',IRIGID)
        ENDIF
        CALL WKVECT('&&ENERCA.DESC','V V K8',NEQ,IDESC)
        CALL WKVECT('&&ENERCA.UMOY','V V R',NEQ,IUMOY)
        CALL WKVECT('&&ENERCA.UPMUM','V V R',NEQ,IUPMUM)
        CALL WKVECT('&&ENERCA.UMOYZ','V V R',NEQ,IUMOYZ)
        CALL WKVECT('&&ENERCA.UPMUMZ','V V R',NEQ,IUPMUZ)
        CALL WKVECT('&&ENERCA.VMOY','V V R',NEQ,IVMOY)
        CALL WKVECT('&&ENERCA.VPMVM','V V R',NEQ,IVPMVM)
        CALL WKVECT('&&ENERCA.VMOYZ','V V R',NEQ,IVMOYZ)
        CALL WKVECT('&&ENERCA.VPMVMZ','V V R',NEQ,IVPMVZ)
        DO 10 IAUX=1,NEQ
          ZR(IUMOY-1+IAUX)=(DEPL1(IAUX)+DEP0(IAUX))*5.D-1
          ZR(IUPMUM-1+IAUX)=DEPL1(IAUX)-DEP0(IAUX)
          ZR(IVMOY-1+IAUX)=(VITE1(IAUX)+VIT0(IAUX))*5.D-1
          ZR(IVPMVM-1+IAUX)=VITE1(IAUX)-VIT0(IAUX)
   10   CONTINUE
        CALL DCOPY(NEQ,ZR(IUMOY),1,ZR(IUMOYZ),1)
        CALL DCOPY(NEQ,ZR(IUPMUM),1,ZR(IUPMUZ),1)
        CALL DCOPY(NEQ,ZR(IVMOY),1,ZR(IVMOYZ),1)
        CALL DCOPY(NEQ,ZR(IVPMVM),1,ZR(IVPMVZ),1)
        CALL DISMOI('F','NOM_NUME_DDL',MASSE,
     &              'MATR_ASSE',IBID,NUMEDD,IE)
        CALL JEVEUO(NUMEDD(1:14)//'.NUME.DEEQ','L',JDEEQ)
        IF (SDENER(1:8).EQ.'&&OP0070') THEN
C ON NE GARDE QUE LES DDL NODAUX PHYSIQUES
          CALL NMCHEX(VALINC,'VALINC','DEPPLU',DEPPLU)
        ELSEIF (SDENER(1:8).EQ.'&&OP0048') THEN
          DEPPLU=SCHEMA//'.DEPL1     '
          IF (SCHEMA.EQ.'&&DLADAP') THEN
            DEPPLU=SCHEMA//'.DEP2 '
          ENDIF
        ENDIF
        CALL DDLPHY(DEPPLU,NEQ,ZR(IUPMUZ),ZK8(IDESC))
        CALL DDLPHY(DEPPLU,NEQ,ZR(IVMOYZ),ZK8(IDESC))
        CALL DDLPHY(DEPPLU,NEQ,ZR(IVPMVZ),ZK8(IDESC))
C ON ENLEVE UNIQUEMENT LES LAGRANGES DES CONDITIONS DE DIRICHLET
        CALL ZERLAG(ZR(IUMOYZ),NEQ,ZI(JDEEQ))
      ELSE
C --------------------------------------------------------------------
C CALCUL STATIQUE (STAT_NON_LINE)
C - CREATION DES VECTEURS DE DEPLACEMENT MOYEN ET D INCREMENT
C   DE DEPLACEMENT
C - RECUPERATION DE LA MATRICE DE RIGIDITE POUR OBTENIR LES LAGRANGES
C --------------------------------------------------------------------
        CALL JEVEUO(RIGID//'.&INT','L',IRIGID)
        NEQ=ZI(IRIGID+2)
        CALL WKVECT('&&ENERCA.DESC','V V K8',NEQ,IDESC)
        CALL WKVECT('&&ENERCA.UMOY','V V R',NEQ,IUMOY)
        CALL WKVECT('&&ENERCA.UPMUM','V V R',NEQ,IUPMUM)
        CALL WKVECT('&&ENERCA.UMOYZ','V V R',NEQ,IUMOYZ)
        CALL WKVECT('&&ENERCA.UPMUMZ','V V R',NEQ,IUPMUZ)
        DO 20 IAUX=1,NEQ
          ZR(IUMOY-1+IAUX)=(DEPL1(IAUX)+DEP0(IAUX))*5.D-1
          ZR(IUPMUM-1+IAUX)=DEPL1(IAUX)-DEP0(IAUX)
  20    CONTINUE
        CALL DCOPY(NEQ,ZR(IUMOY),1,ZR(IUMOYZ),1)
        CALL DCOPY(NEQ,ZR(IUPMUM),1,ZR(IUPMUZ),1)
        CALL DISMOI('F','NOM_NUME_DDL',RIGID,
     &              'MATR_ASSE',IBID,NUMEDD,IE)
        CALL JEVEUO(NUMEDD(1:14)//'.NUME.DEEQ','L',JDEEQ)
        CALL NMCHEX(VALINC,'VALINC','DEPPLU',DEPPLU)
C ON NE GARDE QUE LES DDL NODAUX PHYSIQUES
        CALL DDLPHY(DEPPLU,NEQ,ZR(IUPMUZ),ZK8(IDESC))
C ON ENLEVE UNIQUEMENT LES LAGRANGES DES CONDITIONS DE DIRICHLET
        CALL ZERLAG(ZR(IUMOYZ),NEQ,ZI(JDEEQ))
      ENDIF
C --------------------------------------------------------------------
C WINT : TRAVAIL REEL DES EFFORTS CALCULE COMME LE TRAVAIL DES FORCES
C        INTERNES
C - SI DYNA_LINE_TRAN : EGAL A L ENERGIE DE DEFORMATION ELASTIQUE
C - SI MECA_NON_LINE : TRAVAIL DES FORCES INTERNES
C --------------------------------------------------------------------
      CALL WKVECT('&&ENERCA.FMOY','V V R',NEQ,IFMOY)
      IF (SDENER(1:8).EQ.'&&OP0048') THEN
        CALL WKVECT('&&ENERCA.KUMOYZ','V V R  ',NEQ,IKUMOZ)
        CALL MRMULT('ZERO',IRIGID,ZR(IUMOYZ),'R',ZR(IKUMOZ),1)
        WINT=DDOT(NEQ,ZR(IUPMUZ),1,ZR(IKUMOZ),1)
      ELSE
        DO 30 IAUX=1,NEQ
          ZR(IFMOY-1+IAUX)=(FNODA(IAUX)+FNODA(IAUX+NEQ))*5.D-1
  30    CONTINUE
        WINT=DDOT(NEQ,ZR(IUPMUZ),1,ZR(IFMOY),1)
      ENDIF
C --------------------------------------------------------------------
C ECIN : ENERGIE CINETIQUE
C - UNIQUEMENT SI CALCUL DYNAMIQUE
C --------------------------------------------------------------------
      IF (LDYNA) THEN
        CALL WKVECT('&&ENERCA.MDV','V V R  ',NEQ,IMDV)
        CALL MRMULT('ZERO',IMASSE,ZR(IVPMVZ),'R',ZR(IMDV),1)
        ECIN=DDOT(NEQ,ZR(IVMOYZ),1,ZR(IMDV),1)
      ENDIF
C --------------------------------------------------------------------
C WEXT : TRAVAIL DES EFFORTS EXTERIEURS
C --------------------------------------------------------------------
      WEXT=0.D0
C 1. CONTRIBUTION AFFE_CHAR_CINE (MECA_NON_LINE UNIQUEMENT)
      IF (SDENER(1:8).EQ.'&&OP0070') THEN
        WEXT=DDOT(NEQ,ZR(IFMOY),1,FCINE(1),1)
      ENDIF
C 2. CONTRIBUTION DE Bt.LAMBDA (DIRICHLETS) POUR OP0048
      IF (SDENER(1:8).EQ.'&&OP0048') THEN
        IF (LEXPL) THEN
C LAGRANGES PORTES PAR LA MATRICE DE MASSE
          CALL WKVECT('&&ENERCA.MUMOY','V V R',NEQ,IMUMOY)
          CALL WKVECT('&&ENERCA.MUMOYZ','V V R',NEQ,IMUMOZ)
          CALL MRMULT('ZERO',IMASSE,ZR(IUMOY),'R',ZR(IMUMOY),1)
          CALL MRMULT('ZERO',IMASSE,ZR(IUMOYZ),'R',ZR(IMUMOZ),1)
          DO 40 IAUX=1,NEQ
            ZR(IFMOY-1+IAUX)=ZR(IMUMOZ-1+IAUX)-ZR(IMUMOY-1+IAUX)
  40      CONTINUE
          COEFL=1.D0
C ON PEUT NE PAS AVOIR DE BLOCAGE ET NE JAMAIS CALCULER DE LAGRANGE
C NI DE COEFFICIENT DE MISE A L ECHELLE
          CALL JEEXIN(MASSE//'.CONL',IRET)
          IF (IRET.NE.0) THEN
            CALL JEVEUO(MASSE//'.CONL','L',JCONL)
            DO 50 IAUX=1,NEQ
              IF (ZR(JCONL-1+IAUX).GT.1.D0) THEN
                COEFL=ZR(JCONL-1+IAUX)
              ENDIF
  50        CONTINUE
          ENDIF
          WEXT = WEXT + DDOT(NEQ,ZR(IFMOY),1,ZR(IUPMUZ),1)/COEFL
        ELSE
C LAGRANGES PORTES PAR LA MATRICE DE RIGIDITE
          CALL WKVECT('&&ENERCA.KUMOY','V V R  ',NEQ,IKUMOY)
          CALL MRMULT('ZERO',IRIGID,ZR(IUMOY),'R',ZR(IKUMOY),1)
          DO 60 IAUX=1,NEQ
            ZR(IFMOY-1+IAUX)=ZR(IKUMOZ-1+IAUX)-ZR(IKUMOY-1+IAUX)
  60      CONTINUE
          COEFL=1.D0
C ON PEUT NE PAS AVOIR DE BLOCAGE ET NE JAMAIS CALCULER DE LAGRANGE
C NI DE COEFFICIENT DE MISE A L ECHELLE
          CALL JEEXIN(RIGID//'.CONL',IRET)
          IF (IRET.NE.0) THEN
            CALL JEVEUO(RIGID//'.CONL','L',JCONL)
            DO 70 IAUX=1,NEQ
              IF (ZR(JCONL-1+IAUX).GT.1.D0) THEN
                COEFL=ZR(JCONL-1+IAUX)
              ENDIF
  70        CONTINUE
          ENDIF
          WEXT = WEXT + DDOT(NEQ,ZR(IFMOY),1,ZR(IUPMUZ),1)/COEFL
        ENDIF
      ENDIF
C 3. CONTRIBUTION DES NEUMANN
      DO 80 IAUX=1,NEQ
        ZR(IFMOY-1+IAUX)=(FEXTE(IAUX)+FEXTE(IAUX+NEQ))*5.D-1
  80  CONTINUE
C GLUT : LA CONTRIBUTION DE LA FORCE QUI TRAVAILLE EN UN POINT OU
C LE DEPLACEMENT EST IMPOSE EST PRIS EN COMPTE DANS WEXT1 POUR
C LES AFFE_CHAR_CINE ET DANS WEXT2 POUR AFFE_CHAR_MECA. IL PEUT
C ARRIVER QU'ELLE SOIT REPRISE EN COMPTE DANS WEXT3 SI ON INTRODUIT
C UN CHARGEMENT VOLUMIQUE (PESANTEUR). IL FAUT DONC METTRE A ZERO
C CERTAINS TERMES DES EFFORTS EXTERIEURS.
      DO 90 IAUX=1,NEQ
        IF (FCINE(IAUX).NE.0.D0) THEN
          ZR(IFMOY-1+IAUX)=0.D0
        ENDIF
  90  CONTINUE
      WEXT = WEXT + DDOT(NEQ,ZR(IFMOY),1,ZR(IUPMUZ),1)
C --------------------------------------------------------------------
C LIAI : ENERGIE DISSIPEE PAR LES LIAISONS
C - UNIQUEMENT IMPE_ABSO POUR DYNA_LINE_TRAN
C --------------------------------------------------------------------
      DO 100 IAUX=1,NEQ
        ZR(IFMOY-1+IAUX)=(FLIAI(IAUX)+FLIAI(IAUX+NEQ))*5.D-1
 100  CONTINUE
      LIAI=DDOT(NEQ,ZR(IUPMUZ),1,ZR(IFMOY),1)
C --------------------------------------------------------------------
C AMOR : ENERGIE DISSIPEE PAR AMORTISSEMENT
C - UNIQUEMENT SI CALCUL DYNAMIQUE
C --------------------------------------------------------------------
      IF (LDYNA) THEN
        DO 110 IAUX=1,NEQ
          ZR(IFMOY-1+IAUX)=(FAMOR(IAUX)+FAMOR(IAUX+NEQ))*5.D-1
  110   CONTINUE
        AMOR=DDOT(NEQ,ZR(IUPMUZ),1,ZR(IFMOY),1)
        IF (LAMORT) THEN
          IF (ZI(IAMORT+3).EQ.1) THEN
            CALL WKVECT('&&ENERCA.CVMOYZ','V V R',NEQ,ICVMOZ)
            CALL MRMULT('ZERO',IAMORT,ZR(IVMOYZ),'R',ZR(ICVMOZ),1)
            AMOR = AMOR + DDOT(NEQ,ZR(IUPMUZ),1,ZR(ICVMOZ),1)
          ELSE
            CALL WKVECT('&&ENERCA.CVMOYZ','V V C',NEQ,ICVMOZ)
            CALL MRMULT('ZERO',IAMORT,ZR(IVMOYZ),'C',ZR(ICVMOZ),1)
            AMOR = AMOR + DDOT(NEQ,ZR(IUPMUZ),1,ZR(ICVMOZ),1)
          ENDIF
        ENDIF
      ENDIF
C --------------------------------------------------------------------
C WSCH : ENERGIE DISSIPEE PAR LE SCHEMA
C --------------------------------------------------------------------
      WSCH=WEXT-ECIN-WINT-AMOR-LIAI
C --------------------------------------------------------------------
C MISE A JOUR DES ENERGIES
C - ORDRE : WEXT - ECIN - WINT - AMOR - LIAI - WSCH
C --------------------------------------------------------------------
      CALL JEVEUO(SDENER//'.VALE','E',IENER)
      NBCOL=4
      ZR(IENER-1+1)=ZR(IENER-1+1)+WEXT
      ZR(IENER-1+3)=ZR(IENER-1+3)+WINT
      ZR(IENER-1+6)=ZR(IENER-1+6)+WSCH
      IF (LDYNA) THEN
        ZR(IENER-1+2)=ZR(IENER-1+2)+ECIN
        ZR(IENER-1+4)=ZR(IENER-1+4)+AMOR
        NBCOL=NBCOL+2
      ENDIF
      ZR(IENER-1+5)=ZR(IENER-1+5)+LIAI
      IF ((ZR(IENER-1+5).NE.0.D0).OR.(LIAI.NE.0.D0)) THEN
        NBCOL=NBCOL+1
      ENDIF
C --------------------------------------------------------------------
C AFFICHAGE DU BILAN
C MINIMUM : 4 COLONNES (TITRE, WEXT, WINT, WSCH)
C 5 COLONNES : AJOUT DE LIAI
C 6 COLONNES : AJOUT DE ECIN ET AMOR
C 7 COLONNES : AJOUT DE LIAI, ECIN ET AMOR
C --------------------------------------------------------------------
      LONG=18+14*(NBCOL-1)+1
      WRITE(FORMA,1001) LONG
      WRITE(6,FORMA) ('-',IAUX=1,LONG)
      WRITE(FORMB,1002) NBCOL-1
      WRITE(FORMC,1003) NBCOL-1
      IF (NBCOL.EQ.4) THEN
        WRITE(6,FORMB) '|','BILAN D''ENERGIE','|','WEXT','|','WINT',
     &                 '|','WSCH','|'
        WRITE(6,FORMC) '|','  PAS COURANT  ','|',WEXT,'|',WINT,
     &                 '|',WSCH,'|'
        WRITE(6,FORMC) '|','     TOTAL     ','|',ZR(IENER-1+1),
     &                 '|',ZR(IENER-1+3),'|',ZR(IENER-1+6),'|'
      ELSE IF (NBCOL.EQ.5) THEN
        WRITE(6,FORMB) '|','BILAN D''ENERGIE','|','WEXT','|','WINT',
     &                 '|','LIAI','|','WSCH','|'
        WRITE(6,FORMC) '|','  PAS COURANT  ','|',WEXT,'|',WINT,'|',LIAI,
     &                 '|',WSCH,'|'
        WRITE(6,FORMC) '|','     TOTAL     ','|',ZR(IENER-1+1),
     &                 '|',ZR(IENER-1+3),'|',ZR(IENER-1+5),
     &                 '|',ZR(IENER-1+6),'|'
      ELSE IF (NBCOL.EQ.6) THEN
        WRITE(6,FORMB) '|','BILAN D''ENERGIE','|','WEXT','|','WINT',
     &                 '|','ECIN','|','AMOR','|','WSCH','|'
        WRITE(6,FORMC) '|','  PAS COURANT  ','|',WEXT,'|',WINT,'|',ECIN,
     &                 '|',AMOR,'|',WSCH,'|'
        WRITE(6,FORMC) '|','     TOTAL     ','|',ZR(IENER-1+1),
     &                 '|',ZR(IENER-1+3),'|',ZR(IENER-1+2),
     &                 '|',ZR(IENER-1+4),'|',ZR(IENER-1+6),'|'
      ELSE IF (NBCOL.EQ.7) THEN
        WRITE(6,FORMB) '|','BILAN D''ENERGIE','|','WEXT','|','WINT',
     &                 '|','ECIN','|','AMOR','|','LIAI','|','WSCH','|'
        WRITE(6,FORMC) '|','  PAS COURANT  ','|',WEXT,'|',WINT,'|',ECIN,
     &                 '|',AMOR,'|',LIAI,'|',WSCH,'|'
        WRITE(6,FORMC) '|','     TOTAL     ','|',ZR(IENER-1+1),
     &                 '|',ZR(IENER-1+3),'|',ZR(IENER-1+2),
     &                 '|',ZR(IENER-1+4),'|',ZR(IENER-1+5),
     &                 '|',ZR(IENER-1+6),'|'
      ENDIF
      WRITE(6,FORMA) ('-',IAUX=1,LONG)

C --------------------------------------------------------------------
C MENAGE
C --------------------------------------------------------------------
      CALL JEDETR('&&ENERCA.CVMOYZ')
      CALL JEDETR('&&ENERCA.DESC')
      CALL JEDETR('&&ENERCA.FMOY')
      CALL JEDETR('&&ENERCA.KUMOY')
      CALL JEDETR('&&ENERCA.KUMOYZ')
      CALL JEDETR('&&ENERCA.MDV')
      CALL JEDETR('&&ENERCA.MUMOY')
      CALL JEDETR('&&ENERCA.MUMOYZ')
      CALL JEDETR('&&ENERCA.UMOY')
      CALL JEDETR('&&ENERCA.UMOYZ')
      CALL JEDETR('&&ENERCA.UPMUM')
      CALL JEDETR('&&ENERCA.UPMUMZ')
      CALL JEDETR('&&ENERCA.VMOY')
      CALL JEDETR('&&ENERCA.VMOYZ')
      CALL JEDETR('&&ENERCA.VPMVM')
      CALL JEDETR('&&ENERCA.VPMVMZ')

1001  FORMAT ('(',I3,'A1)')
C1002  FORMAT ('(',I1,'(A1,4X,A4,5X),(A1,4X,A5,4X),A1)')
1002  FORMAT ('((A1,1X,A15,1X),',I1,'(A1,4X,A4,5X),A1)')
C1003  FORMAT ('(',I1,'(A1,1X,ES11.4,1X),(A1,4X,A5,4X),A1)')
1003  FORMAT ('((A1,1X,A15,1X),',I1,'(A1,1X,ES11.4,1X),A1)')
      CALL JEDEMA()
      END
