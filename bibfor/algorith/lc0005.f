      SUBROUTINE LC0005(FAMI,KPG,KSP,NDIM,IMATE,COMPOR,CRIT,INSTAM,
     &              INSTAP,EPSM,DEPS,SIGM,VIM,OPTION,ANGMAS,SIGP,VIP,
     &                  TAMPON,TYPMOD,ICOMP,NVI,DSIDEP,CODRET)
      IMPLICIT NONE
      INTEGER         IMATE,NDIM,KSP,KPG
      INTEGER         ICOMP,NVI
      INTEGER         CODRET
      REAL*8          ANGMAS(*)
      REAL*8          TAMPON(*)
      CHARACTER*16    COMPOR(*),OPTION
      CHARACTER*8     TYPMOD(*)
      CHARACTER*(*)   FAMI
      REAL*8          EPSM(6),  DEPS(6),CRIT(*)
      REAL*8          SIGP(6),SIGM(*),INSTAM,INSTAP
      REAL*8          VIM(*),   VIP(*)
      REAL*8          DSIDEP(6,6)

C
C TOLE CRP_21
C ======================================================================
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 28/02/2011   AUTEUR BARGELLI R.BARGELLINI 
C ======================================================================
C COPYRIGHT (C) 1991 - 2011  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE PROIX J-M.PROIX
C ======================================================================
C.......................................................................
C
C     BUT: LOI D'ENDOMMAGEMENT D'UN MATERIAU ELASTIQUE FRAGILE
C
C          RELATION : 'ENDO_FRAGILE'
C
C       IN      NDIM    DIMENSION DE L ESPACE (3D=3,2D=2,1D=1)
C               TYPMOD  TYPE DE MODELISATION
C               OPTION     OPTION DE CALCUL A FAIRE
C                             'RIGI_MECA_TANG'> DSIDEP(T)
C                             'FULL_MECA'     > DSIDEP(T+DT) , SIG(T+DT)
C                             'RAPH_MECA'     > SIG(T+DT)
C               IMATE    ADRESSE DU MATERIAU CODE
C               EPSM   DEFORMATION TOTALE A T
C               DEPS   INCREMENT DE DEFORMATION TOTALE
C               VIM    VARIABLES INTERNES A T    + INDICATEUR ETAT T
C    ATTENTION  VIM    VARIABLES INTERNES A T MODIFIEES SI REDECOUPAGE
C       OUT     SIGP    CONTRAINTE A T+DT
C               VIP    VARIABLES INTERNES A T+DT + INDICATEUR ETAT T+DT
C               DSIDEP    MATRICE DE COMPORTEMENT TANGENT A T+DT OU T


C
C     NORMALEMENT, LES VERIF ONT ETE FAITES AVANT POUR INTERDIRE
C     SIMO_MIEHE
C     EXPLICITE

C     FORMULATION NON-LOCALE AVEC REGULARISATION DES DEFORMATIONS
      IF (TYPMOD(2).EQ.'GRADEPSI') THEN

        CALL LCFRGE(NDIM,TYPMOD,IMATE,EPSM,DEPS,
     &              VIM,OPTION,SIGP,VIP,DSIDEP,TAMPON)

C     FORMULATION LOCALE
      ELSE
        IF (CRIT(2).NE.9) THEN
            CALL LCFRLO (NDIM,TYPMOD,IMATE,EPSM,DEPS,
     &               VIM,OPTION,SIGP,VIP,DSIDEP)
             ELSE
            CALL FRAGEX(FAMI,KPG,KSP,NDIM,IMATE,COMPOR,CRIT,INSTAM,
     &            INSTAP,EPSM,DEPS,SIGM,VIM,OPTION,ANGMAS,SIGP,
     &             VIP,TAMPON,TYPMOD,ICOMP,NVI,DSIDEP,CODRET)
             ENDIF

      ENDIF

      END
