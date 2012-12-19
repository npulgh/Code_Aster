      SUBROUTINE XMVEC2(NDIM,NNO,NNOS,NNOL,PLA,
     &                  FFC,FFP,REAC,JAC,NFH,SAUT,
     &                  SINGU,ND,RR,COEFFR,DDLS,DDLM,
     &                  JFISNO,NFISS,IFISS,JHEAFA,NCOMPH,IFA,
     &                  VTMP )

      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      INTEGER     NDIM,NNO,NNOS,NNOL
      INTEGER     PLA(27),NFH
      INTEGER     SINGU,DDLS,DDLM,JFISNO,NFISS,IFISS,JHEAFA,NCOMPH,IFA
      REAL*8      VTMP(400),COEFFR,SAUT(3),ND(3)
      REAL*8      FFC(8),FFP(27),JAC,REAC,RR

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

C TOLE CRP_21
C
C ROUTINE CONTACT (METHODE XFEM HPP - CALCUL ELEM.)
C
C --- CALCUL DU VECTEUR LN1 & LN2
C
C ----------------------------------------------------------------------
C
C IN  NDIM   : DIMENSION DE L'ESPACE
C IN  NNO    : NOMBRE DE NOEUDS DE L'ELEMENT DE REF PARENT
C IN  NNOS   : NOMBRE DE NOEUDS SOMMET DE L'ELEMENT DE REF PARENT
C IN  NNOL   : NOMBRE DE NOEUDS PORTEURS DE DDLC
C IN  NNOF   : NOMBRE DE NOEUDS DE LA FACETTE DE CONTACT
C IN  PLA    : PLACE DES LAMBDAS DANS LA MATRICE
C IN  IPGF   : NUM�RO DU POINTS DE GAUSS
C IN  IVFF   : ADRESSE DANS ZR DU TABLEAU FF(INO,IPG)
C IN  FFC    : FONCTIONS DE FORME DE L'ELEMENT DE CONTACT
C IN  FFP    : FONCTIONS DE FORME DE L'ELEMENT PARENT
C IN  IDEPD  :
C IN  IDEPM  :
C IN  NFH    : NOMBRE DE FONCTIONS HEAVYSIDE
C IN  NOEUD  : INDICATEUR FORMULATION (T=NOEUDS , F=ARETE)
C IN  TAU1   : TANGENTE A LA FACETTE AU POINT DE GAUSS
C IN  TAU2   : TANGENTE A LA FACETTE AU POINT DE GAUSS
C IN  SINGU  : 1 SI ELEMENT SINGULIER, 0 SINON
C IN  RR     : DISTANCE AU FOND DE FISSURE
C IN  IFA    : INDICE DE LA FACETTE COURANTE
C IN  CFACE  : CONNECTIVIT� DES NOEUDS DES FACETTES
C IN  LACT   : LISTE DES LAGRANGES ACTIFS
C IN  DDLS   : NOMBRE DE DDL (DEPL+CONTACT) � CHAQUE NOEUD SOMMET
C IN  DDLM   : NOMBRE DE DDL A CHAQUE NOEUD MILIEU
C IN  RHOTK  :
C IN  COEFFR : COEFFICIENTS DE AUGMENTATION DU FROTTEMENT
C IN  P      :
C OUT ADHER  :
C OUT KNP    : PRODUIT KN.P
C OUT PTKNP  : MATRICE PT.KN.P
C OUT IK     :
C
C
C

C
      INTEGER I,J,IN,PLI,IFH,COEFI
      REAL*8  FFI,DN
      LOGICAL LMULTC
C
C ----------------------------------------------------------------------
C
      COEFI = 2
      LMULTC = NFISS.GT.1
      DN = 0.D0
      DO 143 J = 1,NDIM
        DN = DN + SAUT(J)*ND(J)
 143  CONTINUE
C
C --- TERME LN1
C
        DO 150 I = 1,NNO
          CALL INDENT(I,DDLS,DDLM,NNOS,IN)
          DO 157 IFH = 1,NFH
            IF (LMULTC) THEN
              COEFI = ZI(JHEAFA-1+NCOMPH*(NFISS*(IFISS-1)
     &                  +ZI(JFISNO-1+NFH*(I-1)+IFH)-1)+2*IFA)
     &              - ZI(JHEAFA-1+NCOMPH*(NFISS*(IFISS-1)
     &                  +ZI(JFISNO-1+NFH*(I-1)+IFH)-1)+2*IFA-1)
            ENDIF
            DO 151 J = 1,NDIM
              VTMP(IN+NDIM*IFH+J) = VTMP(IN+NDIM*IFH+J) +
     &        (REAC-COEFFR*DN)*COEFI*FFP(I)*ND(J)*JAC
 151        CONTINUE
 157      CONTINUE
          DO 152 J = 1,SINGU*NDIM
            VTMP(IN+NDIM*(1+NFH)+J) = VTMP(IN+NDIM*(1+NFH)+J) +
     &      (REAC-COEFFR*DN)*COEFI*FFP(I)*RR*ND(J)*JAC
 152      CONTINUE
 150    CONTINUE
C
C --- TERME LN2
C
       DO 160 I = 1,NNOL
         PLI=PLA(I)
         FFI=FFC(I)

         VTMP(PLI) = VTMP(PLI) - DN * FFI * JAC

 160     CONTINUE
      END
