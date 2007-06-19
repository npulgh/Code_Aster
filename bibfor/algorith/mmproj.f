        SUBROUTINE  MMPROJ(ALIAS,NDIM,NNO,GEOM,
     &                     ITEMAX,EPSMAX,TOLEOU,DIRAPP,DIR,
     &                     XI,YI,NORM,TAU1,TAU2,DIST,LDIST,NIVERR)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 05/09/2006   AUTEUR MABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2006  EDF R&D                  WWW.CODE-ASTER.ORG
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
      IMPLICIT NONE
      CHARACTER*8  ALIAS      
      INTEGER      NDIM
      INTEGER      NNO
      REAL*8       GEOM(30)
      LOGICAL      DIRAPP
      REAL*8       DIR(3)
      REAL*8       XI
      REAL*8       YI
      REAL*8       TAU1(3)
      REAL*8       TAU2(3)
      REAL*8       NORM(3)
      REAL*8       DIST
      LOGICAL      LDIST      
      REAL*8       TOLEOU
      INTEGER      NIVERR
      INTEGER      ITEMAX
      REAL*8       EPSMAX
C
C ----------------------------------------------------------------------
C ROUTINE APPELLEE PAR : MMREMA/LISSAG
C ----------------------------------------------------------------------
C
C FAIRE LA PROJECTION D'UN POINT SUR UNE MAILLE DONNEE 
C
C IN  ALIAS  : TYPE DE MAILLE
C IN  NNO    : NOMBRE DE NOEUD SUR LA MAILLE
C IN  NDIM   : DIMENSION DE LA MAILLE (2 OU 3)
C IN  GEOM   : COORDONNEES DU POINT ET DE LA MAILLE
C IN  ITEMAX : NOMBRE MAXI D'ITERATIONS DE NEWTON POUR LA PROJECTION
C IN  EPSMAX : RESIDU POUR CONVERGENCE DE NEWTON POUR LA PROJECTION 
C IN  TOLEOU : TOLERANCE POUR LE PROJETE HORS SURFACE MAITRE
C IN  DIRAPP : VAUT .TRUE. SI APPARIEMENT DANS UNE DIRECTION DE 
C              RECHERCHE DONNEE (PAR DIR)
C IN  DIR    : DIRECTION D'APPARIEMENT
C OUT XI     : PREMIERE COORDONNEE PARAMETRIQUE DU POINT PROJETE
C OUT YI     : SECONDE COORDONNEE PARAMETRIQUE DU POINT PROJETE
C OUT NORM   : NORMALE
C OUT DIST   : DISTANCE ENTRE POINT ET SA PROJECTION SUR LA MAILLE
C OUT TAU1   : PREMIER VECTEUR TANGENT EN XI,YI
C OUT TAU2   : SECOND VECTEUR TANGENT EN XI,YI
C OUT LDIST  : VAUT .FALSE. SI LA PROJECTION EST EN DEHORS
C               DE LA MAILLE
C OUT NIVERR : RETOURNE UN CODE ERREUR
C                0  TOUT VA BIEN
C                1  ELEMENT INCONNU
C                2  MATRICE SINGULIERE (VECTEURS TANGENTS COLINEAIRES)
C                3  DEPASSEMENT NOMBRE ITERATIONS MAX
C                4  VECTEURS TANGENTS NULS
C
C ----------------------------------------------------------------------
C
      REAL*8       TN(9),DR(2,9)
      REAL*8       DDR(3,9)
      REAL*8       VEC(3)
      REAL*8       NTA1,NTA2
      INTEGER      K,I,J
C
C ----------------------------------------------------------------------
C
      NIVERR = 0
C 
C --- ALGO DE NEWTON POUR LA PROJECTION SUIVANT UNE DIRECTION DONNEE
C
      IF (DIRAPP) THEN
        CALL MMNEWD(ALIAS,NNO,NDIM,GEOM,
     &              ITEMAX,EPSMAX,DIR,
     &              XI,YI,TAU1,TAU2,NIVERR)
      ELSE
        CALL MMNEWT(ALIAS,NNO,NDIM,GEOM,
     &              ITEMAX,EPSMAX,
     &              XI,YI,TAU1,TAU2,NIVERR)      
      ENDIF
C
C --- AJUSTEMENT (ON RAMENE DANS LA MAILLE)
C
      CALL MAJUST(ALIAS,XI,YI,TOLEOU,LDIST)
      CALL CALFFD(ALIAS,XI,YI,TN,DR,DDR,NIVERR)
      IF (NIVERR.NE.0) THEN
        GOTO 999
      ENDIF    
C
C --- CALCUL DES VECTEURS TANGENTS
C
      DO 110 K = 1,NDIM
        DO 100 I = 1,NNO
          TAU1(K) = GEOM(3*I+K)*DR(1,I) + TAU1(K)
          IF (NDIM.EQ.3) THEN
            TAU2(K) = GEOM(3*I+K)*DR(2,I) + TAU2(K)
          ENDIF  
  100   CONTINUE
  110 CONTINUE
C
C --- NORMALISATION DES VECTEURS TANGENTS
C
      CALL NORMEV(TAU1,NTA1)
      IF (NDIM.EQ.3) THEN
        CALL NORMEV(TAU2,NTA2)
      ELSE
        NTA2 = 1.D0  
      ENDIF 
      
      IF ((NTA1.EQ.0.D0).OR.(NTA2.EQ.0.D0)) THEN
        NIVERR = 4
        GOTO 999
      ENDIF     
C
C --- DISTANCE POINT DE CONTACT/PROJECTION
C
      DO 90 I = 1,3
        VEC(I)=0.D0
        DO 80 J = 1,NNO
          VEC(I) = GEOM(3*J+I)*TN(J) + VEC(I)
   80   CONTINUE
   90 CONTINUE
   
      DO 140 I = 1,3
        NORM(I) = VEC(I) - GEOM(I)
  140 CONTINUE
      DIST = SQRT(NORM(1)**2+NORM(2)**2+NORM(3)**2)
      
  999 CONTINUE    
   
      END
