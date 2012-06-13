      SUBROUTINE GKSIMP ( RESULT, NNOFF, ABSC, IADRGK, NUMERO, IADGKS,
     &                  NDEG, NDIMTE, IADGKI, EXTIM, TIME, IORDR, UNIT )
      IMPLICIT  NONE

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
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
C
C     - FONCTION REALISEE:  IMPRESSION DU TAUX DE RESTITUTION D'ENERGIE
C                           ET DES FACTEURS D'INTENSITES DE CONTRAINTES
C                           LOCALS SUIVANT LA METHODE CHOISIE
C                           DANS LE CADRE DE X-FEM
C  ENTREE
C
C    RESULT       --> NOM UTILISATEUR DU RESULTAT ET TABLE
C    NNOFF        --> NOMBRE DE POINTS DU FOND DE FISSURE
C    ABSC         --> ABSCISSES CURVILIGNES
C    IADRGK       --> ADRESSE DE VALEURS DE GKTHI
C                 (G, K1, K2, K3, BETA POUR LES CHAMPS THETAI)
C
C    NUMERO       --> NUMERO DE LA METHODE   1 : THETA-LEGENDRE
C                                            2 : THETA-LAGRANGE
C                                            3 ou 4 : LAGRANGE-LAGRANGE
C    IADGKS       --> ADRESSE DE VALEURS DE GKS
C                      (VALEUR DE G(S), K1(S), K2(S), K3(S), BETA(S))
C    NDEG         --> DEGRE DU POLYNOME DE LEGENDRE
C    IADGKI       --> ADRESSE DES VALEURS ELEMENTAIRES AVANT LISSAGE
C                      (VALEUR DE G(S), K1(S), K2(S), K3(S))
C    EXTIM        --> .TRUE. => TIME EXISTE
C    TIME         --> INSTANT DE CALCUL A IMPRIMER
C    IORDR        --> NUMERO D'ORDRE A IMPRIMER
C    UNIT         --> UNITE DU FICHIER D'AFFICHAGE
C ......................................................................
C
      INCLUDE 'jeveux.h'
      INTEGER         NNOFF, UNIT, NUMERO, NDEG, IORDR, I, I1,IMOD
      INTEGER         IADRGK, IADGKS, IADGKI, NDIMTE
      REAL*8            TIME, ABSC(*)
      LOGICAL         EXTIM
      CHARACTER*8    RESULT
C
C
C
C
      WRITE(UNIT,*)
C
      IF (NUMERO.EQ.1) THEN
         WRITE(UNIT,555) NDEG
      ELSE IF (NUMERO.EQ.2) THEN
         WRITE(UNIT,556) NDEG
      ELSE IF (NUMERO.EQ.3) THEN
         WRITE(UNIT,557)
      ELSE IF (NUMERO.EQ.4) THEN
         WRITE(UNIT,558)
      ELSE IF (NUMERO.EQ.5) THEN
         WRITE(UNIT,559)
      ENDIF
      WRITE(UNIT,666)
      WRITE(UNIT,*)
C
      WRITE(UNIT,*)  'NOM DU RESULTAT : ',RESULT
      WRITE(UNIT,*)
      IF(EXTIM) THEN
        WRITE(UNIT,*) '          INSTANT : ',TIME
        WRITE(UNIT,*) '          +++++++'
      ELSE IF (IORDR.NE.0) THEN
        WRITE(UNIT,*) '          NUMERO D''ORDRE : ',IORDR
        WRITE(UNIT,*) '          ++++++++++++++'
      ENDIF
      WRITE(UNIT,*)

C- IMPRESSION DU TAUX DE RESTITUTION D ENERGIE G

      WRITE(UNIT,*) 'TAUX DE RESTITUTION D''ENERGIE LOCAL G'
      WRITE(UNIT,667)

      IF ( NUMERO .NE. 1 ) THEN
        WRITE(UNIT,770)
        WRITE(UNIT,*)
        WRITE(UNIT,*) ' NOEUD    GELEM(THETAI)'
        WRITE(UNIT,*)
        IF ( NUMERO .EQ. 5 ) THEN
          DO 20 I=1,NDIMTE
            WRITE(UNIT,110) I,ZR(IADGKI-1+(I-1)*5+1)
20        CONTINUE
        ELSE
          DO 21 I=1,NNOFF
            WRITE(UNIT,110) I,ZR(IADGKI-1+(I-1)*5+1)
21        CONTINUE
        ENDIF
        WRITE(UNIT,*)
      ENDIF
C
      IF ( (NUMERO.EQ.1) .OR. (NUMERO.EQ.2) ) THEN
        WRITE(UNIT,771)
        WRITE(UNIT,*)
        DO 10 I=1,NDEG+1
           I1 = I-1
           WRITE(UNIT,*) 'DEGRE ',I1,' : ',ZR(IADGKI-1+I1*5+1)
10      CONTINUE
        WRITE(UNIT,*)
      ENDIF
C
      WRITE(UNIT,*) 'VALEUR DE G AUX POINTS DE FOND DE FISSURE'
      WRITE(UNIT,*)  ' ABSC_CURV       G(S)'
      WRITE(UNIT,*)
      DO 30 I=1,NNOFF
         WRITE(UNIT,111) ABSC(I), ZR(IADGKS-1+(I-1)*6+1)
30    CONTINUE
      WRITE(UNIT,*)
C

C- IMPRESSION DES FACTEURS D INTENSITE DE CONTRAINTE K

      DO 40 IMOD=1,3
        WRITE(UNIT,750) IMOD
        WRITE(UNIT,667)
        IF ( NUMERO .NE. 1 ) THEN
          WRITE(UNIT,772) IMOD
          WRITE(UNIT,*)
          WRITE(UNIT,773) IMOD
          WRITE(UNIT,*)
          IF ( NUMERO .EQ. 5 ) THEN
            DO 401 I=1,NDIMTE
              WRITE(UNIT,110) I,ZR(IADGKI-1+(I-1)*5+IMOD+1)
401         CONTINUE
          ELSE
            DO 402 I=1,NNOFF
              WRITE(UNIT,110) I,ZR(IADGKI-1+(I-1)*5+IMOD+1)
402         CONTINUE
          ENDIF
          WRITE(UNIT,*)
        ENDIF
        IF ( (NUMERO.EQ.1) .OR. (NUMERO.EQ.2) ) THEN
          WRITE(UNIT,751) IMOD
          WRITE(UNIT,*)
          DO 41 I=1,NDEG+1
            I1 = I-1
            WRITE(UNIT,*) 'DEGRE ',I1,' : ',ZR(IADGKI-1+I1*5+IMOD+1)
41        CONTINUE
          WRITE(UNIT,*)
        ENDIF

        WRITE(UNIT,752) IMOD
        WRITE(UNIT,753) IMOD
        WRITE(UNIT,*)
        DO 42 I=1,NNOFF
           WRITE(UNIT,111) ABSC(I), ZR(IADGKS-1+(I-1)*6+IMOD+1)
42      CONTINUE
        WRITE(UNIT,*)
40    CONTINUE

C- IMPRESSION DE L'ANGLE DE PROPAGATION DE FISSURE BETA

      WRITE(UNIT,*) 'ANGLE DE PROPAGATION DE FISSURE BETA'
      WRITE(UNIT,667)
C
      WRITE(UNIT,*) 'VALEUR DE BETA AUX POINTS DE FOND DE FISSURE'
      WRITE(UNIT,*)  ' ABSC_CURV       BETA(S)'
      WRITE(UNIT,*)
      DO 50 I=1,NNOFF
         WRITE(UNIT,111) ABSC(I), ZR(IADGKS-1+(I-1)*6+6)
50    CONTINUE
      WRITE(UNIT,*)
C
C- IMPRESSION DE G_IRWIN

      WRITE(UNIT,*) 'G_IRWIN (RECALCULE A PARTIR DE K1, K2 ET K3)'
      WRITE(UNIT,667)
C
      WRITE(UNIT,*) 'VALEUR DE G_IRWIN AUX POINTS DE FOND DE FISSURE'
      WRITE(UNIT,*)  ' ABSC_CURV       G_IRWIN(S)'
      WRITE(UNIT,*)
      DO 60 I=1,NNOFF
         WRITE(UNIT,111) ABSC(I), ZR(IADGKS-1+(I-1)*6+5)
60    CONTINUE
      WRITE(UNIT,*)
C
110   FORMAT(1X,I2,6X,1PD12.5)
111   FORMAT(1X,2(1PD12.5,4X))
555   FORMAT('THETA_LEGENDRE  G_LEGENDRE (DEGRE ',I2,')')
556   FORMAT('THETA_LAGRANGE  G_LEGENDRE (DEGRE ',I2,')')
557   FORMAT('THETA_LAGRANGE  G_LAGRANGE')
558   FORMAT('THETA_LAGRANGE  G_LAGRANGE_NO_NO')
559   FORMAT('THETA_LAGRANGE_REGU  G_LAGRANGE_REGU')
666   FORMAT(37('*'))
667   FORMAT(37('+'))

750   FORMAT('FACTEUR D''INTENSITE DE CONTRAINTE K',I1)
751   FORMAT('COEF DE K',I1,'(S) DANS LA BASE DE POLY DE LEGENDRE : ')
752   FORMAT('VALEUR DE K',I1,' AUX POINTS DE FOND DE FISSURE')
753   FORMAT(' ABSC_CURV       K',I1,'(S)')

770   FORMAT('VALEURS DE G ELEMENTAIRES AVANT LISSAGE :')
771   FORMAT('COEF DE G(S) DANS LA BASE DE POLYNOMES DE LEGENDRE :')
772   FORMAT('VALEURS DE K',I1,' ELEMENTAIRES AVANT LISSAGE :')
773   FORMAT(' NOEUD    K',I1,'ELEM(THETAI)')
C
      END
