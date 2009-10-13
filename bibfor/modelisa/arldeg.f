      SUBROUTINE ARLDEG(TMSUIN,TYMA1 ,TYMA2  ,TYPEMA,NUMERO,
     &                  NMAMA ,NFAM  ,FAM)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 13/10/2009   AUTEUR CAO B.CAO 
C ======================================================================
C COPYRIGHT (C) 1991 - 2002  EDF R&D                  WWW.CODE-ASTER.ORG
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
C
C
C ======================================================================
C RESPONSABLE MEUNIER S.MEUNIER
C
      IMPLICIT NONE
      CHARACTER*8 TMSUIN
      CHARACTER*8 TYMA1
      CHARACTER*8 TYMA2
      CHARACTER*8 TYPEMA(*)
      INTEGER     NUMERO(*)
      INTEGER     NMAMA(*)
      INTEGER     NFAM
      INTEGER     FAM
C
C ----------------------------------------------------------------------
C
C ROUTINE ARLEQUIN
C
C SELECTION DE LA FAMILLE DE QUADRATURE POUR INTEGRER COUPLAGE ARLEQUIN
C
C ----------------------------------------------------------------------
C
C
C IN  TMSUIN : TYPE DE LA MAILLE SUPPORT INTEGRATION
C IN  TYMA1  : TYPE DE LA PREMIERE MAILLE DE DISCRETISATION
C IN  TYMA2  : TYPE DE LA SECONDE MAILLE DE DISCRETISATION
C I/O TYPEMA : TYPE DE LA MAILLE SUPPORT (TMSUIN) POUR
C              CHAQUE FAMILLE (TMSUIN FAM.1, TMSUIN FAM.2, ...)
C I/O NUMERO : NUMERO DE LA FORMULE D'INTEGRATION (NFI)
C              (NFI FAM.1, NFI FAM.2, ...)
C I/O NMAMA  : NOMBRE DE COUPLES DE MAILLE (NCM) ASSOCIE
C              A CHAQ FAMILLE (NCM FAM.1, NCM FAM.2, ...)
C I/O NFAM   : NOMBRE DE FAMILLES DE QUADRATURE
C OUT FAM    : NUMERO DE LA FAMILLE
C
C ----------------------------------------------------------------------
C
      INTEGER     TYPEDG,FCIG,IAUX
      INTEGER     DEGMS(4),DEGM1(4),DEGM2(4)
      LOGICAL     ISEXIS
      INTEGER     DEGCPL
C
C ----------------------------------------------------------------------
C
C
C --- DEGRE DU POLYNOME A INTEGRER POUR LA MAILLE SUPPORT
C
      TYPEDG = 0
      CALL FORMEN(TMSUIN ,TYPEDG,DEGMS)
C
C --- DEGRE DU POLYNOME A INTEGRER POUR LA PREMIERE MAILLE
C
      CALL FORMEN(TYMA1,TYPEDG,DEGM1)
C
C --- DEGRE DU POLYNOME A INTEGRER POUR LA SECONDE MAILLE
C
      CALL FORMEN(TYMA2,TYPEDG,DEGM2)
C
C --- DEGRE DU POLYNOME DE L'INTEGRANDE POUR TERME DE COUPLAGE
C
      DEGCPL = DEGM1(1)+DEGM2(1)+DEGMS(3)
C
C --- CHOIX DE LA FORMULE D'INTEGRATION
C
      CALL NPGAUS(TMSUIN,DEGCPL,FCIG)
C
C --- RECHERCHE SI LA FAMILLE (TMSUIN,FCIG) EXISTE DEJA
C
      ISEXIS = .FALSE.
      DO 10 IAUX = 1, NFAM
        IF ((TMSUIN.EQ.TYPEMA(IAUX)).AND.(FCIG.EQ.NUMERO(IAUX))) THEN
          ISEXIS = .TRUE.
          GOTO 20
        ENDIF
 10   CONTINUE
 20   CONTINUE
C
C --- AJOUT DE LA FAMILLE (TMSUIN,FCIG)
C
      IF (.NOT.ISEXIS) THEN
        NFAM         = NFAM + 1
        TYPEMA(NFAM) = TMSUIN
        NUMERO(NFAM) = FCIG
        IAUX         = NFAM
      ENDIF
C
C --- NOUVEAU COUPLE POUR CETTE FAMILLE
C
      NMAMA(IAUX) = NMAMA(IAUX) + 1
      FAM      = IAUX

      END
