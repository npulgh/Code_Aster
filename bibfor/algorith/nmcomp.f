      SUBROUTINE NMCOMP (FAMI,KPG,KSP,NDIM,TYPMOD,IMATE,COMPOR,CRIT,
     &                   INSTAM,INSTAP, NEPS,EPSM,DEPS,NSIG,SIGM,VIM,
     &                   OPTION,ANGMAS,NWKIN,WKIN,
     &                   SIGP,VIP,NDSDE,DSIDEP,NWKOUT,WKOUT,CODRET)
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 19/12/2012   AUTEUR PELLET J.PELLET 
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
C RESPONSABLE PROIX J.M.PROIX
C TOLE CRP_21
C
      IMPLICIT NONE
      INTEGER      KPG,KSP,NDIM,IMATE,CODRET,ICP,NUMLC
      INTEGER      NEPS,NSIG,NWKIN,NWKOUT,NDSDE
      CHARACTER*8  TYPMOD(*)
      CHARACTER*(*)FAMI
      CHARACTER*16 COMPOR(*), OPTION
      REAL*8       CRIT(*), INSTAM, INSTAP
      REAL*8       EPSM(*), DEPS(*), DSIDEP(*)
      REAL*8       SIGM(*), VIM(*), SIGP(*), VIP(*)
      REAL*8       WKIN(*),WKOUT(*)
      REAL*8       ANGMAS(*)
C ----------------------------------------------------------------------
C     INTEGRATION DES LOIS DE COMPORTEMENT NON LINEAIRE POUR LES
C     ELEMENTS ISOPARAMETRIQUES EN PETITES OU GRANDES DEFORMATIONS
C
C IN  FAMI,KPG,KSP  : FAMILLE ET NUMERO DU (SOUS)POINT DE GAUSS
C     NDIM    : DIMENSION DE L'ESPACE
C               3 : 3D , 2 : D_PLAN ,AXIS OU  C_PLAN
C     TYPMOD(2): MODELISATION ex: 1:3D, 2:INCO
C     IMATE   : ADRESSE DU MATERIAU CODE
C     COMPOR  : COMPORTEMENT :  (1) = TYPE DE RELATION COMPORTEMENT
C                               (2) = NB VARIABLES INTERNES / PG
C                               (3) = HYPOTHESE SUR LES DEFORMATIONS
C                               (4) etc... (voir grandeur COMPOR)
C     CRIT    : CRITERES DE CONVERGENCE LOCAUX (voir grandeur CARCRI)
C     INSTAM  : INSTANT DU CALCUL PRECEDENT
C     INSTAP  : INSTANT DU CALCUL
C     NEPS    : NOMBRE DE CMP DE EPSM ET DEPS (SUIVANT MODELISATION)
C     EPSM    : DEFORMATIONS A L'INSTANT DU CALCUL PRECEDENT
C     DEPS    : INCREMENT DE DEFORMATION TOTALE :
C                DEPS(T) = DEPS(MECANIQUE(T)) + DEPS(DILATATION(T))
C     NSIG    : NOMBRE DE CMP DE SIGM ET SIGP (SUIVANT MODELISATION)
C     SIGM    : CONTRAINTES A L'INSTANT DU CALCUL PRECEDENT
C     VIM     : VARIABLES INTERNES A L'INSTANT DU CALCUL PRECEDENT
C     OPTION  : OPTION DEMANDEE : RIGI_MECA_TANG , FULL_MECA , RAPH_MECA
C     ANGMAS  : LES TROIS ANGLES DU MOT_CLEF MASSIF (AFFE_CARA_ELEM),
C               + UN REEL QUI VAUT 0 SI NAUTIQUIES OU 2 SI EULER
C               + LES 3 ANGLES D'EULER
C     NWKIN   : DIMENSION DE WKIN 
C     WKIN    : TABLEAU DE TRAVAIL EN ENTREE(SUIVANT MODELISATION)

C OUT SIGP    : CONTRAINTES A L'INSTANT ACTUEL
C VAR VIP     : VARIABLES INTERNES
C                IN  : ESTIMATION (ITERATION PRECEDENTE OU LAG. AUGM.)
C                OUT : EN T+
C     NDSDE   : DIMENSION DE DSIDEP
C     DSIDEP  : OPERATEUR TANGENT DSIG/DEPS OU DSIG/DF
C     NWKOUT  : DIMENSION DE WKOUT
C     WKOUT   : TABLEAU DE TRAVAIL EN SORTIE (SUIVANT MODELISATION)
C     CODRET  : CODE RETOUR LOI DE COMPORMENT :
C               CODRET=0 : TOUT VA BIEN
C               CODRET=1 : ECHEC DANS L'INTEGRATION DE LA LOI
C               CODRET=3 : SIZZ NON NUL (CONTRAINTES PLANES DEBORST)
C
C PRECISIONS :
C -----------
C  LES TENSEURS ET MATRICES SONT RANGES DANS L'ORDRE :
C         XX YY ZZ SQRT(2)*XY SQRT(2)*XZ SQRT(2)*YZ

C -SI DEFORMATION = SIMO_MIEHE  
C   EPSM(3,3)    GRADIENT DE LA TRANSFORMATION EN T-
C   DEPS(3,3)    GRADIENT DE LA TRANSFORMATION DE T- A T+

C  OUTPUT SI RESI (RAPH_MECA, FULL_MECA_*)
C   VIP      VARIABLES INTERNES EN T+
C   SIGP(6)  CONTRAINTE DE KIRCHHOFF EN T+ RANGES DANS L'ORDRE
C         XX YY ZZ SQRT(2)*XY SQRT(2)*XZ SQRT(2)*YZ

C  OUTPUT SI RIGI (RIGI_MECA_*, FULL_MECA_*)
C   DSIDEP(6,3,3) MATRICE TANGENTE D(TAU)/D(FD) * (FD)T
C                 (AVEC LES RACINES DE 2)
C
C -SINON (DEFORMATION = PETIT OU PETIT_REAC OU GDEF_...)
C   EPSM(6), DEPS(6)  SONT LES DEFORMATIONS (LINEARISEES OU GREEN OU ..)
C
C ----------------------------------------------------------------------
C
C    POUR LES UTILITAIRES DE CALCUL TENSORIEL
      INTEGER NDT,NDI
      COMMON /TDIM/ NDT,NDI

      CHARACTER*16 OPTIO2
      LOGICAL CP,CONVCP
      INTEGER CPL,NVV,NCPMAX
      REAL*8  R8BID,R8VIDE

      CODRET = 0
      R8BID=R8VIDE()

C     CONTRAINTES PLANES
      CALL NMCPL1(COMPOR,TYPMOD,OPTION,VIP,DEPS,OPTIO2,CPL,NVV)
      CP=(CPL.NE.0)

C     DIMENSIONNEMENT POUR LE CALCUL TENSORIEL
      NDT = 2*NDIM
      NDI = NDIM

      IF (CP) THEN
        CONVCP = .FALSE.
        NCPMAX = NINT(CRIT(9))
      ELSE
        CONVCP = .TRUE.
        NCPMAX = 1
      ENDIF

C     RECUP NUMLC
      READ (COMPOR(6),'(I16)') NUMLC

C     BOUCLE POUR ETABLIR LES CONTRAINTES PLANES
      DO 1000, ICP = 1,NCPMAX

         IF ( COMPOR(1).EQ.'KIT_DDI') THEN
C        POUR EVITER LA RECURSIVITE. PETITES DEFORMATIONS
            CALL NMCOUP (FAMI,KPG,KSP,NDIM,TYPMOD,IMATE,COMPOR,CP,CRIT,
     &                   INSTAM,INSTAP,
     &                   NEPS,EPSM,DEPS,NSIG,SIGM,VIM,OPTION,
     &                   NWKIN,WKIN,
     &                   SIGP,VIP,NDSDE,DSIDEP,NWKOUT,WKOUT,CODRET)
         ELSE
            CALL REDECE (FAMI,KPG,KSP,NDIM,TYPMOD,IMATE,COMPOR,CRIT,
     &                   INSTAM,INSTAP,
     &                   NEPS,EPSM, DEPS,NSIG,SIGM,VIM,OPTION,ANGMAS,
     &                   NWKIN,WKIN,
     &                   CP,NUMLC,R8BID,R8BID,R8BID,
     &                   SIGP,VIP,NDSDE,DSIDEP,NWKOUT,WKOUT,CODRET)
         ENDIF

C       VERIFIER LA CONVERGENCE DES CONTRAINTES PLANES ET
C       SORTIR DE LA BOUCLE SI NECESSAIRE
        IF(CP) CALL NMCPL3(COMPOR,OPTION,CRIT,DEPS,DSIDEP,NDIM,
     &     SIGP,VIP,CPL,ICP,CONVCP)

        IF(CONVCP) GOTO 1001

 1000 CONTINUE
 1001 CONTINUE

C     CONTRAINTES PLANES METHODE DE BORST
      IF (CP) THEN
         IF (CODRET.EQ.0) THEN
            CALL NMCPL2(COMPOR,TYPMOD,OPTION,OPTIO2,CPL,NVV,CRIT,
     &                    DEPS,DSIDEP,NDIM,SIGP,VIP,CODRET)
         ELSE
            OPTION=OPTIO2
         ENDIF
      ENDIF
C     EXAMEN DU DOMAINE DE VALIDITE      
      IF (CODRET.EQ.0) THEN
         CALL LCVALI(FAMI,KPG,KSP,IMATE,COMPOR,NDIM,
     &            EPSM,DEPS,INSTAM,INSTAP,CODRET)
      ENDIF
      END
