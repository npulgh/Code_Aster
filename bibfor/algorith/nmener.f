      SUBROUTINE NMENER(VALINC,VEASSE,MEASSE,SDDYNA,ETA   ,
     &                  SDENER,FONACT,SOLVEU,NUMEDD,NUMFIX,
     &                  MEELEM,NUMINS,MODELE,MATE  ,CARELE,
     &                  COMPOR,CARCRI,SDTIME,SDDISC,SOLALG,
     &                  LISCHA,COMREF,RESOCO,RESOCU,PARCON,
     &                  VEELEM)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
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
C RESPONSABLE IDOUX L.IDOUX
C TOLE CRP_21
C
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      CHARACTER*19  SDDYNA,SDENER,VALINC(*),VEASSE(*),MEASSE(*)
      CHARACTER*19  SOLVEU,MEELEM(*),SDDISC,SOLALG(*),LISCHA,VEELEM(*)
      CHARACTER*24  NUMEDD,NUMFIX,MODELE,MATE,CARELE,COMPOR,CARCRI
      CHARACTER*24  SDTIME,COMREF,RESOCO,RESOCU
      REAL*8        ETA,PARCON(*)
      INTEGER       FONACT(*),NUMINS
C
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (ALGORITHME - CALCUL)
C
C CALCUL DES ENERGIES
C
C ----------------------------------------------------------------------
C
C IN  VALINC : VARIABLE CHAPEAU POUR INCREMENTS VARIABLES
C IN  VEASSE : VARIABLE CHAPEAU POUR NOM DES VECT_ASSE
C IN  MEASSE : VARIABLE CHAPEAU POUR NOM DES MATR_ASSE
C IN  SDDYNA : SD DYNAMIQUE
C IN  ETA    : COEFFICIENT DU PILOTAGE
C IN  SDENER : SD ENERGIE
C IN  FONACT : FONCTIONNALITES ACTIVEES
C IN  SOLVEU : SOLVEUR
C IN  NUMEDD : NUME_DDL
C IN  NUMFIX : NUME_DDL (FIXE AU COURS DU CALCUL)
C IN  MEELEM : MATRICES ELEMENTAIRES
C IN  NUMINS : NUMERO D'INSTANT
C IN  MODELE : MODELE
C IN  MATE   : CHAMP MATERIAU
C IN  CARELE : CARACTERISTIQUES DES ELEMENTS DE STRUCTURE
C IN  COMPOR : COMPORTEMENT
C IN  CARCRI : PARAMETRES METHODES D'INTEGRATION LOCALES (VOIR NMLECT)
C IN  SDTIME : SD TIMER
C IN  SDDISC : SD DISCRETISATION TEMPORELLE
C IN  SOLALG : VARIABLE CHAPEAU POUR INCREMENTS SOLUTIONS
C IN  LISCHA : LISTE DES CHARGES
C IN  COMREF : VARI_COM DE REFERENCE
C IN  DEFICO : SD DEF. CONTACT
C IN  RESOCO : SD RESOLUTION CONTACT
C IN  RESOCU : SD RESOLUTION LIAISON_UNILATER
C IN  PARCON : PARAMETRES DU CRITERE DE CONVERGENCE REFERENCE
C                     1 : SIGM_REFE
C                     2 : EPSI_REFE
C                     3 : FLUX_THER_REFE
C                     4 : FLUX_HYD1_REFE
C                     5 : FLUX_HYD2_REFE
C                     6 : VARI_REFE
C                     7 : EFFORT (FORC_REFE)
C                     8 : MOMENT (FORC_REFE)
C IN  VEELEM : VECTEURS ELEMENTAIRES
C
C
C
C
      INTEGER      NVEASS,LONG
      PARAMETER    (NVEASS=33)
      CHARACTER*19 DEPMOI,DEPPLU,VITMOI,VITPLU,MASSE,AMORT,RIGID
      CHARACTER*19 FEXMOI,FEXPLU,FAMMOI,FNOMOI
      CHARACTER*19 FAMPLU,FLIMOI,FLIPLU,FNOPLU
      CHARACTER*19 LISBID
      CHARACTER*24 K8B
      CHARACTER*8  K8BID
      INTEGER      IDEPMO,IDEPPL,IVITMO,IVITPL
      INTEGER      NEQ,I,J,IVEASS
      INTEGER      IFEXMO,IFAMMO,IFLIMO,IFNOMO
      INTEGER      IFEXPL,IFAMPL,IFLIPL,IFNOPL
      INTEGER      IFEXTE,IFAMOR,IFLIAI,IFCINE,IRET(NVEASS),IFNODA
      LOGICAL      NDYNLO,LDYNA,LAMOR,LEXPL,REASSM
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
      K8BID=' '
      REASSM=.FALSE.
      CALL NMCHEX(VALINC,'VALINC','DEPMOI',DEPMOI)
      CALL JEVEUO(DEPMOI//'.VALE','L',IDEPMO)
      CALL NMCHEX(VALINC,'VALINC','DEPPLU',DEPPLU)
      CALL JEVEUO(DEPPLU//'.VALE','L',IDEPPL)
      CALL JELIRA(DEPMOI//'.VALE','LONMAX',NEQ,K8B)
      LDYNA=NDYNLO(SDDYNA,'DYNAMIQUE')
      LAMOR=NDYNLO(SDDYNA,'MAT_AMORT')
      LEXPL=NDYNLO(SDDYNA,'EXPLICITE')
      IF (LDYNA) THEN
        CALL NMCHEX(VALINC,'VALINC','VITMOI',VITMOI)
        CALL JEVEUO(VITMOI//'.VALE','L',IVITMO)
        CALL NMCHEX(VALINC,'VALINC','VITPLU',VITPLU)
        CALL JEVEUO(VITPLU//'.VALE','L',IVITPL)
      ENDIF
      CALL NMCHEX(VALINC,'VALINC','FEXMOI',FEXMOI)
      CALL NMCHEX(VALINC,'VALINC','FEXPLU',FEXPLU)
      CALL NMCHEX(VALINC,'VALINC','FAMMOI',FAMMOI)
      CALL NMCHEX(VALINC,'VALINC','FNOMOI',FNOMOI)
      CALL NMCHEX(VALINC,'VALINC','FAMPLU',FAMPLU)
      CALL NMCHEX(VALINC,'VALINC','FLIMOI',FLIMOI)
      CALL NMCHEX(VALINC,'VALINC','FLIPLU',FLIPLU)
      CALL NMCHEX(VALINC,'VALINC','FNOPLU',FNOPLU)
      CALL NMCHEX(MEASSE,'MEASSE','MERIGI',RIGID)
      CALL NMCHEX(MEASSE,'MEASSE','MEMASS',MASSE)
      CALL NMCHEX(MEASSE,'MEASSE','MEAMOR',AMORT)
C
      CALL NMCHAI('VEASSE','LONMAX',LONG  )
      CALL ASSERT(LONG.EQ.NVEASS)
      DO 10 I=1,NVEASS
        IRET(I)=0
        CALL JEEXIN(VEASSE(I)//'.VALE',IRET(I))
 10   CONTINUE
C
      CALL JEVEUO(FEXMOI//'.VALE','L',IFEXMO)
      CALL JEVEUO(FAMMOI//'.VALE','L',IFAMMO)
      CALL JEVEUO(FLIMOI//'.VALE','L',IFLIMO)
      CALL JEVEUO(FNOMOI//'.VALE','L',IFNOMO)
      CALL JEVEUO(FEXPLU//'.VALE','E',IFEXPL)
      CALL JEVEUO(FAMPLU//'.VALE','E',IFAMPL)
      CALL JEVEUO(FLIPLU//'.VALE','E',IFLIPL)
      CALL JEVEUO(FNOPLU//'.VALE','E',IFNOPL)
C
      DO 20 I=1,NEQ
        ZR(IFEXPL-1+I)=0.D0
        ZR(IFAMPL-1+I)=0.D0
        ZR(IFLIPL-1+I)=0.D0
        ZR(IFNOPL-1+I)=0.D0
 20   CONTINUE
C
      CALL WKVECT('FEXTE','V V R',2*NEQ,IFEXTE)
      CALL WKVECT('FAMOR','V V R',2*NEQ,IFAMOR)
      CALL WKVECT('FLIAI','V V R',2*NEQ,IFLIAI)
      CALL WKVECT('FNODA','V V R',2*NEQ,IFNODA)
      CALL WKVECT('FCINE','V V R',NEQ,IFCINE)
C
C RECUPERATION DES DIFFERENTES CONTRIBUTIONS AUX VECTEURS DE FORCE
C
      DO 30 I=1,NVEASS
        IF (IRET(I).NE.0) THEN
          CALL JEVEUO(VEASSE(I)//'.VALE','L',IVEASS)
C --------------------------------------------------------------------
C 7  - CNFEDO : CHARGES MECANIQUES FIXES DONNEES
C 9  - CNLAPL : FORCES DE LAPLACE
C 11 - CNFSDO : FORCES SUIVEUSES
C 15 - CNSSTF : FORCES ISSUES DU CALCUL PAR SOUS-STRUCTURATION
C --------------------------------------------------------------------
          IF ((I.EQ.7 ).OR.(I.EQ.9 ).OR.(I.EQ.11).OR.(I.EQ.15)) THEN
            DO 40 J=1,NEQ
              ZR(IFEXPL-1+J)=ZR(IFEXPL-1+J)+ZR(IVEASS-1+J)
 40         CONTINUE
C --------------------------------------------------------------------
C 20 - CNVCF0 : FORCE DE REFERENCE LIEE AUX VAR. COMMANDES EN T+
C --------------------------------------------------------------------
          ELSE IF (I.EQ.20) THEN
            DO 50 J=1,NEQ
              ZR(IFEXPL-1+J)=ZR(IFEXPL-1+J)+ZR(IVEASS-1+J)
 50         CONTINUE
C ON AJOUTE LES CONTRAINTES ISSUES DES VARIABLES DE COMMANDE AUX
C FORCES INTERNES EGALEMENT
            DO 51 J=1,NEQ
              ZR(IFNOPL-1+J)=ZR(IFNOPL-1+J)+ZR(IVEASS-1+J)
 51         CONTINUE
C --------------------------------------------------------------------
C 8  - CNFEPI : FORCES PILOTEES PARAMETRE ETA A PRENDRE EN COMPTE
C --------------------------------------------------------------------
          ELSE IF (I.EQ.8) THEN
            DO 60 J=1,NEQ
              ZR(IFEXPL-1+J)=ZR(IFEXPL-1+J)+ETA*ZR(IVEASS-1+J)
 60         CONTINUE
C --------------------------------------------------------------------
C 2  - CNDIRI : BtLAMBDA                : IL FAUT PRENDRE L OPPOSE
C 10 - CNONDP : CHARGEMENT ONDES PLANES : IL FAUT PRENDRE L OPPOSE
C --------------------------------------------------------------------
          ELSE IF ((I.EQ.2).OR.(I.EQ.10)) THEN
            DO 70 J=1,NEQ
              ZR(IFEXPL-1+J)=ZR(IFEXPL-1+J)-ZR(IVEASS-1+J)
 70         CONTINUE
C --------------------------------------------------------------------
C 27 - CNMODC : FORCE D AMORTISSEMENT MODAL
C --------------------------------------------------------------------
          ELSE IF (I.EQ.27) THEN
            DO 80 J=1,NEQ
              ZR(IFAMPL-1+J)=ZR(IFAMPL-1+J)+ZR(IVEASS-1+J)
 80         CONTINUE
C --------------------------------------------------------------------
C 16 - CNELTC : FORCES ELEMENTS DE CONTACT (CONTINU + XFEM)
C 17 - CNELTF : FORCES ELEMENTS DE FROTTEMENT (CONTINU + XFEM)
C 31 - CNIMPC : FORCES IMPEDANCE
C 23 - CNCTDF : FORCES DE FROTTEMENT (CONTACT DISCRET)
C 28 - CNCTDC : FORCES DE CONTACT (CONTACT DISCRET)
C 29 - CNUNIL : FORCES DE CONTACT (LIAISON_UNILATERALE)
C --------------------------------------------------------------------
          ELSE IF ((I.EQ.16).OR.(I.EQ.17).OR.(I.EQ.31).OR.
     &             (I.EQ.23).OR.(I.EQ.28).OR.(I.EQ.29)) THEN
            DO 90 J=1,NEQ
              ZR(IFLIPL-1+J)=ZR(IFLIPL-1+J)+ZR(IVEASS-1+J)
 90         CONTINUE
            IF ((I.EQ.16).OR.(I.EQ.17)) THEN
C ON ENLEVE LA CONTRIBUTION DU CONTACT (CONTINU + XFEM) DANS
C LES FORCES INTERNES (VOIR ROUTINE NMAINT)
              DO 91 J=1,NEQ
                ZR(IFNOPL-1+J)=ZR(IFNOPL-1+J)-ZR(IVEASS-1+J)
 91           CONTINUE
            ENDIF
C CNDIRI CONTIENT BTLAMBDA PLUS CONTRIBUTION CNCTDF DU CONTACT.
C ON SOUHAITE AJOUTER -BT.LAMBDA A FEXTE. ON AJOUTE DONC -CNDIRI,
C MAIS IL FAUT ALORS LUI RETRANCHER -CNCTDF.
            IF (I.EQ.23) THEN
              DO 92 J=1,NEQ
                ZR(IFEXPL-1+J)=ZR(IFEXPL-1+J)+ZR(IVEASS-1+J)
 92          CONTINUE
            ENDIF
C --------------------------------------------------------------------
C 33 - CNVISS : CHARGEMENT VEC_ISS (FORCE_SOL)
C --------------------------------------------------------------------
          ELSEIF (I.EQ.33) THEN
C CHARGEMENT FORCE_SOL CNVISS. SI ON COMPTE SA CONTRIBUTION EN TANT
C QUE FORCE DISSIPATIVE DE LIAISON, ON DOIT PRENDRE L OPPOSE.
            DO 100 J=1,NEQ
              ZR(IFLIPL-1+J)=ZR(IFLIPL-1+J)-ZR(IVEASS-1+J)
 100        CONTINUE
C --------------------------------------------------------------------
C  1  - CNFINT : FORCES INTERNES
C --------------------------------------------------------------------
          ELSEIF (I.EQ.1) THEN
C CONTIENT UNE CONTRIBUTION DU CONTACT QU ON ENLEVE PAR AILLEURS.
C CONTIENT LA CONTRIBUTION DES MACRO ELEMENTS.
            DO 110 J=1,NEQ
              ZR(IFNOPL-1+J)=ZR(IFNOPL-1+J)+ZR(IVEASS-1+J)
 110        CONTINUE
C --------------------------------------------------------------------
C 21 - CNCINE : INCREMENTS DE DEPLACEMENT IMPOSES (AFFE_CHAR_CINE)
C --------------------------------------------------------------------
          ELSEIF (I.EQ.21) THEN
C ON DOIT RECONSTRUIRE LA MATRICE DE MASSE CAR ELLE A ETE MODIFIEE
C POUR SUPPRIMER DES DEGRES DE LIBERTE EN RAISON DE AFFE_CHAR_CINE.
            REASSM=.TRUE.
            DO 120 J=1,NEQ
              ZR(IFCINE-1+J)=ZR(IFCINE-1+J)+ZR(IVEASS-1+J)
 120        CONTINUE
          ENDIF
        ENDIF
 30   CONTINUE
C
      IF (REASSM) THEN
C --- REASSEMBLAGE DE LA MATRICE DE MASSE.
        LISBID=' '
        CALL NMMASS(FONACT,LISBID,SDDYNA,SOLVEU,NUMEDD,
     &              NUMFIX,MEELEM,MASSE)
      ENDIF
C
C --- INITIALISATION DE LA FORCE EXTERIEURE ET DES FORCES INTERNES
C --- AU PREMIER PAS DE TEMPS.
C --- ON LE FAIT ICI AFIN DE DISPOSER D UNE MATRICE D AMORTISSEMENT.
C
      IF (NUMINS.EQ.1) THEN
        CALL NMFINI(SDDYNA,VALINC,MEASSE,MODELE,MATE  ,
     &              CARELE,COMPOR,CARCRI,SDTIME,SDDISC,
     &              NUMINS,SOLALG,LISCHA,COMREF,RESOCO,
     &              RESOCU,NUMEDD,PARCON,VEELEM,VEASSE)
      ENDIF
C
C --- PREPARATION DES CHAMPS DE FORCE
C
      DO 130 I=1,NEQ
        ZR(IFEXTE-1+I+NEQ)=ZR(IFEXPL-1+I)
        ZR(IFEXTE-1+I)=ZR(IFEXMO-1+I)
        ZR(IFLIAI-1+I+NEQ)=ZR(IFLIPL-1+I)
        ZR(IFLIAI-1+I)=ZR(IFLIMO-1+I)
        ZR(IFAMOR-1+I+NEQ)=ZR(IFAMPL-1+I)
        ZR(IFAMOR-1+I)=ZR(IFAMMO-1+I)
        ZR(IFNODA-1+I+NEQ)=ZR(IFNOPL-1+I)
        ZR(IFNODA-1+I)=ZR(IFNOMO-1+I)
 130  CONTINUE
C
      CALL ENERCA(VALINC    ,ZR(IDEPMO),ZR(IVITMO),ZR(IDEPPL),
     &            ZR(IVITPL),MASSE     ,AMORT     ,RIGID     ,
     &            ZR(IFEXTE),ZR(IFAMOR),ZR(IFLIAI),ZR(IFNODA),
     &            ZR(IFCINE),LAMOR     ,LDYNA     ,LEXPL     ,
     &            SDENER    ,K8BID)
C
C     ON NE PEUT PAS UTILISER NMFPAS POUR METTRE LES CHAMPS PLUS
C     EN CHAMP MOINS, SINON CA POSE PROBLEME EN LECTURE D'ETAT INITIAL
C     SI POURSUITE.
C     ON FAIT DONC LE REPORT DE CHAMP ICI
C
      CALL COPISD('CHAMP_GD','V',FEXPLU,FEXMOI)
      CALL COPISD('CHAMP_GD','V',FAMPLU,FAMMOI)
      CALL COPISD('CHAMP_GD','V',FLIPLU,FLIMOI)
      CALL COPISD('CHAMP_GD','V',FNOPLU,FNOMOI)
C
      CALL JEDETR('FEXTE')
      CALL JEDETR('FAMOR')
      CALL JEDETR('FLIAI')
      CALL JEDETR('FNODA')
      CALL JEDETR('FCINE')
C
      CALL JEDEMA()
C
      END
