      SUBROUTINE NMFCOR(MODELE,NUMEDD,MATE  ,CARELE,COMREF,
     &                  COMPOR,LISCHA,FONACT,PARMET,CARCRI,
     &                  METHOD,NUMINS,ITERAT,SDSTAT,SDTIME,
     &                  SDDISC,SDDYNA,SDNUME,SDERRO,DEFICO,
     &                  RESOCO,RESOCU,PARCON,VALINC,SOLALG,
     &                  VEELEM,VEASSE,MEELEM,MEASSE,MATASS,
     &                  LERRIT)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 24/09/2012   AUTEUR ABBAS M.ABBAS 
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
C TOLE CRP_21
C
      IMPLICIT     NONE
      INCLUDE 'jeveux.h'
      INTEGER      FONACT(*)
      INTEGER      ITERAT,NUMINS
      REAL*8       PARMET(*)
      REAL*8       PARCON(*)
      CHARACTER*16 METHOD(*)
      CHARACTER*24 SDSTAT,SDTIME
      CHARACTER*19 SDDISC,SDDYNA,SDNUME
      CHARACTER*19 LISCHA,MATASS
      CHARACTER*24 MODELE,NUMEDD,MATE,CARELE,COMREF,COMPOR
      CHARACTER*24 CARCRI,SDERRO
      CHARACTER*19 MEELEM(*),VEELEM(*),MEASSE(*),VEASSE(*)
      CHARACTER*19 SOLALG(*),VALINC(*)
      CHARACTER*24 DEFICO,RESOCU,RESOCO
      LOGICAL      LERRIT
C
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (ALGORITHME)
C
C MISE A JOUR DES EFFORTS APRES CALCUL DE LA CORRECTION DES CHAMPS
C DEPLACEMENTS/VITESSES ACCELERATIONS
C
C ----------------------------------------------------------------------
C
C
C IN  MODELE : MODELE
C IN  NUMEDD : NUME_DDL
C IN  MATE   : CHAMP MATERIAU
C IN  CARELE : CARACTERISTIQUES DES ELEMENTS DE STRUCTURE
C IN  COMREF : VARI_COM DE REFERENCE
C IN  COMPOR : COMPORTEMENTC IN  LISCHA : LISTE DES CHARGES
C IN  SDDYNA : SD POUR LA DYNAMIQUE
C IN  SDTIME : SD TIMER
C IN  SDSTAT : SD STATISTIQUES
C IN  FONACT : FONCTIONNALITES ACTIVEES
C IN  SDTIME : SD TIMER
C IN  PARMET : PARAMETRES DES METHODES DE RESOLUTION
C IN  CARCRI : PARAMETRES DES METHODES D'INTEGRATION LOCALES
C IN  METHOD : INFORMATIONS SUR LES METHODES DE RESOLUTION
C IN  ITERAT : NUMERO D'ITERATION DE NEWTON
C IN  NUMINS : NUMERO D'INSTANT
C IN  SDDISC : SD DISCRETISATION TEMPORELLE
C IN  SDERRO : GESTION DES ERREURS
C IN  DEFICO : SD DEFINITION CONTACT
C IN  RESOCO : SD RESOLUTION CONTACT
C IN  RESOCU : SD RESOLUTION LIAISON_UNILATERALE
C IN  PARCON : PARAMETRES DU CRITERE DE CONVERGENCE REFERENCE
C IN  VALINC : VARIABLE CHAPEAU POUR INCREMENTS VARIABLES
C IN  SOLALG : VARIABLE CHAPEAU POUR INCREMENTS SOLUTIONS
C IN  VEELEM : VARIABLE CHAPEAU POUR NOM DES VECT_ELEM
C IN  VEASSE : VARIABLE CHAPEAU POUR NOM DES VECT_ASSE
C IN  MEELEM : VARIABLE CHAPEAU POUR NOM DES MATR_ELEM
C IN  MEASSE : VARIABLE CHAPEAU POUR NOM DES MATR_ASSE
C IN  SDNUME : SD NUMEROTATION
C OUT LERRIT : .TRUE. SI ERREUR PENDANT CORRECTION
C
C ----------------------------------------------------------------------
C
      LOGICAL      LCFINT,LCRIGI,LCDIRI,LCBUDI
      CHARACTER*24 CODERE
      CHARACTER*19 VEFINT,VEDIRI,VEBUDI,CNFINT,CNDIRI,CNBUDI
      CHARACTER*19 DEPPLU,VITPLU,ACCPLU
      CHARACTER*16 OPTION
      LOGICAL      ISFONC,LCTCD,LUNIL,LELTC
      INTEGER      LDCCVG
      INTEGER      IFM,NIV
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFDBG('MECA_NON_LINE',IFM,NIV)
C
C --- AFFICHAGE
C
      IF (NIV.GE.2) THEN
        WRITE (IFM,*) '<MECANONLINE> CORRECTION DES FORCES'
      ENDIF
C
C --- INITIALISATIONS CODES RETOURS
C
      LDCCVG = -1
      CODERE = '&&NMFCOR.CODERE'
C
C --- FONCTIONNALITES ACTIVEES
C
      LUNIL  = ISFONC(FONACT,'LIAISON_UNILATER')
      LCTCD  = ISFONC(FONACT,'CONT_DISCRET')
      LELTC  = ISFONC(FONACT,'ELT_CONTACT')
C
C --- DECOMPACTION DES VARIABLES CHAPEAUX
C
      CALL NMCHEX(VALINC,'VALINC','DEPPLU',DEPPLU)
      CALL NMCHEX(VALINC,'VALINC','VITPLU',VITPLU)
      CALL NMCHEX(VALINC,'VALINC','ACCPLU',ACCPLU)
      CALL NMCHEX(VEELEM,'VEELEM','CNDIRI',VEDIRI)
      CALL NMCHEX(VEELEM,'VEELEM','CNBUDI',VEBUDI)
      CALL NMCHEX(VEELEM,'VEELEM','CNFINT',VEFINT)
      CALL NMCHEX(VEASSE,'VEASSE','CNDIRI',CNDIRI)
      CALL NMCHEX(VEASSE,'VEASSE','CNFINT',CNFINT)
      CALL NMCHEX(VEASSE,'VEASSE','CNBUDI',CNBUDI)
C
C --- CALCUL DES CHARGEMENTS VARIABLES AU COURS DU PAS DE TEMPS
C
      CALL NMCHAR('VARI','CORRECTION' ,
     &            MODELE,NUMEDD,MATE  ,CARELE,COMPOR,
     &            LISCHA,CARCRI,NUMINS,SDTIME,SDDISC,
     &            PARCON,FONACT,RESOCO,RESOCU,COMREF,
     &            VALINC,SOLALG,VEELEM,MEASSE,VEASSE,
     &            SDDYNA)
C
C --- CALCUL DU SECOND MEMBRE POUR CONTACT/XFEM
C
      IF (LELTC) THEN
        CALL NMFOCC('CONVERGENC',
     &              MODELE,MATE  ,NUMEDD,FONACT,DEFICO,
     &              RESOCO,SOLALG,VALINC,VEELEM,VEASSE)
      ENDIF
C
C --- OPTION POUR MERIMO
C
      CALL NMCHFI(PARMET,METHOD,FONACT,SDDISC,SDDYNA,
     &            NUMINS,ITERAT,DEFICO,LCFINT,LCDIRI,
     &            LCBUDI,LCRIGI,OPTION)
C
C --- CALCUL DES FORCES INTERNES ET DE LA RIGIDITE SI NECESSAIRE
C
      IF (LCFINT) THEN
        IF (LCRIGI) THEN
          CALL NMRIGI(MODELE,MATE  ,CARELE,COMPOR,CARCRI,
     &                SDDYNA,SDSTAT,SDTIME,FONACT,ITERAT,
     &                VALINC,SOLALG,COMREF,MEELEM,VEELEM,
     &                OPTION,LDCCVG,CODERE)
        ELSE
          CALL NMFINT(MODELE,MATE  ,CARELE,COMREF,COMPOR,
     &                CARCRI,FONACT,ITERAT,SDDYNA,SDSTAT,
     &                SDTIME,VALINC,SOLALG,LDCCVG,CODERE,
     &                VEFINT)
        ENDIF
      ENDIF
C
C --- ERREUR SANS POSSIBILITE DE CONTINUER
C
      IF (LDCCVG.EQ.1) GOTO 9999
C
C --- CALCUL DES FORCES DE CONTACT ET LIAISON_UNILATER
C
      CALL NMTIME(SDTIME,'INI','SECO_MEMB')
      CALL NMTIME(SDTIME,'RUN','SECO_MEMB')
      IF (LCTCD.OR.LUNIL) THEN
        CALL NMCTCD(MODELE,MATE  ,CARELE,FONACT,COMPOR,
     &              CARCRI,SDTIME,SDDISC,SDDYNA,NUMINS,
     &              VALINC,SOLALG,LISCHA,COMREF,DEFICO,
     &              RESOCO,RESOCU,NUMEDD,PARCON,VEELEM,
     &              VEASSE,MEASSE)
      ENDIF
C
C --- ASSEMBLAGE DES FORCES INTERIEURES
C
      IF (LCFINT) THEN
        CALL NMAINT(NUMEDD,FONACT,DEFICO,VEASSE,VEFINT,
     &              CNFINT,SDNUME)
      ENDIF
C
C --- CALCUL ET ASSEMBLAGE DES REACTIONS D'APPUI BT.LAMBDA
C
      IF (LCDIRI) THEN
        CALL NMDIRI(MODELE,MATE  ,CARELE,LISCHA,SDDYNA,
     &              DEPPLU,VITPLU,ACCPLU,VEDIRI)
        CALL NMADIR(NUMEDD,FONACT,DEFICO,VEASSE,VEDIRI,
     &              CNDIRI)
      ENDIF
C
C --- CALCUL ET ASSEMBLAGE DE B.U
C
      CALL NMBUDI(MODELE,NUMEDD,LISCHA,DEPPLU,VEBUDI,
     &            CNBUDI,MATASS)
C
      CALL NMTIME(SDTIME,'END','SECO_MEMB')
C
 9999 CONTINUE
C
C --- TRANSFORMATION DES CODES RETOURS EN EVENEMENTS
C
      CALL NMCRET(SDERRO,'LDC',LDCCVG)
C
C --- EVENEMENT ERREUR ACTIVE ?
C
      CALL NMLTEV(SDERRO,'ERRI','NEWT',LERRIT)
C
      CALL JEDEMA()
      END
