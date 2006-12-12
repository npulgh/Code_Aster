      SUBROUTINE NTDOED ( INITPR, RESULT, NUMINI, TEMPIN )
C
C     THERMIQUE - DONNEES EN TEMPS POUR LES DERIVEES
C     *           **      *                 *
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 13/12/2006   AUTEUR PELLET J.PELLET 
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
C RESPONSABLE GNICOLAS G.NICOLAS
C
C ----------------------------------------------------------------------
C SAISIE DU TYPE DE CALCUL ET DU CHAMP INITIAL DES PB DERIVE
C
C IN  INITPR : TYPE D'INITIALISATION DU CALCUL PRINCIPAL
C              -1 : PAS D'INITIALISATION. (VRAI STATIONNAIRE)
C               0 : CALCUL STATIONNAIRE
C               1 : VALEUR UNIFORME
C               2 : CHAMP AUX NOEUDS
C               3 : RESULTAT D'UN AUTRE CALCUL
C IN  RESULT : NOM DU RESULTAT PRECEDENT SI INITPR = 3
C IN  NUMINI : NUMERO D'ORDRE DU CALCUL PRECEDENT SI INITPR = 3
C OUT TEMPIN : CHAMP DE TEMPERATURE INITIALE
C   -------------------------------------------------------------------
C     SUBROUTINES APPELLEES:
C       JEVEUX: JEMARQ,JEDEMA,JEVEUO,JELIRA.
C       MANIP. SD: RSEXCH.
C       MSG: UTDEBM,UTIMPI,UTFINM.
C
C     FONCTIONS INTRINSEQUES:
C       AUCUNE.
C   -------------------------------------------------------------------
C     ASTER INFORMATIONS:
C       30/11/01 (OB): MISE A JOUR DES INITIALISATIONS.
C----------------------------------------------------------------------
C CORPS DU PROGRAMME
      IMPLICIT NONE

C 0.1. ==> ARGUMENTS

      INTEGER INITPR, NUMINI
      CHARACTER*24 RESULT, TEMPIN

C 0.2. ==> COMMUNS

C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------
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
C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------

C 0.3. ==> VARIABLES LOCALES
      CHARACTER*6 NOMPRO
      PARAMETER ( NOMPRO = 'NTDOED' )

      CHARACTER*8  K8BID
      INTEGER IRET,I,NDDL,JTEMPI

C     ------------------------------------------------------------------

      CALL JEMARQ()

C====
C 1. ON CHOISIT EN FONCTION DU MODE D'INITIALISATION DE LA TEMPERATURE
C====

C 1.1. ==> TEMPERATURE UNIFORME OU CHAMP AU NOEUDS==> PB DERIVEE INITI
C          ALISE PAR UN CAUCHY NUL.

      IF ((INITPR.EQ.1).OR.(INITPR.EQ.2)) THEN

        CALL JEVEUO(TEMPIN(1:19)//'.VALE','E',JTEMPI)
        CALL JELIRA(TEMPIN(1:19)//'.VALE','LONMAX',NDDL,K8BID)

        DO 11 , I = 1 , NDDL
          ZR(JTEMPI+I-1) = 0.D0
   11   CONTINUE

C 1.2. ==> RECUPERATION D'UN CHAM_NO DE TEMPERATURE A PARTIR D'UNE
C          STRUCTURE DE DONNEES RESULTAT ==> IDEM SUR LE RESULTAT DERIVE

      ELSE IF ( INITPR.EQ.3 ) THEN

        CALL RSEXCH(RESULT,'TEMP',NUMINI,TEMPIN,IRET)
        IF ( IRET.GT.0 ) THEN
          CALL U2MESS('F','ALGORITH9_1')
        ENDIF

C 1.3. ==> LES AUTRES CHOIX QUE STATIONNAIRE SONT INTERDITS

      ELSE

        IF ( INITPR.NE.-1 .AND. INITPR.NE.0 ) THEN

          CALL UTDEBM ( 'A', NOMPRO, 'CHOIX IMPOSSIBLE' )
          CALL UTIMPI ( 'S', 'POUR INITPR : ', 1, INITPR )
          CALL UTFINM
          CALL U2MESS('F','MODELISA_67')

        ENDIF

      ENDIF

      CALL JEDEMA()

      END
