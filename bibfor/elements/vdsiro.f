      SUBROUTINE VDSIRO(NP,NBSP,MATEV,SENS,GOUN,TENS1,TENS2)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 05/09/2011   AUTEUR PELLET J.PELLET 
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
      IMPLICIT NONE
C BUT : CHANGER LE REPERE : INTRINSEQUE <-> UTILISATEUR
C       POUR DES TENSEURS DE CONTRAINTE OU DE DEFORMATION.
C      (MODELISATION : 'COQUE_3D')
C
C        CETTE ROUTINE EST ANALOGUE A DXSIRO QUI EST
C        OPERATIONELLE POUR LES ELEMENTS DE PLAQUE
C        A L'EXCEPTION DES MATRICES DE PASSAGE QUI
C        SONT DEFINIES EN DES POINTS DE L'ELEMENT.
C
C
C   ARGUMENT        E/S   TYPE     ROLE
C    NP             IN     I    NOMBRE DE POINTS OU SONT CALCULES
C                               LES TENSEURS (I.E. IL S'AGIT DES
C                               NOEUDS OU DES POINTS D'INTEGRATION
C                               DE L'ELEMENT)
C    NSP            IN     I    NOMBRE DE SOUS-POINTS OU SONT CALCULES
C                               LES TENSEURS
C    MATEV(2,2,10)  IN     R    MATRICES DE PASSAGE DES REPERES
C                               INTRINSEQUES AUX POINTS  DE
C                               L'ELEMENT AU REPERE UTILISATEUR
C        MATEV EST OBTENUE PAR VDREPE :
C           MATEVN : POUR UN CHAMP AUX NOEUDS
C           MATEVG : POUR UN CHAMP AUX POINTS DE GAUSS
C    SENS           IN     K2   : "SENS" DU CHANGEMENT DE REPERE :
C                                 / 'IU' : INTRINSEQUE -> UTILISATEUR
C                                 / 'UI' : UTILISATEUR -> INTRINSEQUE
C    GOUN           IN     K1   : /'G' (GAUSS) /'N' (NOEUD)
C      (GOUN NE SERT QUE POUR EVITER UN BUG A CORRIGER)
C    TENS1(1)       IN     R    TENSEURS DES CONTRAINTES OU DES
C                               DEFORMATIONS DANS LE REPERE 1 :
C                                   SIXX SIYY SIXY SIXZ SIYZ
C                               OU  EPXX EPYY EPXY EPXZ EPYZ
C    TENS2(1)       OUT    R    TENSEUR DES CONTRAINTES OU DES
C                               DEFORMATIONS DANS LE REPERE 2
C
C  REMARQUE : ON PEUT APPELER CETTE ROUTINE AVEC LE MEME TABLEAU
C             POUR TENS1 ET TENS2 (PAS D'EFFET DE BORD)
C
C.========================= DEBUT DES DECLARATIONS ====================
C -----  ARGUMENTS
           REAL*8            MATEV(2,2,1), TENS1(1), TENS2(1)
           CHARACTER*2 SENS
           CHARACTER*1 GOUN
           INTEGER NP,NBSP
C -----  VARIABLES LOCALES
           REAL*8    WORKEL(4), WORKLO(4), XAB(2,2)
           REAL*8    TAMPON(2),MATTMP(2,2)
           INTEGER I, KPT, KSP,KPT2
           INTEGER IADZI,IAZK24
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
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
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------
C.========================= DEBUT DU CODE EXECUTABLE ==================
C
      CALL ASSERT(SENS.EQ.'IU'.OR.SENS.EQ.'UI')
      CALL ASSERT(GOUN.EQ.'G'.OR.GOUN.EQ.'N')
C
C --- BOUCLE SUR LES POINTS OU SONT CALCULES LES TENSEURS
C --- (I.E. LES NOEUDS OU LES POINTS D'INTEGRATION) :
C     ============================================
      DO 10 KPT = 1 , NP

C       -- IL Y A UN BUG DANS VDREPE : ON NE CALCULE PAS
C          LES MATRICES POUR FAMI='MASS'
        KPT2=KPT
        IF (GOUN.EQ.'G') KPT2=1

C       -- RECOPIE DE MATEV(KPT) DANS MATTMP :
        MATTMP(1,1)=MATEV(1,1,KPT2)
        MATTMP(2,2)=MATEV(2,2,KPT2)


        IF (SENS.EQ.'IU') THEN
          MATTMP(1,2)=MATEV(1,2,KPT2)
          MATTMP(2,1)=MATEV(2,1,KPT2)
        ELSE
          MATTMP(1,2)=MATEV(2,1,KPT2)
          MATTMP(2,1)=MATEV(1,2,KPT2)
        ENDIF

        DO 20 KSP = 1 , NBSP
          I=(KPT-1)*NBSP+KSP
          WORKEL(1) = TENS1(1+6*(I-1))
          WORKEL(2) = TENS1(4+6*(I-1))
          WORKEL(3) = TENS1(4+6*(I-1))
          WORKEL(4) = TENS1(2+6*(I-1))

          CALL UTBTAB ('ZERO',2,2,WORKEL,MATTMP(1,1),XAB,WORKLO)

          TENS2(1+6*(I-1)) = WORKLO(1)
          TENS2(2+6*(I-1)) = WORKLO(4)
          TENS2(3+6*(I-1)) = TENS1(3+6*(I-1))
          TENS2(4+6*(I-1)) = WORKLO(2)
          TAMPON(1)=TENS1(5+6*(I-1))
          TAMPON(2)=TENS1(6+6*(I-1))
          TENS2(5+6*(I-1)) = TAMPON(1) * MATTMP(1,1) +
     +                       TAMPON(2) * MATTMP(2,1)
          TENS2(6+6*(I-1)) = TAMPON(1) * MATTMP(1,2) +
     +                       TAMPON(2) * MATTMP(2,2)

  20    CONTINUE
  10  CONTINUE
C
C.============================ FIN DE LA ROUTINE ======================
      END
