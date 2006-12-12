      SUBROUTINE SEMECO ( CHOIX, NOSIMP, NOPASE,
     &                    PREF,
     &                    NOCOMP, NBMOCL, LIMOCL, LIVALE, LIMOFA,
     &                    IRET )
C
C     SENSIBILITE - MEMORISATION DES CORRESPONDANCES
C     **            **               **
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 13/12/2006   AUTEUR PELLET J.PELLET 
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
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C RESPONSABLE GNICOLAS G.NICOLAS
C ----------------------------------------------------------------------
C     MEMORISE LES CORRESPONDANCES ENTRE :
C     . UN COUPLE ( STRUCTURE DE BASE , PARAMETRE DE SENSIBILITE )
C     . ET UNE STRUCTURE COMPOSEE
C     A PRIORI, CE PROGRAMME NE DOIT ETRE APPELE QUE PAR UN AUTRE PSXXXX
C     ------------------------------------------------------------------
C IN  CHOIX   : /'PREFIXE' : ON RETOURNE LE PREFIXE DU NOM DE LA
C                            STRUCTURE DE MEMORISATION
C               /'E' : ON ECRIT DANS LA STRUCTURE DE MEMORISATION
C               /'RENC' : ON RECUPERE LE NOM COMPOSE ASSOCIE A UN NOM
C                         SIMPLE
C               /'REMC' : ON RECUPERE LES MOTS_CLES ASSOCIES A UN COUPLE
C                       ( STRUCTURE DE BASE , PARAMETRE DE SENSIBILITE )
C               /'S' : ON SUPPRIME DANS LA STRUCTURE DE MEMORISATION
C SI CHOIX='PREFIXE' :
C      IN  : AUCUNE DONNEE
C      0UT PREF : NOM DE LA STRUCTURE DE MEMORISATION
C SI CHOIX N'EST PAS 'PREFIXE' :
C IN  NOSIMP  : NOM DE LA SD DE BASE
C IN  NOPASE  : NOM DU PARAMETRE DE SENSIBILITE
C I/O NOCOMP  : NOM DE LA SD DERIVEE :
C    SI CHOIX='E' : NOCOMP EST UNE DONNEE (EVENTUELLEMENT ' ')
C           SI NOCOMP=' ', NOCOMP EST CALCULEE DE LA FORME '_OOOIJKL'
C           SI LE COUPLE (NOSIMP,NOPASE) EST DEJA RENSEIGNE, ERREUR <F>
C    SI CHOIX='RENC' : NOCOMP EST UNE SORTIE
C    SI CHOIX='REMC' : NOCOMP EST INUTILISE
C    SI CHOIX='S' : NOCOMP EST UNE DONNEE
C I/O NBMOCL  : NOMBRE DE MOTS-CLES CONCERNES
C    SI CHOIX='E' : NBMOCL EST UNE DONNEE
C    SI CHOIX='RENC' : NBMOCL EST INUTILISE
C    SI CHOIX='REMC' : NBMOCL EST UNE SORTIE
C    SI CHOIX='S' : NOCOMP EST INUTILISE
C I/O LIMOCL  : NOM DE LA STRUCTURE K80 CONTENANT LES MOTS_CLES
C    SI CHOIX='E' ET NBMOCL NON NUL : LIMOCL EST UNE DONNEE
C    SI CHOIX='RENC' : LIMOCL EST INUTILISE
C    SI CHOIX='REMC' : LIMOCL EST UNE SORTIE, ALLOUEE ICI, SI NBMOCL > 0
C    SI CHOIX='S' : LIMOCL EST INUTILISE
C I/O LIVALE  : NOM DE LA STRUCTURE K80 CONTENANT LES VALEURS
C    SI CHOIX='E' ET NBMOCL NON NUL : LIVALE EST UNE DONNEE
C    SI CHOIX='RENC' : LIVALE EST INUTILISE
C    SI CHOIX='REMC' : LIVALE EST UNE SORTIE, ALLOUEE ICI, SI NBMOCL > 0
C    SI CHOIX='S' : LIVALE EST INUTILISE
C I/O LIMOFA  : NOM DE LA STRUCTURE K80 CONTENANT LES MOTS-CLES FACTEURS
C    SI CHOIX='E' ET NBMOCL NON NUL : LIMOFA EST UNE DONNEE
C    SI CHOIX='RENC' : LIMOFA EST INUTILISE
C    SI CHOIX='REMC' : LIMOFA EST UNE SORTIE, ALLOUEE ICI, SI NBMOCL > 0
C    SI CHOIX='S' : LIMOFA EST INUTILISE
C OUT IRET    : CODE_RETOUR :
C                     0 -> TOUT S'EST BIEN PASSE
C                     1 -> LE COUPLE (NOSIMP,NOPASE) N'EST PAS RENSEIGNE
C                     2 -> LA STRUCTURE DE MEMORISATION EST INCONNUE
C                     3 -> LA STRUCTURE COMPOSEE LIEE AU COUPLE
C                          (NOSIMP,NOPASE) N'EST PAS LA BONNE
C
C  POUR CHAQUE MEMORISATION, NOUS AVONS DANS :
C     . ZK80(I,1) :
C       01-08 : NOM SIMPLE
C       09-16 : NOM DU PARAMETRE SENSIBLE
C       17-24 : NOM COMPOSE
C     . ZK80(I,2) :
C       01-24 : BLANC SI AUCUN MOT-CLE N'EST RENSEIGNE
C               NOM DU ZK80 QUI CONTIENT LA LISTE DES MOTS-CLES
C       25-48 : BLANC SI AUCUN MOT-CLE N'EST RENSEIGNE
C               NOM DU ZK80 QUI CONTIENT LA LISTE DES VALEURS
C       49-72 : BLANC SI AUCUN MOT-CLE N'EST RENSEIGNE
C               NOM DU ZK80 QUI CONTIENT LA LISTE DES MOTS-CLES FACTEURS
C     ------------------------------------------------------------------
C
      IMPLICIT NONE
C
C 0.1. ==> ARGUMENTS
C
      CHARACTER*(*) CHOIX, NOSIMP, NOPASE
      CHARACTER*(*) PREF
      CHARACTER*(*) NOCOMP, LIMOCL, LIVALE, LIMOFA
      INTEGER NBMOCL
      INTEGER IRET
C
C 0.2. ==> COMMUNS
C
C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------
C
C 0.3. ==> VARIABLES LOCALES
C
      CHARACTER*6 NOMPRO
      PARAMETER ( NOMPRO = 'SEMECO' )
C
      CHARACTER*13 PREFIX
      PARAMETER ( PREFIX = '&NOSENSI.MEMO' )
C                           1234567890123
C
      INTEGER LXLGUT
C
      INTEGER ADMOCL, ADVALE, ADMOFA
      INTEGER ADMMEM, ADMEMC, ADMEVA, ADMEMF
      INTEGER LONMAX, NUTI, NUMERO, LGNOCO
      INTEGER IAUX, JAUX, IER
C
      CHARACTER*4 SAUX04
      CHARACTER*6 SAUX06(3)
      CHARACTER*8 NOSIM8, NOPAS8, NOCOM8, SAUX08
      CHARACTER*18 NOMMEM
      CHARACTER*24 NOMMCL, NOMVAL, NOMMFA
      CHARACTER*24 VALK(2)
C
      DATA SAUX06 / 'NOSIMP', 'NOPASE', 'NOCOMP' /
C     ------------------------------------------------------------------
C====
C 1. PREALABLES
C====
C
      CALL JEMARQ()
C
      IRET = 0
C
      IF ( CHOIX.NE.'PREFIXE' ) THEN
C
        NOMMEM = PREFIX // '.CORR'
C                           45678
C
        IF ( CHOIX.EQ.'E' ) THEN
          JAUX = 3
        ELSE
          JAUX = 2
        ENDIF
C
        DO 11 , IAUX = 1 , JAUX
C
          IF ( IAUX.EQ.1 ) THEN
            LGNOCO = LXLGUT(NOSIMP)
          ELSEIF ( IAUX.EQ.2 ) THEN
            LGNOCO = LXLGUT(NOPASE)
          ELSE
            LGNOCO = LXLGUT(NOCOMP)
          ENDIF
C
          IF ( LGNOCO.GT.8 ) THEN
            CALL UTDEBM ( 'A', NOMPRO, 'LA CHAINE '//SAUX06(IAUX) )
            CALL UTIMPI ( 'S', ' EST DE LONGUEUR : ', 1, LGNOCO )
            CALL UTFINM
            CALL U2MESS('A','UTILITAI3_96')
            CALL U2MESS('F','MODELISA_67')
          ELSE
            IF ( IAUX.EQ.1 ) THEN
              NOSIM8 = '        '
              NOSIM8(1:LGNOCO) = NOSIMP(1:LGNOCO)
            ELSEIF ( IAUX.EQ.2 ) THEN
              NOPAS8 = '        '
              NOPAS8(1:LGNOCO) = NOPASE(1:LGNOCO)
            ELSE
              NOCOM8 = '        '
              NOCOM8(1:LGNOCO) = NOCOMP(1:LGNOCO)
            ENDIF
          ENDIF
C
   11   CONTINUE
C
      ENDIF
C
C====
C 2. EN RECUPERATION DU PREFIXE
C====
C
      IF ( CHOIX.EQ.'PREFIXE' ) THEN
C
        IAUX = LEN(PREF)
        DO 21 , JAUX = 1 , IAUX
          PREF(JAUX:JAUX) = ' '
   21   CONTINUE
        JAUX = LEN(PREFIX)
        IF ( IAUX.LT.JAUX ) THEN
          CALL U2MESK('A','UTILITAI4_54',1,PREFIX)
          CALL U2MESS('F','MODELISA_67')
        ENDIF
        PREF(1:JAUX) = PREFIX
C
C====
C 3. EN ECRITURE
C====
C
      ELSEIF ( CHOIX.EQ.'E' ) THEN
C
C 3.1. ==> CREATION OU AGRANDISSEMENT DE NOMMEM SI NECESSAIRE :
C          ON COMMENCE PAR UNE TAILLE DE 1, PUIS ON DOUBLE A CHAQUE
C          FOIS QUE L'ON A BESOIN DE PLUS DE PLACE
C
        CALL JEEXIN (NOMMEM,IER)
        IF (IER.EQ.0) THEN
          NUTI = 1
          CALL WKVECT ( NOMMEM,'G V K80',2*NUTI,ADMMEM )
          CALL JEECRA ( NOMMEM,'LONUTI',NUTI,SAUX08 )
        ELSE
          CALL JELIRA ( NOMMEM,'LONMAX',LONMAX,SAUX08 )
          CALL JELIRA ( NOMMEM,'LONUTI',NUTI,SAUX08 )
          NUTI = NUTI + 1
          IF (2*NUTI.GT.LONMAX) THEN
            CALL JUVECA ( NOMMEM,2*LONMAX )
          END IF
          CALL JEECRA ( NOMMEM,'LONUTI',NUTI,SAUX08 )
          CALL JEVEUO ( NOMMEM,'E',ADMMEM )
        END IF
C
C 3.2. ==> CONTROLE
C
        DO 32 , IAUX = 1 , NUTI - 1
          IF ( (ZK80(ADMMEM+2*IAUX-2) (1: 8).EQ.NOSIM8 ) .AND.
     &         (ZK80(ADMMEM+2*IAUX-2) (9:16).EQ.NOPAS8) ) THEN
             VALK(1) = NOSIM8(1:8)
             VALK(2) = NOPAS8(1:8)
             CALL U2MESK('F','UTILITAI4_55', 2 ,VALK)
          ENDIF
   32   CONTINUE
C
C 3.3. ==> ENREGISTREMENT DU TRIPLET :
C          (NOM SIMPLE, PARAMETRE SENSIBLE, NOM COMPOSE)
C
        DO 33 , IAUX = 1 , 3
C                   12345678
          SAUX08 = '        '
          IF ( IAUX.EQ.1 ) THEN
            LGNOCO = LXLGUT(NOSIM8)
            SAUX08(1:LGNOCO) = NOSIM8(1:LGNOCO)
          ELSEIF ( IAUX.EQ.2 ) THEN
            LGNOCO = LXLGUT(NOPAS8)
            SAUX08(1:LGNOCO) = NOPAS8(1:LGNOCO)
          ELSE
            LGNOCO = LXLGUT(NOCOM8)
            IF ( LGNOCO.EQ.0 .OR. NOCOM8.EQ.' ' ) THEN
              CALL GCNCON ('_', SAUX08 )
            ELSE
              SAUX08(1:LGNOCO) = NOCOM8(1:LGNOCO)
            ENDIF
          ENDIF
C
          ZK80(ADMMEM+2*NUTI-2) (8*(IAUX-1)+1:8*IAUX) = SAUX08
C
   33   CONTINUE
C
C 3.4. ==> ENREGISTREMENT DES MOTS-CLES ASSOCIES
C
        IF ( NBMOCL.NE.0 ) THEN
C
          CALL JEVEUO ( LIMOCL, 'L', ADMOCL )
          CALL JEVEUO ( LIVALE, 'L', ADVALE )
          CALL JEVEUO ( LIMOFA, 'L', ADMOFA )
C
          CALL CODENT ( NUTI, 'G', SAUX04 )
C                  1234567890123           45   6789     01234
          NOMMCL = PREFIX              // '.M'//SAUX04//'     '
          NOMVAL = PREFIX              // '.V'//SAUX04//'     '
          NOMMFA = PREFIX              // '.F'//SAUX04//'     '
          ZK80(ADMMEM+2*NUTI-1) (01:24) = NOMMCL
          ZK80(ADMMEM+2*NUTI-1) (25:48) = NOMVAL
          ZK80(ADMMEM+2*NUTI-1) (49:72) = NOMMFA
C
          CALL WKVECT ( NOMMCL,'G V K80',NBMOCL,ADMEMC )
          CALL JEECRA ( NOMMCL,'LONUTI',NBMOCL,SAUX08 )
          CALL WKVECT ( NOMVAL,'G V K80',NBMOCL,ADMEVA )
          CALL JEECRA ( NOMVAL,'LONUTI',NBMOCL,SAUX08 )
          CALL WKVECT ( NOMMFA,'G V K80',NBMOCL,ADMEMF )
          CALL JEECRA ( NOMMFA,'LONUTI',NBMOCL,SAUX08 )
          DO 342 , IAUX = 1 , NBMOCL
            JAUX = LXLGUT(ZK80(ADMOCL+IAUX-1))
            IF ( JAUX.NE.0 ) THEN
              ZK80(ADMEMC+IAUX-1)(1:JAUX) = ZK80(ADMOCL+IAUX-1)(1:JAUX)
            ENDIF
            JAUX = LXLGUT(ZK80(ADVALE+IAUX-1))
            IF ( JAUX.NE.0 ) THEN
              ZK80(ADMEVA+IAUX-1)(1:JAUX) = ZK80(ADVALE+IAUX-1)(1:JAUX)
            ENDIF
            JAUX = LXLGUT(ZK80(ADMOFA+IAUX-1))
            IF ( JAUX.NE.0 ) THEN
              ZK80(ADMEMF+IAUX-1)(1:JAUX) = ZK80(ADMOFA+IAUX-1)(1:JAUX)
            ENDIF
  342     CONTINUE
C
        ENDIF
C
C====
C 4. EN RECUPERATION OU SUPPRESSION
C====
C
      ELSEIF ( CHOIX.EQ.'RENC' .OR. CHOIX.EQ.'REMC' .OR.
     &         CHOIX.EQ.'S' ) THEN
C
C 4.1. ==> RECHERCHE DU NOM COMPOSE QUI A ETE ASSOCIE AU COUPLE
C          ( STRUCTURE DE BASE , PARAMETRE DE SENSIBILITE )
C
        CALL JEEXIN (NOMMEM,IER)
C
        IF (IER.EQ.0) THEN
          IRET = 2
        ELSE
          CALL JEVEUO ( NOMMEM, 'L', ADMMEM )
          CALL JELIRA ( NOMMEM, 'LONUTI', NUTI, SAUX08 )
          DO 41 , IAUX = 1 , NUTI
            IF ( (ZK80(ADMMEM+2*IAUX-2) (1: 8).EQ.NOSIM8 ) .AND.
     &           (ZK80(ADMMEM+2*IAUX-2) (9:16).EQ.NOPAS8) ) THEN
              SAUX08 = ZK80(ADMMEM+2*IAUX-2) (17:24)
C                             12345678
              IF ( SAUX08.EQ.'        ' ) THEN
                IRET = 1
              ENDIF
              NUMERO = IAUX
              GO TO 410
            ENDIF
   41     CONTINUE
          IRET = 1
  410     CONTINUE
        ENDIF
C
C 4.2. ==> RECUPERATION DU NOM COMPOSE
C
        IF ( CHOIX.EQ.'RENC' ) THEN
C
          IF ( IRET.NE.0 )  THEN
C                     12345678
            SAUX08 = '????????'
          ENDIF
C
          IAUX = LXLGUT(SAUX08)
          LGNOCO = LEN(NOCOMP)
          IF ( LGNOCO.LT.IAUX ) THEN
           CALL UTDEBM ( 'A', NOMPRO, 'PROBLEME DE DECLARATION' )
            CALL UTIMPI ( 'L',
     &      'LA CHAINE NOCOMP EST DECLAREE A ', 1, LGNOCO)
            CALL UTIMPI ( 'L',
     &'ON VEUT Y METTRE '//SAUX08//' QUI EN CONTIENT ', 1, IAUX)
            CALL UTFINM
            CALL U2MESS('F','MODELISA_67')
          ELSE
            NOCOMP(1:IAUX) = SAUX08(1:IAUX)
            DO 42 , JAUX = IAUX+1 , LGNOCO
              NOCOMP(JAUX:JAUX) = ' '
   42       CONTINUE
          ENDIF
C
C 4.3. ==> RECUPERATION DES MOTS-CLES/VALEURS ASSOCIES
C
        ELSEIF ( CHOIX.EQ.'REMC' ) THEN
C
          IF ( IRET.EQ.0 )  THEN
C
          CALL CODENT ( NUMERO, 'G', SAUX04 )
C                  1234567890123           45   6789     01234
          NOMMCL = PREFIX              // '.M'//SAUX04//'     '
          NOMVAL = PREFIX              // '.V'//SAUX04//'     '
          NOMMFA = PREFIX              // '.F'//SAUX04//'     '
          CALL JEEXIN (NOMMCL,IER)
C
          IF ( IER.EQ.0 ) THEN
            NBMOCL = 0
          ELSE
            CALL JEVEUO ( NOMMCL, 'L', ADMEMC )
            CALL JELIRA ( NOMMCL, 'LONUTI', NBMOCL, SAUX08 )
            CALL JEVEUO ( NOMVAL, 'L', ADMEVA )
            CALL JEVEUO ( NOMMFA, 'L', ADMEMF )
            CALL WKVECT ( LIMOCL,'V V K80',NBMOCL,ADMOCL )
            CALL JEECRA ( LIMOCL,'LONUTI',NBMOCL,SAUX08 )
            CALL WKVECT ( LIVALE,'V V K80',NBMOCL,ADVALE )
            CALL JEECRA ( LIVALE,'LONUTI',NBMOCL,SAUX08 )
            CALL WKVECT ( LIMOFA,'V V K80',NBMOCL,ADMOFA )
            CALL JEECRA ( LIMOFA,'LONUTI',NBMOCL,SAUX08 )
            DO 43 , IAUX = 0 , NBMOCL-1
              ZK80(ADMOCL+IAUX) = ZK80(ADMEMC+IAUX)
              ZK80(ADVALE+IAUX) = ZK80(ADMEVA+IAUX)
              ZK80(ADMOFA+IAUX) = ZK80(ADMEMF+IAUX)
   43       CONTINUE
C
          ENDIF
C
          ENDIF
C
C 4.4. ==> EN SUPPRESSION
C          . ON BASCULE LE DERNIER ENREGISTREMENT A LA PLACE DEGAGEE
C          . ON INDIQUE QUE L'ON RACCOURCIT LA STRUCTURE
C          . ON SUPPRIME LES EVENTUELS MOTS-CLES ASSOCIES
C
        ELSE
C
          IF ( IRET.EQ.0 )  THEN
C
          IAUX = LXLGUT(SAUX08)
          JAUX = LXLGUT(NOCOMP)
          IF ( JAUX.NE.IAUX ) THEN
            IRET = 3
          ELSE
            IF ( SAUX08(1:IAUX).NE.NOCOMP(1:IAUX) ) THEN
              IRET = 3
            ENDIF
          ENDIF
C
          ENDIF
C
          IF ( IRET.EQ.0 ) THEN
C
            ZK80(ADMMEM-1+NUMERO) = ZK80(ADMMEM-1+NUTI)
            NUTI = NUTI - 1
            CALL JEECRA ( NOMMEM,'LONUTI',NUTI,SAUX08)
C
          ELSE
C
            CALL U2MESK('A','UTILITAI4_56',1,NOSIM8)
            CALL U2MESK('A','UTILITAI4_57',1,NOPAS8)
            CALL U2MESK('A','UTILITAI4_58',1,NOCOM8)
            CALL U2MESK('A','UTILITAI4_59',1,SAUX08)
            CALL U2MESS('A','UTILITAI4_60')
C
          ENDIF
C
        ENDIF
C
C====
C 5. MAUVAIX CHOIX
C====
C
      ELSE
        CALL U2MESS('A','UTILITAI4_61')
        CALL U2MESS('F','MODELISA_67')
      ENDIF
C
      CALL JEDEMA()
C
      END
