      SUBROUTINE PIQINI ( MAILLA )
      IMPLICIT   NONE
      INCLUDE 'jeveux.h'

      CHARACTER*32 JEXNOM
      CHARACTER*8         MAILLA
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF SOUSTRUC  DATE 18/12/2012   AUTEUR SELLENET N.SELLENET 
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
C     OPERATEUR: "DEFI_GROUP" , MOTCLE FACTEUR "EQUE_PIQUA"
C     AUTEUR Y. WADIER
C
C     INITIALISE ET LANCE LE PROGRAMME PIQUAG
C
C-----------------------------------------------------------------------
C
C-----------------DONNEES FOURNIES PAR L'UTILISATEUR--------------------
C
C     EPT1  = EPAISSEUR PIQUAGE A LA BASE
C     DET1  = DIAMETRE EXTERIEUR PIQUAGE A LA BASE
C     D1    = HAUTEUR PIQUAGE A LA BASE
C     TYPSOU= TYPE DE LA SOUDURE (TYPE_1 OU TYPE_2)
C     H     = HAUTEUR SOUDURE
C     ALPHA = ANGLE ENTRE LES 2 INTERFACES
C     JEU   = JEU A LA BASE DE LA SOUDURE
C     DEC   = DIAMETRE EXTERIEUR CORPS A LA BASE
C     EPC   = EPAISSEUR CORPS A LA BASE
C     THETA = POSITION ANGULAIRE DU CENTRE DE LA FISSURE
C
C----------------------DONNEES FOURNIES PAR ASTER-----------------------
C
C     XMAX = LONGUEUR MAX SELON X, APRES ALLONGEMENT
C     YMAX = LONGUEUR MAX SELON Y
C     LMAX = LONGUEUR MAX SELON X
C     NT   = NOMBRE DE TRANCHES
C
C---------------CALCUL DES DONNEES DU PROGRAMME PIQUAGE-----------------
C
C     RIP = RAYON INTERIEUR DU PIQUAGE
C     REP = RAYON EXTERIEUR DU PIQUAGE
C     RIT = RAYON INTERIEUR DE LA TUYAUTERIE
C     RET = RAYON EXTERIEUR DE LA TUYAUTERIE
C
C     BET = ANGLE SOUDURE
C     ESO = EPAISSEUR SOUDURE
C     HSO = HAUTEUR SOUDURE
C
C     H2 = HAUTEUR  ZONE 2
C     H3 = HAUTEUR  ZONE 3
C     L3 = LONGUEUR ZONE 3
C     L4 = LONGUEUR ZONE 4
C     L5 = LONGUEUR ZONE 5
C     L6 = LONGUEUR ZONE 6
C
C     YMAX  = EPAISSEUR DE L'EQUERRE SUIVANT Y
C     TETAF = POSITION DU CENTRE DE LA FISSURE
C     NT    = NOMBRE DE TRANCHES
C-----------------------------------------------------------------------
C
      INTEGER  NT, N1, IRET
      REAL*8   EPSI, RIP, REP, RIT, RET, BET, ESO, HSO, H2, H3,
     +         L3, L4, L5, L6, TETAF, R8DGRD, RMC, R8PI, D1, D2,
     +         EPT1, DET1, H, ALPHA, JEU, DEC, EPC, THETA, XMAX,
     +         YMAX, LMAX
      CHARACTER*8   TYPSOU
      CHARACTER*8   NOGRNO, TYPMAI, NOGRNP
      CHARACTER*24  GRPNOE
      INTEGER      IARG
C     ------------------------------------------------------------------
C
C     ON ORDONNE LES NOEUDS SELON L'ORDRE DES MAILLES
C     CAR LORS DU CREA_GROUP L'ORDRE N'EST PAS CONSERVE
C
      CALL ORDGMN(MAILLA,'PFONDFIS')
C
      CALL GETVEM(MAILLA,'GROUP_NO', 'EQUE_PIQUA','GROUP_NO',
     +              1,IARG,1,NOGRNO,N1)
C
      CALL GETVR8 ( 'EQUE_PIQUA', 'E_BASE'   , 1,IARG,1, EPT1 , N1 )
      CALL GETVR8 ( 'EQUE_PIQUA', 'DEXT_BASE', 1,IARG,1, DET1 , N1 )
      CALL GETVR8 ( 'EQUE_PIQUA', 'L_BASE'   , 1,IARG,1, D1   , N1 )
      CALL GETVR8 ( 'EQUE_PIQUA', 'L_CHANF'  , 1,IARG,1, D2   , N1 )
      CALL GETVTX ( 'EQUE_PIQUA', 'TYPE'     , 1,IARG,1, TYPSOU,N1 )
      CALL GETVR8 ( 'EQUE_PIQUA', 'H_SOUD'   , 1,IARG,1, H    , N1 )
      CALL GETVR8 ( 'EQUE_PIQUA', 'ANGL_SOUD', 1,IARG,1, ALPHA, N1 )
      CALL GETVR8 ( 'EQUE_PIQUA', 'JEU_SOUD' , 1,IARG,1, JEU  , N1 )
      CALL GETVR8 ( 'EQUE_PIQUA', 'E_CORP'   , 1,IARG,1, EPC  , N1 )
      CALL GETVR8 ( 'EQUE_PIQUA', 'DEXT_CORP', 1,IARG,1, DEC  , N1 )
      CALL GETVR8 ( 'EQUE_PIQUA', 'AZIMUT   ', 1,IARG,1, THETA, N1 )
      CALL GETVTX ( 'EQUE_PIQUA', 'RAFF_MAIL', 1,IARG,1, TYPMAI,N1 )
      CALL GETVR8 ( 'EQUE_PIQUA', 'X_MAX'    , 1,IARG,1, XMAX , N1 )
C
C
      RMC = ( DEC - EPC ) / 2.0D0
C
      LMAX = R8PI() * RMC
      YMAX  = LMAX - ( DET1 / 2.0D0 ) + EPT1
C
      IF ( TYPMAI .EQ. 'GROS' ) THEN
         NT = 20
      ELSE
         NT = 24
      ENDIF
C
      EPSI   = EPC * 1.D-08
C
      REP = DET1 / 2.0D0
      RIP = REP - EPT1
      RET = DEC / 2.0D0
      RIT = RET - EPC
C
      BET = ALPHA * R8DGRD()
      HSO = H
      H2 = RET + D1
      L3 = REP
      IF ( TYPSOU .EQ. 'TYPE_1') THEN
        ESO = JEU + EPC*TAN(BET)
C
        H3 = RET + H
        L4 = REP + ESO
      ELSEIF ( TYPSOU .EQ. 'TYPE_2' ) THEN
        ESO = JEU + EPT1*TAN(BET)
C
        H3 = RET + JEU + EPT1*TAN(BET)
        L4 = REP + HSO
      ENDIF
      L5 = 2.0D0 * L4
      L6 = LMAX
C
      TETAF = THETA * R8DGRD()
C
      CALL PIQUAG ( EPSI, RIP, REP, RIT, RET, BET, ESO, HSO, H2,
     +              H3, L3, L4, L5, L6, TETAF, XMAX, YMAX,
     +              LMAX, NT, MAILLA, NOGRNO, TYPSOU )
C
      GRPNOE = MAILLA//'.GROUPENO       '
      CALL JEEXIN ( JEXNOM(GRPNOE,'P_FIS1'), IRET )
      IF ( IRET .NE. 0 ) THEN
         NOGRNP = 'P_FIS1  '
         CALL PIQUAG ( EPSI, RIP, REP, RIT, RET, BET, ESO, HSO, H2,
     +                 H3, L3, L4, L5, L6, TETAF, XMAX, YMAX,
     +                 LMAX, NT, MAILLA, NOGRNP, TYPSOU )
      ELSE
C
         CALL JEEXIN ( JEXNOM(GRPNOE,'PI_FIS1'), IRET )
         IF ( IRET .NE. 0 ) THEN
         NOGRNP = 'PI_FIS1  '
         CALL PIQUAG ( EPSI, RIP, REP, RIT, RET, BET, ESO, HSO, H2,
     +                 H3, L3, L4, L5, L6, TETAF, XMAX, YMAX,
     +                 LMAX, NT, MAILLA, NOGRNP, TYPSOU )
         ENDIF
C
         CALL JEEXIN ( JEXNOM(GRPNOE,'PS_FIS1'), IRET )
         IF ( IRET .NE. 0 ) THEN
         NOGRNP = 'PS_FIS1  '
         CALL PIQUAG ( EPSI, RIP, REP, RIT, RET, BET, ESO, HSO, H2,
     +                 H3, L3, L4, L5, L6, TETAF, XMAX, YMAX,
     +                 LMAX, NT, MAILLA, NOGRNP, TYPSOU )
         ENDIF
      ENDIF
C
      CALL JEEXIN ( JEXNOM(GRPNOE,'P_FIS2'), IRET )
      IF ( IRET .NE. 0 ) THEN
         NOGRNP = 'P_FIS2  '
         CALL PIQUAG ( EPSI, RIP, REP, RIT, RET, BET, ESO, HSO, H2,
     +                 H3, L3, L4, L5, L6, TETAF, XMAX, YMAX,
     +                 LMAX, NT, MAILLA, NOGRNP, TYPSOU )
      ELSE
         CALL JEEXIN ( JEXNOM(GRPNOE,'PI_FIS2'), IRET )
         IF ( IRET .NE. 0 ) THEN
         NOGRNP = 'PI_FIS2  '
         CALL PIQUAG ( EPSI, RIP, REP, RIT, RET, BET, ESO, HSO, H2,
     +                 H3, L3, L4, L5, L6, TETAF, XMAX, YMAX,
     +                 LMAX, NT, MAILLA, NOGRNP, TYPSOU )
         ENDIF
C
         CALL JEEXIN ( JEXNOM(GRPNOE,'PS_FIS2'), IRET )
         IF ( IRET .NE. 0 ) THEN
         NOGRNP = 'PS_FIS2  '
         CALL PIQUAG ( EPSI, RIP, REP, RIT, RET, BET, ESO, HSO, H2,
     +                 H3, L3, L4, L5, L6, TETAF, XMAX, YMAX,
     +                 LMAX, NT, MAILLA, NOGRNP, TYPSOU )
         ENDIF
      ENDIF
C
      END
