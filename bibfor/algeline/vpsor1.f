      SUBROUTINE VPSOR1
     &  (LDYNFA, NBEQ, NBVECT, NFREQ, TOLSOR, VECT, RESID,
     &   WORKD, WORKL, LONWL, SELEC, DSOR, FSHIFT, VAUX, WORKV,
     &   DDLEXC, DDLLAG, NEQACT, MAXITR, IFM, NIV, PRIRAM, ALPHA,
     &   OMECOR, NCONV, FLAGE)
C---------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGELINE  DATE 13/12/2006   AUTEUR PELLET J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2003  EDF R&D                  WWW.CODE-ASTER.ORG
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
C TOLE CRP_21
C
C     SUBROUTINE ASTER ORCHESTRANT LA METHODE DE SORENSEN: UN ARNOLDI
C     AVEC REDEMARRAGE IMPLICITE VIA QR (VERSION ARPACK 2.4).
C---------------------------------------------------------------------
C     PARTANT DU PROBLEME GENERALISE AUX VALEURS PROPRES
C                           (A)*X = LAMBDA*(B)*X
C     AVEC
C      - LES MATRICES REELLES SYMETRIQUES (A) ET (B), CORRESPONDANT AUX
C     MATRICES DE RAIDEUR ET A CELLE DE MASSE (RESP. RAIDEUR GEOMETRIQUE
C     , EN FLAMBEMENT),
C      - LE REEL, LAMBDA, CORRESPONDANT AU CARRE DE LA PULSATION (RESP.
C     L'OPPOSE DE LA CHARGE CRITIQUE, EN FLAMBEMENT),
C      - LE OU LES VECTEURS PROPRES REELS ASSOCIES, X, (A- ET B- ORTHOGO
C        NAUX ENTRE EUX AINSI QU'AVEC CEUX DES AUTRES VALEURS PROPRES).
C
C     ON RESOUT LE PROBLEME STANDARD
C                             (OP)*X =  MU*X
C     AVEC
C       - L'OPERATEUR SHIFTE (OP) = INV((A)-SIGMA*(B))*(B),
C       - LE 'SHIFT' REEL SIGMA,
C       - LA VALEUR PROPRE MU = 1/(LAMBDA-SIGMA),
C       - LE OU LES MEMES VECTEURS PROPRES QU'INITIALEMENT, X.
C   ------------------------------------------------------------------
C   CETTE METHODE, PARTANT D'UNE FACTORISATION DE TYPE ARNOLDI D'ORDRE
C   M=K+P DU PROBLEME, PILOTE UN RESTART A L'ORDRE K SUR P NOUVELLES
C   ITERATIONS. CE RESTART PERMET D'AMELIORER LES K PREMIERES VALEURS
C   PROPRES SOUHAITEES, LES P DERNIERES SERVANT UNIQUEMENT AUX CALCULS
C   AUXILIAIRES.
C   ELLE PERMET
C     - DE MINIMISER LA TAILLE DU SOUS-ESPACE DE PROJECTION,
C     - D'EFFECTUER DES RESTARTS DE MANIERE TRANSPARENTE, EFFICACE ET
C       AVEC DES PRE-REQUIS MEMOIRE FIXES,
C     - DE MIEUX PRENDRE EN COMPTE LES MULTIPLICITES,
C     - DE TRAITER AVEC UN BON COMPROMIS LA STRATEGIE DE RE-ORTHONORMA
C       LISATION.
C   -------------------------------------------------------------------
C     SUBROUTINES APPELLEES:
C
C       DNAUPD -> (SUBROUTINE ISSUE DU PACKAGE ARPACK 2.5 RELEASE 2)
C         CALCUL DES VALEURS PROPRES DE (OP) EN COMMUNIQUANT LES DONNEES
C         MECANIQUE EN 'REVERSE COMMUNICATION MODE' VIA L'INTEGER IDO.
C       DNEUPD -> (SUBROUTINE ISSUE DU PACKAGE ARPACK 2.5 RELEASE 2)
C         CALCUL ET FILTRAGE DES MODES PROPRES DU PROBLEME INITIAL.
C       VPGSKP    -> (SUBROUTINE IMPLANTANT LA METHODE DE KAHAN-PARLET)
C         (A)- ET (B)- ORTHONORMALISATION DES VECTEURS PROPRES.
C       RLDLGG -> (SUBROUTINE ASTER)
C         RESOLUTION DE SYSTEME LDLT.
C       MRMULT -> (SUBROUTINE ASTER)
C         PRODUIT MATRICE-VECTEUR.
C       VPORDO -> (SUBROUTINE ASTER)
C         REMISE EN ORDRE DES MODES PROPRES.
C       UTDEBM, UTIMPI, UTIMPR, UTFINM -> (SUBROUTINES ASTER)
C         UTILITAIRES D'IMPRESSION
C
C     FONCTIONS INTRINSEQUES:
C
C       ABS.
C   ------------------------------------------------------------------
C     PARAMETRES D'APPELS:
C
C IN  LDYNFA : IS : DESCRIPTEUR MATRICE DE "RAIDEUR"-SHIFT"MASSE"
C                     FACTORISEE.
C IN  NBEQ   : IS : DIMENSION DES VECTEURS.
C IN  NBVECT : IS : DIMENSION DE L'ESPACE DE PROJECTION.
C IN  NFREQ  : IS : NOMBRE DE VALEURS PROPRES DEMANDEES.
C IN  TOLSOR : R8 : NORME D'ERREUR SOUHAITEE (SI 0.D0 ALORS LA VALEUR
C                   PAR DEFAUT EST LA PRECISION MACHINE).
C IN  LONWL  : IS : TAILLE DU VECTEUR DE TRAVAIL WORKL.
C IN  FSHIFT : R8 : VALEUR DU SHIFT SIGMA EN OMEGA2.
C IN  DDLEXC : IS : DDLEXC(1..NBEQ) VECTEUR POSITION DES DDLS BLOQUES.
C IN  DDLLAG : IS : DDLLAG(1..NBEQ) VECTEUR POSITION DES LAGRANGES.
C IN  NEQACT : IS : NOMBRE DE DDLS ACTIFS.
C IN  MAXITR : IS : NOMBRE MAXIMUM DE RESTARTS.
C IN  IFM    : IS : UNITE LOGIQUE D'IMPRESSION DES .MESS
C IN  NIV    : IS : NIVEAU D'IMPRESSION
C IN  PRIRAM : IS : PRIRAM(1..8) VECTEUR NIVEAU D'IMPRESSION ARPACK
C IN  ALPHA  : R8 : PARAMETRE VPGSKP D'ORTHONORMALISATION.
C IN  OMECOR : R8 : OMEGA2 DE CORPS RIGIDE
C
C OUT VECT   : R8 : VECT(1..NBEQ,1..NBVECT) MATRICE DES
C                   VECTEURS D'ARNOLDI.
C OUT RESID  : R8 : RESID(1..NBEQ) VECTEUR RESIDU.
C OUT WORKD  : R8 : WORKD(1..3*NBEQ) VECTEUR DE TRAVAIL PRIMAIRE IRAM
C OUT WORKL  : R8 : WORKL(1..LONWL) VECTEUR DE TRAVAIL SECONDAIRE IRAM
C OUT SELEC  : LS : SELEC(1..NBVECT) VECTEUR DE TRAVAIL POUR DNEUPD.
C OUT DSOR   : R8 : DSOR(1..NFREQ+1,1..2) MATRICE DES VALEURS PROPRES.
C OUT VAUX   : R8 : VAUX(1..NBEQ) VECTEUR DE TRAVAIL POUR VPSORN.
C OUT WORKV  : R8 : WORKV(1..3*NBVECT) VECTEUR DE TRAVAIL POUR DNEUPD
C                     ET VPGSKP.
C OUT NCONV  : IS : NOMBRE DE MODES CONVERGES.
C OUT FLAGE  : LO : FLAG PERMETTANT DE GERER LES IMPRESSIONS
C
C ASTER INFORMATION
C 11/01/2000 TOILETTAGE DU FORTRAN SUIVANT LES REGLES ASTER,
C            MSGS GERES PAR UTDEBM, UTIMPI, UTIMPR, UTFINM.
C 23/03/2000 PASSAGE OMECOR POUR TESTS SI IM(VP) < 0, TRANSF DU MSG,
C            CHANGEMENT MSGS DNAUPD/1 ET 3, DNEUPD/-14 ET 0,
C            CHANGEMENT UTMESS(F.. EN UTMESS(S.. POUR NCONV < NFREQ,
C            SORTIE NCONV ET FLAGE POUR OP0045.
C----------------------------------------------------------------------
C CORPS DU PROGRAMME
      IMPLICIT NONE

C DECLARATION PARAMETRES D'APPELS
      INTEGER LDYNFA, NBEQ, NBVECT, NFREQ, LONWL, DDLEXC(NBEQ),
     &  DDLLAG(NBEQ), NEQACT, MAXITR, IFM, NIV, PRIRAM(8), NCONV
      REAL*8  TOLSOR, VECT(NBEQ,NBVECT), RESID(NBEQ), WORKD(3*NBEQ),
     &  WORKL(LONWL), DSOR(NFREQ+1,2), FSHIFT, VAUX(NBEQ),
     &  WORKV(3*NBVECT), ALPHA, OMECOR
      LOGICAL SELEC(NBVECT), FLAGE
C--------------------------------------------------------------------
C DECLARATION VARIABLES LOCALES

C POUR LE FONCTIONNEMENT GLOBAL
      INTEGER I, J
      COMPLEX*16 CBID
      REAL*8 VARAUX

C POUR ARPACK
      INTEGER IDO, INFO, ISHFTS, MODE, IPARAM(11),IPNTR(14)
      REAL*8  SIGMAR, SIGMAI
      LOGICAL  RVEC
      CHARACTER*1 BMAT
      CHARACTER*2 WHICH

      INTEGER LOGFIL, NDIGIT, MGETV0,
     &  MNAUPD, MNAUP2, MNAITR, MNEIGH, MNAPPS, MNGETS, MNEUPD
      COMMON /DEBUG/
     &  LOGFIL, NDIGIT, MGETV0,
     &  MNAUPD, MNAUP2, MNAITR, MNEIGH, MNAPPS, MNGETS, MNEUPD
C------------------------------------------------------------------
C INITIALISATION POUR ARPACK

C NIVEAU D'IMPRESSION ARPACK
      NDIGIT = -3
      LOGFIL = IFM
      MGETV0 = PRIRAM(1)
      MNAUPD = PRIRAM(2)
      MNAUP2 = PRIRAM(3)
      MNAITR = PRIRAM(4)
      MNEIGH = PRIRAM(5)
      MNAPPS = PRIRAM(6)
      MNGETS = PRIRAM(7)
      MNEUPD = PRIRAM(8)

C FONCTIONNEMENT D'ARPACK
      IDO = 0
      INFO = 0
      ISHFTS = 1
      MODE = 3
      SIGMAR = FSHIFT
      SIGMAI = 0.D0
      RVEC = .TRUE.
      BMAT  = 'I'
      WHICH = 'LM'
      IPARAM(1) = ISHFTS
      IPARAM(3) = MAXITR
      IPARAM(4) = 1
      IPARAM(7) = MODE

C------------------------------------------------------------------
C BOUCLE PRINCIPALE

 20   CONTINUE

C CALCUL DES VALEURS PROPRES DE (OP)
      CALL DNAUPD
     &  (IDO, BMAT, NBEQ, WHICH, NFREQ, TOLSOR, RESID, NBVECT,
     &   VECT, NBEQ, IPARAM, IPNTR, WORKD, WORKL, LONWL, INFO, NEQACT,
     &   ALPHA)

C NOMBRE DE MODES CONVERGES
      NCONV = IPARAM(5)

C GESTION DES FLAGS D'ERREURS
      IF ((INFO.EQ.1).AND.(NIV.GT.1)) THEN
        WRITE(IFM,*)
        WRITE(IFM,*)'<VPSORN/DNAUPD 1> NOMBRE MAXIMAL D''ITERATIONS'
        WRITE(IFM,*)' NMAX_ITER_SOREN = ',MAXITR,' A ETE ATTEINT !'
        WRITE(IFM,*)
      ELSE IF (INFO.EQ.2) THEN
        CALL U2MESS('F','ALGELINE3_72')
      ELSE IF ((INFO.EQ.3).AND.(NIV.GE.1)) THEN
        WRITE(IFM,*)
        WRITE(IFM,*)'<VPSORN/DNAUPD 3> AUCUN SHIFT NE PEUT ETRE'//
     &   ' APPLIQUE'
        WRITE(IFM,*)
      ELSE IF (INFO.EQ.-7) THEN
        CALL U2MESS('F','ALGELINE3_73')
      ELSE IF (INFO.EQ.-8) THEN
        CALL U2MESS('F','ALGELINE3_74')
      ELSE IF (INFO.EQ.-9) THEN
        CALL U2MESS('F','ALGELINE3_75')
      ELSE IF ((INFO.EQ.-9999).AND.(NIV.GE.1)) THEN
        WRITE(IFM,*)
        WRITE(IFM,*)'<VPSORN/DNAUPD -9999> PROBLEME FACTORISATION'//
     &    ' D''ARNOLDI'
        WRITE(IFM,*)
      ELSE IF (INFO.LT.0) THEN
        CALL UTDEBM('F','VPSORN/DNAUPD -N','INCOHERENCE DE CER'//
     &    'TAINS PARAMETRES MODAUX PROPRES A ARPACK')
        CALL UTIMPI('L',' NUMERO D''ERREUR ',1,INFO)
        CALL UTFINM()
      ENDIF
C
C GESTION DES MODES CONVERGES
      IF ((NCONV.LT.NFREQ).AND.(IDO.EQ.99)) THEN
        CALL UTDEBM('E','VPSORN/DNAUPD 0','NOMBRE DE VALEURS PROPRES ')
        CALL UTIMPI('S','CONVERGEES ',1,NCONV)
        CALL UTIMPI('L','< NOMBRE DE FREQUENCES DEMANDEES ',1,NFREQ)
        CALL UTIMPI('L','ERREUR ARPACK NUMERO : ',1,INFO)
        CALL UTIMPI('L','--> LE CALCUL CONTINUE, LA PROCHAINE FOIS',0,I)
        CALL UTIMPI('L','-->   AUGMENTER DIM_SOUS_ESPACE = ',1,NBVECT)
        CALL UTIMPI('L','-->   OU NMAX_ITER_SOREN = ',1,MAXITR)
        CALL UTIMPR('L','-->   OU PREC_SOREN = ',1,TOLSOR)
        CALL UTFINM()
        FLAGE = .TRUE.
      ENDIF

C---------------------------------------------------------------------
C ZONE GERANT LA 'REVERSE COMMUNICATION' VIA IDO

      IF (IDO .EQ. -1) THEN
C CALCUL DU Y = (OP)*X INITIAL
C 1/ CALCUL D'UN ELT. INITIAL X REPONDANT AU C.I. DE LAGRANGE
C 2/ CALCUL DE Y = (OP)* X AVEC DDL CINEMATIQUEMENT BLOQUES
C X <- X*DDL_LAGRANGE
        DO 25 J=1,NBEQ
          VAUX(J) = WORKD(IPNTR(1)+J-1) * DDLLAG(J)
   25   CONTINUE
C X <- (INV((A)-SIGMA*(B))*X)*DDL_LAGRANGE
        CALL RLDLGG(LDYNFA, VAUX, CBID, 1)
        DO 30 J= 1,NBEQ
          WORKD(IPNTR(1)+J-1) = VAUX(J) * DDLLAG(J)
   30   CONTINUE
C X <- (OP)*(X*DDL_BLOQUE)
C        CALL MRMULT('ZERO', LMASSE, WORKD(IPNTR(1)), 'R', VAUX, 1)
        DO 35 J=1,NBEQ
C          VAUX(J) = VAUX(J) * DDLEXC(J)
          VAUX(J) = WORKD(IPNTR(1)+J-1) * DDLEXC(J)
   35   CONTINUE
        CALL RLDLGG(LDYNFA, VAUX, CBID, 1)
C RETOUR VERS DNAUPD
        DO 40 J=1,NBEQ
          WORKD(IPNTR(2)+J-1) = VAUX(J)
   40   CONTINUE
        GOTO 20

      ELSE IF ( IDO .EQ. 1) THEN
C CALCUL DU Y = (OP)*X CONNAISSANT DEJA (B)*X (EN FAIT ON CONNAIT
C SEULEMENT (ID)*X VIA IDO= 2 CAR PRODUIT SCALAIRE= L2)
C X <- (B)*X*DDL_BLOQUE
C        CALL MRMULT('ZERO', LMASSE, WORKD(IPNTR(3)), 'R', VAUX, 1)
        DO 45 J=1,NBEQ
C          VAUX(J) = VAUX(J) * DDLEXC(J)
          VAUX(J) =  WORKD(IPNTR(3)+J-1) * DDLEXC(J)
   45   CONTINUE
C X <- (OP)*X
        CALL RLDLGG(LDYNFA, VAUX, CBID, 1)
C RETOUR VERS DNAUPD
        DO 50 J=1,NBEQ
          WORKD(IPNTR(2)+J-1) = VAUX(J)
   50   CONTINUE
        GOTO 20

      ELSE IF ( IDO .EQ. 2) THEN
C X <- X*DDL_BLOQUE  (PRODUIT SCALAIRE= L2)
         DO 55 J=1,NBEQ
             WORKD(IPNTR(2)+J-1)=WORKD(IPNTR(1)+J-1)*DDLEXC(J)
   55   CONTINUE
C RETOUR VERS DNAUPD
        GOTO 20

      END IF
C--------------------------------------------------------------------
C CALCUL DES MODES PROPRES APPROCHES DU PB INITIAL

       INFO = 0
       CALL DNEUPD
     &   (RVEC, 'A', SELEC, DSOR, DSOR(1,2), VECT, NBEQ,
     &    SIGMAR, SIGMAI, WORKV, BMAT, NBEQ, WHICH, NFREQ, TOLSOR,
     &    RESID, NBVECT, VECT, NBEQ, IPARAM, IPNTR, WORKD,
     &    WORKL, LONWL, INFO)

C GESTION DES FLAGS D'ERREURS
        IF (INFO.EQ.1) THEN
          CALL U2MESS('F','ALGELINE3_74')
        ELSE IF (INFO.EQ.-7) THEN
          CALL U2MESS('F','ALGELINE3_73')
        ELSE IF (INFO.EQ.-8) THEN
          CALL U2MESS('F','ALGELINE3_76')
        ELSE IF (INFO.EQ.-9) THEN
          CALL U2MESS('F','ALGELINE3_77')
        ELSE IF (INFO.EQ.-14) THEN
          CALL U2MESS('F','ALGELINE3_78')
        ELSE IF (INFO.LT.0) THEN
          CALL UTDEBM('F','VPSORN/DNEUPD -N','INCOHERENCE DE CER'//
     &     'TAINS PARAMETRES MODAUX PROPRES A ARPACK')
          CALL UTIMPI('L',' NUMERO D''ERREUR ',1,INFO)
          CALL UTFINM()
        ENDIF
C--------------------------------------------------------------------
C TESTS ET POST-TRAITEMENTS

C POUR TEST
C      DO 59 J=1,NCONV
C       WRITE(IFM,*) '******** VALEUR DE RITZ N ********',J
C       WRITE(IFM,*) 'RE: LANDAJ/ FJ INIT',DSOR(J,1),
C    &                   FREQOM(DSOR(J,1))
C       WRITE(IFM,*) 'IM: LANDAJ/ FJ INIT',DSOR(J,2),
C    &                   FREQOM(DSOR(J,2))
C  59 CONTINUE


C VERIFICATIONS DES VALEURS PROPRES
      DO 60 J=1,NCONV
        VARAUX = ABS(DSOR(J,2))
        IF (VARAUX.GT.OMECOR) THEN
          CALL UTDEBM('A','VPSORN/DNEUPD 0','LA VALEUR PROPRE ')
          CALL UTIMPI('S','NUMERO ',1,J)
          CALL UTIMPI('L','A UNE PARTIE IMAGINAIRE NON NULLE',0,I)
          CALL UTIMPR('L','RE(VP) = ',1,DSOR(J,1))
          CALL UTIMPR('L','IM(VP) = ',1,DSOR(J,2))
          CALL UTIMPI('L','--> CE PHENOMENE NUMERIQUE EST FREQUENT',0,
     &      I)
          CALL UTIMPI('L','--> SUR LES PREMIERES VALEURS PROPRES',0,I)
          CALL UTIMPI('L','--> LORSQUE LE SPECTRE RECHERCHE EST',0,I)
          CALL UTIMPI('L','--> TRES ETENDU (EN PULSATION) ',0,I)
          CALL UTFINM()
        ELSE IF ((VARAUX.NE.0.D0).AND.(NIV.GE.1)) THEN
          WRITE(IFM,*)'<VPSORN/DNEUPD 0> LA VALEUR PROPRE NUMERO ',J
          WRITE(IFM,*)'A UNE PARTIE IMAGINAIRE NON NULLE'
          WRITE(IFM,*)'RE(VP) = ',DSOR(J,1)
          WRITE(IFM,*)'IM(VP) = ',DSOR(J,2)
          WRITE(IFM,*)'--> CE PHENOMENE NUMERIQUE EST FREQUENT'
          WRITE(IFM,*)'--> SUR LES PREMIERES VALEURS PROPRES'
          WRITE(IFM,*)'--> LORSQUE LE SPECTRE RECHERCHE EST'
          WRITE(IFM,*)'--> TRES ETENDU (EN PULSATION) '
        ENDIF
   60 CONTINUE

C REMISE EN FORMES DES MODES PROPRES SELON FORMAT OP0045
      DO 65 I=1,NCONV
        DSOR(I,1) = DSOR(I,1) - SIGMAR
        DSOR(I,2) = DSOR(I,2) - SIGMAI
   65 CONTINUE

C TRI DES MODES PROPRES PAR RAPPORT AU NCONV DSOR(I)
      CALL VPORDO(1, 0, NCONV, DSOR, VECT, NBEQ)

C RE-ORTHONORMALISATION SUIVANT IGS PAR RAPPORT A B
      CALL VPGSKP
     &  (NBEQ, NCONV, VECT, ALPHA, LDYNFA, 1, VAUX, DDLEXC, WORKV)

C FIN DE VPSORN

      END
