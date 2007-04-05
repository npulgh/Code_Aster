      SUBROUTINE RCVALC( JMAT,PHENOM,NBPAR,NOMPAR,VALPAR,
     &                   NBRES,NOMRES,VALRES,CODRET, STOP )
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 06/04/2007   AUTEUR PELLET J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
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
      IMPLICIT REAL*8 (A-H,O-Z)
      INTEGER            IMAT,NBPAR,NBRES,JMAT,NBMAT
      CHARACTER*(*)      PHENOM, NOMPAR(NBPAR), NOMRES(NBRES), STOP
      CHARACTER*2        CODRET(NBRES)
      CHARACTER*8        NOMMAT
      REAL*8             VALPAR(NBPAR)
      COMPLEX*16         VALRES(NBRES)
C ----------------------------------------------------------------------
C     OBTENTION DE LA VALEUR VALRES C D'UN "ELEMENT" D'UNE RELATION DE
C     COMPORTEMENT D'UN MATERIAU DONNE (NOUVELLE FORMULE RAPIDE)
C
C     ARGUMENTS D'ENTREE:
C        IMAT   : ADRESSE DU MATERIAU CODE
C        PHENOM : NOM DU PHENOMENE
C        NBPAR  : NOMBRE DE PARAMETRES DANS NOMPAR ET VALPAR
C        NOMPAR : NOMS DES PARAMETRES(EX: TEMPERATURE )
C        VALPAR : VALEURS DES PARAMETRES
C        NBRES  : NOMBRE DE RESULTATS
C        NOMRES : NOM DES RESULTATS (EX: E,NU,... )
C                 TELS QU'IL FIGURENT DANS LA COMMANDE MATERIAU
C     ARGUMENTS DE SORTIE:
C     VALRES : VALEURS DES RESULTATS APRES RECUPERATION ET INTERPOLATION
C     CODRET : POUR CHAQUE RESULTAT, 'OK' SI ON A TROUVE, 'NO' SINON
C
C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------
C
      CHARACTER*32       JEXNUM , JEXNOM , JEXR8 , JEXATR
      INTEGER            ZI
      COMMON  / IVARJE / ZI(1)
      REAL*8             ZR
      COMMON  / RVARJE / ZR(1)
      COMPLEX*16         ZC
      COMMON  / CVARJE / ZC(1)
      LOGICAL            ZL
      COMMON  / LVARJE / ZL(1)
      CHARACTER*8        ZK8
      CHARACTER*16                ZK16
      CHARACTER*24                          ZK24
      CHARACTER*32                                    ZK32
      CHARACTER*80                                              ZK80
      COMMON  / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) , ZK80(1)


C
C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------
C
      CHARACTER*10       NOMPHE
C ----------------------------------------------------------------------
C PARAMETER ASSOCIE AU MATERIAU CODE
C DEB ------------------------------------------------------------------

      NBMAT=ZI(JMAT)
      CALL ASSERT(NBMAT.EQ.1)
      IMAT = JMAT+ZI(JMAT+NBMAT+1)


      DO 130 IRES = 1, NBRES
        CODRET(IRES) = 'NO'
  130 CONTINUE
      NOMPHE = PHENOM
      DO 10 ICOMP=1,ZI(IMAT+1)
        IF ( NOMPHE .EQ. ZK16(ZI(IMAT)+ICOMP-1)(1:10) ) THEN
          IPI = ZI(IMAT+2+ICOMP-1)
          GOTO 11
        ENDIF
 10   CONTINUE
      CALL U2MESS('A','ELEMENTS2_63')
      GOTO 9999
 11   CONTINUE
C
      NBOBJ = 0
      NBR   = ZI(IPI  )
      NBC   = ZI(IPI+1)
      IVALK = ZI(IPI+3)
      IVALC = ZI(IPI+5)
      NBT = NBR + NBC
      DO 150 IR = 1, NBT
        DO 140 IRES = 1, NBRES
          IF (NOMRES(IRES) .EQ. ZK8(IVALK+IR-1)) THEN
            VALRES(IRES) = ZC(IVALC-1+IR)
            CODRET(IRES) = 'OK'
            NBOBJ = NBOBJ + 1
          ENDIF
  140   CONTINUE
  150 CONTINUE
      IF (NBOBJ .NE. NBRES) THEN
        IDF = ZI(IPI)+ZI(IPI+1)
        NBF = ZI(IPI+2)
        DO 170 IRES = 1,NBRES
          DO 160 IK = 1,NBF
            IF (NOMRES(IRES) .EQ. ZK8(IVALK+IDF+IK-1)) THEN
              CALL U2MESS('F','MODELISA6_93')
C              CALL FOINTA (IFON,NBPAR,NOMPAR,VALPAR,VALRES(IRES))
              CODRET(IRES) = 'OK'
            ENDIF
  160     CONTINUE
  170   CONTINUE
      ENDIF
 9999 CONTINUE
C
      CALL RCVALS( STOP, CODRET, NBRES, NOMRES )
C
      END
