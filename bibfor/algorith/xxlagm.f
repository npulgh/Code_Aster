        SUBROUTINE XXLAGM(FFC   ,IDEPL ,IDEPM ,
     &                    LACT  ,NDIM  ,
     &                    NNOL  ,PLA   ,REAC  ,REAC12,
     &                    TAU1  ,TAU2,NVEC)
       IMPLICIT NONE
      INCLUDE 'jeveux.h'

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
C IN CFACE  : CONNECTIVITE FACETTES DE CONTACT
C IN FFC    : FONCTIONS DE FORME DE CONTACT
C IN IDEPL  : ADRESSE DEPLACEMENT COURANT
C IN IDEPM  : ADRESSE DEPLACEMENT INSTANT -
C IN IFA    : NUMERO FACETTE DE CONTACT
C IN IPGF   : NUMERO POINT DE GAUSS DE CONTACT
C IN IVFF   : ADRESSE FONCTION DE FORME EL PARENT
C IN LACT   : DDL DE LAGRANGE ACTIF OU NON
C IN NDIM   : DIMENSION DU MODELE
C IN NNOF   : NOMBRE DE NOEUDS D UNE FACETTE DE CONTACT
C IN NNOL   : NOMBRE DE NOEUDS EL PARENT PORTEURS DE DDL LAGRANGE
C IN NOEUD  : FORMULATION AUX NOEUDS
C IN PLA    : PLACE DES DDLS DE LAGRANGE
C OUT REAC  : REACTION DE CONTACT AU POINT DE GAUSS
C OUT REAC12: REACTION DE FROTTEMENT AU POINT DE GAUSS
C IN TAU1   : 1ERE TANGENTE SURFACE DE CONTACT
C IN TAU2   : 2EME TANGENTE (3D)
        INTEGER I,IDEPL,IDEPM
        INTEGER J,LACT(8),NDIM,NLI,NNOL
        INTEGER PLA(27),PLI,NVEC
        REAL*8  FFC(8),FFI,REAC,REAC12(3),TAU1(3),TAU2(3)
C
C --- R�ACTION CONTACT = SOMME DES FF(I).LAMBDA(I) POUR I=1,NNOL
C --- R�ACTION FROTT = SOMME DES FF(I).(LAMB1(I).TAU1+LAMB2(I).TAU2)
C --- (DEPDEL+DEPMOI)
        REAC=0.D0
        CALL VECINI(3,0.D0,REAC12)
        DO 120 I = 1,NNOL
           PLI=PLA(I)
           FFI=FFC(I)
           NLI=LACT(I)
           IF (NLI.EQ.0) GOTO 120
           REAC = REAC + 
     &       FFI * ZR(IDEPL-1+PLI)
           IF(NVEC.EQ.2) THEN
           REAC = REAC + 
     &       FFI * ZR(IDEPM-1+PLI)
            ENDIF
           DO 121 J=1,NDIM
             IF (NDIM .EQ.3) THEN
               REAC12(J)=REAC12(J)+FFI*(ZR(IDEPL-1+PLI+1)*TAU1(J)
     &                                 +ZR(IDEPL-1+PLI+2)*TAU2(J))
              IF(NVEC.EQ.2) THEN
               REAC12(J)=REAC12(J)+FFI*(ZR(IDEPM-1+PLI+1)*TAU1(J)
     &                                 +ZR(IDEPM-1+PLI+2)*TAU2(J))
              ENDIF
             ELSEIF (NDIM.EQ.2) THEN
               REAC12(J)=REAC12(J)+FFI*ZR(IDEPL-1+PLI+1)*TAU1(J)
               IF(NVEC.EQ.2) THEN
               REAC12(J)=REAC12(J)+FFI*ZR(IDEPM-1+PLI+1)*TAU1(J)
               ENDIF
             ENDIF
 121       CONTINUE
 120   CONTINUE
      END
