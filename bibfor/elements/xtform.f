      SUBROUTINE XTFORM(NDIM  ,TYPMAE,TYPMAM,TYPMAC,NNE  ,
     &                  NNM   ,NNC   ,COORE ,COORM ,COORC ,
     &                  FFE   ,FFM   ,DFFC  )
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 19/12/2012   AUTEUR PELLET J.PELLET 
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
C RESPONSABLE ABBAS M.ABBAS
C
      IMPLICIT NONE
      CHARACTER*8 TYPMAE,TYPMAM,TYPMAC
      REAL*8      COORC(2),COORE(3),COORM(3)
      INTEGER     NDIM,NNM,NNC,NNE
      REAL*8      FFE(20)
      REAL*8      FFM(20)
      REAL*8      DFFC(3,9)
C
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODE XFEMGG - CALCUL ELEM.)
C
C CALCUL DES FONCTIONS DE FORME ET DE LEUR DERIVEES
C
C ----------------------------------------------------------------------
C ROUTINE SPECIFIQUE A L'APPROCHE <<GRANDS GLISSEMENTS AVEC XFEM>>,
C TRAVAIL EFFECTUE EN COLLABORATION AVEC I.F.P.
C ----------------------------------------------------------------------
C
C
C IN  NDIM   : DIMENSION DU MODELE
C IN  NNM    : NOMBRE DE NOEUDS DE LA MAILLE MAITRE
C IN  NNC    : NOMBRE DE NOEUDS DE LA MAILLE DE CONTACT
C IN  NNE    : NOMBRE DE NOEUDS DE LA MAILLE ESCLAVE
C IN  TYPMAE : TYPE DE LA MAILLE ESCLAVE
C IN  TYPMAM : TYPE DE LA MAILLE MAITRE
C IN  TYPMAC : TYPE DE LA MAILLE DE CONTACT
C IN  COORC  : COORDONNEES DU POINT DE CONTACT
C IN  COORE  : LES COORDONNEES ESCLAVES DANS L'ELEMENT PARENT
C IN  COORM  : LES COORDONNEES MAITRES DANS L'ELEMENT PARENT
C OUT FFE    : FONCTIONS DE FORMES ESCLAVES
C OUT FFM    : FONCTIONS DE FORMES MAITRES
C OUT DFFC   : DERIVEES PREMIERES DES FONCTIONS DE FORME LAGR. CONTACT
C
C ----------------------------------------------------------------------
C
      INTEGER IBID
C
C ----------------------------------------------------------------------
C
C
C --- DERIVEES DES FONCTIONS DE FORMES POUR LE PT DE CONTACT DANS
C --- L'ELEMENT DE CONTACT
C
      CALL ELRFDF(TYPMAC,COORC,NNC*NDIM,DFFC,IBID,IBID)
C
C --- FONCTIONS DE FORMES DU POINTS DE CONTACT DANS L'ELEMENT PARENT
C
      CALL ELRFVF(TYPMAE,COORE,NNE,FFE,NNE)
C
C --- FONCTIONS DE FORMES DE LA PROJ DU PT DE CONTACT DANS L'ELE PARENT
C
      IF (NNM.NE.0) CALL ELRFVF(TYPMAM,COORM,NNM,FFM,NNM)


      END
