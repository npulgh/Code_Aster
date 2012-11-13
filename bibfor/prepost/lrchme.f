      SUBROUTINE LRCHME ( CHANOM, NOCHMD, NOMAMD,
     &                    NOMAAS, TYPECH, NOMGD, TYPENT,
     &                    NBCMPV, NCMPVA, NCMPVM, PROLZ,
     &                    IINST, NUMPT,  NUMORD, INST, CRIT, PREC,
     &                    NROFIC, OPTION, PARAM,
     &                    NBPGMA, NBPGMM, CODRET )
C TOLE CRP_21
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 12/11/2012   AUTEUR SELLENET N.SELLENET 
C RESPONSABLE SELLENET N.SELLENET
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
C     LECTURE D'UN CHAMP NOEUD/ELEMENT - FORMAT MED
C     -    -       --                           --
C-----------------------------------------------------------------------
C     ENTREES:
C        CHANOM  : NOM ASTER DU CHAMP A LIRE
C        NOCHMD : NOM MED DU CHAMP DANS LE FICHIER
C        NOMAMD : NOM MED DU MAILLAGE LIE AU CHAMP A LIRE
C                  SI ' ' : ON SUPPOSE QUE C'EST LE PREMIER MAILLAGE
C                           DU FICHIER
C        NOMAAS : NOM ASTER DU MAILLAGE
C        TYPECH : TYPE DU CHAMP
C        TYPENT : TYPE D'ENTITE DU CHAMP 
C                (MED_NOEUD=3,MED_MAILLE=0,MED_NOEUD_MAILLE=4)
C        NOMGD  : NOM DE LA GRANDEUR ASSOCIEE AU CHAMP
C        NBCMPV : NOMBRE DE COMPOSANTES VOULUES
C                 SI NUL, ON LIT LES COMPOSANTES A NOM IDENTIQUE
C        NCMPVA : LISTE DES COMPOSANTES VOULUES POUR ASTER
C        NCMPVM : LISTE DES COMPOSANTES VOULUES DANS MED
C        PROLZ  : VALEUR DE PROL_ZERO ('OUI' OU 'NAN')
C        IINST  : 1 SI LA DEMANDE EST FAITE SUR UN INSTANT, 0 SINON
C        NUMPT  : NUMERO DE PAS DE TEMPS EVENTUEL
C        NUMORD : NUMERO D'ORDRE EVENTUEL DU CHAMP
C        INST   : INSTANT EVENTUEL
C        CRIT   : CRITERE SUR LA RECHERCHE DU BON INSTANT
C        PREC   : PRECISION SUR LA RECHERCHE DU BON INSTANT
C        NROFIC : NUMERO NROFIC LOGIQUE DU FICHIER MED
C        OPTION / PARAM : POUR CREER LE CHAMP COMME S'IL ETAIT LE
C                 PARAMETRE EN SORTIE DE CETTE OPTION (CHAMPS ELGA)
C     SORTIES:
C        CODRET : CODE DE RETOUR (0 : PAS DE PB, NON NUL SI PB)
C_____________________________________________________________________
C
      IMPLICIT NONE
C
C 0.1. ==> ARGUMENTS
C
      CHARACTER*19  CHANOM
      CHARACTER*(*) NCMPVA, NCMPVM
      CHARACTER*8   NOMAAS
      CHARACTER*8   NOMGD, TYPECH
      CHARACTER*3   PROLZ
      CHARACTER*8   CRIT, PARAM
      CHARACTER*24  OPTION
      CHARACTER*64  NOCHMD, NOMAMD
C
      INTEGER NROFIC, TYPENT
      INTEGER CODRET
      INTEGER NBCMPV
      INTEGER IINST, NUMPT, NUMORD
      INTEGER NBPGMA(*),NBPGMM(*)
C
      REAL*8 INST
      REAL*8 PREC
C
C 0.2. ==> COMMUNS
C
C 0.3. ==> VARIABLES LOCALES
C
C
      CHARACTER*8 NOMMOD
      INTEGER     IAUX
      INTEGER      IARG
C
C====
C 1. LECTURE DANS LE FICHIER MED
C====
C
C
      IF ( TYPECH(1:2).EQ.'NO' ) THEN
        CALL LRCNME ( CHANOM,  NOCHMD, NOMAMD,
     &                NOMAAS, NOMGD, TYPENT,
     &                NBCMPV, NCMPVA, NCMPVM,
     &                IINST, NUMPT, NUMORD, INST, CRIT, PREC,
     &                NROFIC, CODRET )
      ELSEIF ( TYPECH(1:2).EQ.'EL'.OR.TYPECH(1:2).EQ.'CA' ) THEN
        CALL GETVID ( ' ', 'MODELE', 0,IARG, 1, NOMMOD, IAUX )
        IF ( IAUX.EQ.0.AND.TYPECH(1:4).NE.'CART' ) THEN
          CALL U2MESS('F','MED_71')
        ENDIF
        IF ( IAUX.EQ.0 ) NOMMOD = ' '
        CALL LRCEME ( CHANOM,  NOCHMD, TYPECH(1:4), NOMAMD,
     &                NOMAAS, NOMMOD, NOMGD, TYPENT,
     &                NBCMPV, NCMPVA, NCMPVM, PROLZ,
     &                IINST, NUMPT, NUMORD, INST, CRIT, PREC,
     &                NROFIC, OPTION, PARAM,
     &                NBPGMA, NBPGMM, CODRET )
      ELSE
        CODRET = 1
        CALL U2MESK('A','MED_92',1,TYPECH(1:4))
      ENDIF
C
C====
C 2. BILAN
C====
C
      IF ( CODRET.NE.0 ) THEN
        CALL U2MESK('A','MED_55',1,CHANOM)
      ENDIF
C
      END
