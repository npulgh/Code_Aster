      SUBROUTINE RCVALA( JMAT, NOMAT, PHENOM, NBPAR, NOMPAR, VALPAR,
     &                   NBRES, NOMRES, VALRES, ICODRE, IARRET)
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      INTEGER            IMAT, NBPAR, NBRES,IARRET
      REAL*8             VALPAR(NBPAR), VALRES(NBRES)
      INTEGER        ICODRE(NBRES)
      CHARACTER*(*)      NOMAT,PHENOM,NOMPAR(NBPAR),NOMRES(NBRES)
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C
C     OBTENTION DE LA VALEUR VALRES D'UN "ELEMENT" D'UNE RELATION DE
C     COMPORTEMENT D'UN MATERIAU DONNE
C
C     ARGUMENTS D'ENTREE:
C        JMAT   : ADRESSE DE LA LISTE DE MATERIAU CODE
C        NOMAT  : NOM DU MATERIAU DANS LE CAS D'UNE LISTE DE MATERIAU
C                 SI = ' ', ON EXPLOITE LE PREMIER DE LA LISTE
C        PHENOM : NOM DU PHENOMENE
C        NBPAR  : NOMBRE DE PARAMETRES DANS NOMPAR ET VALPAR
C        NOMPAR : NOMS DES PARAMETRES(EX: TEMPERATURE )
C        VALPAR : VALEURS DES PARAMETRES
C        NBRES  : NOMBRE DE RESULTATS
C        NOMRES : NOM DES RESULTATS (EX: E,NU,... )
C                 TELS QU'IL FIGURENT DANS LA COMMANDE MATERIAU
C       IARRET = 0 : ON REMPLIT ICODRE ET ON SORT SANS MESSAGE.
C              = 1 : SI UN DES PARAMETRES N'EST PAS TROUVE, ON ARRETE
C                       EN FATAL EN INDIQUANT LE NOM DE LA MAILLE.
C              = 2 : IDEM QUE 1 MAIS ON N'INDIQUE PAS LA MAILLE.
C
C     ARGUMENTS DE SORTIE:
C     VALRES : VALEURS DES RESULTATS APRES RECUPERATION ET INTERPOLATION
C     ICODRE : POUR CHAQUE RESULTAT, 0 SI ON A TROUVE, 1 SINON
C
C ----------------------------------------------------------------------
C     ------------------------------------------------------------------
C --- PARAMETER ASSOCIE AU MATERIAU CODE
      INTEGER      LMAT, LFCT, LSUP
      PARAMETER  ( LMAT = 7 , LFCT = 9 , LSUP = 2 )
C
      INTEGER       IRES, ICOMP, IPI, IADZI, IAZK24, NBOBJ, NBR, NBC,
     &              NBF,IVALK,IVALR,IR,IPIF,IK,NBMAT,JMAT,KMAT,INOM
      CHARACTER*8   NOMAIL,NOMI
      CHARACTER*10 NOMPHE
      CHARACTER*24  VALK(2)
C DEB ------------------------------------------------------------------
C
C     -- ON EST OBLIGE DE RECOPIER PHENOM CAR IL FAUT LE TRONQUER
C        PARFOIS A 10 AVANT DE LE COMPARER
      NOMPHE=PHENOM
C
C  ON EXPLORE L'ENTETE DE LA SD MATER_CODE POUR DETERMINER LE MATERIAU
C  DE LA LA LISTE
C
      NBMAT=ZI(JMAT)
      IF (NOMAT(1:1).NE.' ') THEN
        DO 5 KMAT =1,NBMAT
          INOM=ZI(JMAT+KMAT)
          NOMI=ZK8(INOM)
          IF ( NOMI .EQ. NOMAT ) THEN
            IMAT = JMAT+ZI(JMAT+NBMAT+KMAT)
            GOTO 9
          ENDIF
 5      CONTINUE
        CALL U2MESK('F','MODELISA6_92',1,NOMAT)
      ELSE
        IMAT = JMAT+ZI(JMAT+NBMAT+1)
      ENDIF
C
 9    CONTINUE
C
C  ON TRAITE LE MATERIAU SELECTIONNE DANS LA LISTE
C
      DO 10 IRES = 1 , NBRES
        ICODRE(IRES) = 1
 10   CONTINUE
      DO 20 ICOMP = 1 , ZI(IMAT+1)
        IF ( NOMPHE .EQ. ZK16(ZI(IMAT)+ICOMP-1)(1:10)) THEN
          IPI = ZI(IMAT+2+ICOMP-1)
          GOTO 22
        ENDIF
 20   CONTINUE
C
C --- SELON LA VALEUR DE IARRET ON ARRETE OU NON :
      IF (IARRET.GE.1) THEN
         VALK(1)=NOMPHE
         IF ( IARRET .EQ. 1 ) THEN
            CALL TECAEL ( IADZI, IAZK24 )
            NOMAIL  = ZK24(IAZK24-1+3)(1:8)
            VALK(2) = NOMAIL
            CALL U2MESK('F','MODELISA9_75',2,VALK)
         ELSE
            CALL U2MESK('F','MODELISA9_74',1,VALK)
         ENDIF
      END IF
      GOTO 999
C
 22   CONTINUE
C
      NBOBJ = 0
      NBR   = ZI(IPI)
      NBC   = ZI(IPI+1)
      NBF   = ZI(IPI+2)
      IVALK = ZI(IPI+3)
      IVALR = ZI(IPI+4)
      DO 32 IRES = 1, NBRES
        DO 30 IR = 1, NBR
            IF ( NOMRES(IRES) .EQ. ZK8(IVALK+IR-1) ) THEN
               VALRES(IRES) = ZR(IVALR-1+IR)
               ICODRE(IRES) = 0
               NBOBJ = NBOBJ + 1
               GOTO 32
            ENDIF
 30     CONTINUE
 32   CONTINUE
C
      IF (NBOBJ .NE. NBRES) THEN
         DO 40 IRES = 1,NBRES
            IPIF = IPI+LMAT-1
            DO 42 IK = 1,NBF
               IF ( NOMRES(IRES) .EQ. ZK8(IVALK+NBR+NBC+IK-1) ) THEN
                  CALL FOINTA (IPIF,NBPAR,NOMPAR,VALPAR,VALRES(IRES))
                  ICODRE(IRES) = 0
               ENDIF
               IPIF = IPIF + LFCT
               IF (  NOMPHE(1:8) .EQ. 'TRACTION' ) THEN
                  IPIF = IPIF + LSUP
               ELSEIF ( NOMPHE.EQ. 'META_TRACT' ) THEN
                  IPIF = IPIF + LSUP
               ENDIF
 42         CONTINUE
 40      CONTINUE
      ENDIF
C
 999  CONTINUE
C
      CALL RCVALS( IARRET, ICODRE, NBRES, NOMRES )
C
      END
