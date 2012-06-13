      SUBROUTINE MEBILG(OPTIOZ,RESULT,MODELE,DEPLA1,DEPLA2,THETA,MATE,
     &                  NCHAR,LCHAR,SYMECH,EXTIM,TIMEU,TIMEV,INDI,INDJ,
     &                  NBPRUP,NOPRUP)
      IMPLICIT NONE

      INCLUDE 'jeveux.h'
      CHARACTER*8 MODELE,LCHAR(*),RESULT,SYMECH
      CHARACTER*16 OPTIOZ,NOPRUP(*)
      CHARACTER*24 DEPLA1,DEPLA2,MATE,THETA
      REAL*8 TIMEU, TIMEV
      INTEGER INDI,INDJ,NCHAR,NBPRUP
      LOGICAL EXTIM
C ......................................................................
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
C (AT YOUR OPTION) ANY LATER VERSION.

C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.

C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================

C     - FONCTION REALISEE:   CALCUL DU G BILINEAIRE EN 3D

C IN   OPTION  --> G_BILI
C IN   RESULT  --> NOM UTILISATEUR DU RESULTAT ET TABLE
C IN   MODELE  --> NOM DU MODELE
C IN   DEPLA1  --> CHAMP DE DEPLACEMENT U
C IN   THETA   --> CHAMP THETA
C IN   MATE    --> CHAMP DE MATERIAUX
C IN   SYMECH  --> SYMETRIE DU CHARGEMENT
C IN   EXTIM   --> VRAI SI L'INSTANT EST DONNE
C IN   TIME    --> INSTANT DE CALCUL
C IN   INDI    --> INDICE I DU DEPLACEMENT U DANS LA SD
C IN   INDJ    --> INDICE J DU DEPLACEMENT U DANS LA SD
C ......................................................................

      INTEGER IBID,INIT,NIV,IFM
      INTEGER NCHIN,IVAL(2)

      REAL*8 G,RVAL(1)

      COMPLEX*16 CBID

      LOGICAL EXIGEO,UFONC,VFONC,EPSIU,EPSIV

      CHARACTER*2  CODRET
      CHARACTER*8 K8B
      CHARACTER*8 LPAIN(20),LPAOUT(1)
      CHARACTER*16 OPTION,OPTI,VALK
      CHARACTER*24 CHGEOM,CHVREF
      CHARACTER*24 LCHIN(20),LCHOUT(1),LIGRMO
      CHARACTER*19 UCHVOL,VCHVOL,UCF12D,VCF12D,UCF23D,VCF23D
      CHARACTER*19 UCHPRE,VCHPRE,UCHEPS,VCHEPS,UCHPES,VCHPES
      CHARACTER*19 UCHROT,VCHROT,VRCMOI,VRCPLU
      CHARACTER*24 UPAVOL,VPAVOL,UPA23D,VPA23D,UPAPRE,VPAPRE
      CHARACTER*24 UPEPSI,VPEPSI



      DATA VRCMOI /'&&MBILGL.VRCM'/
      DATA VRCPLU /'&&MBILGL.VRCP'/
      DATA CHVREF /'&&MBILGL.VRCR'/

      CALL JEMARQ()
      OPTION = OPTIOZ
      CALL INFNIV(IFM,NIV)

C- RECUPERATION DU CHAMP GEOMETRIQUE

      CALL MEGEOM(MODELE,' ',EXIGEO,CHGEOM)

C- RECUPERATION DE L'ETAT INITIAL

      CALL GETFAC('ETAT_INIT',INIT)
      IF (INIT.NE.0) THEN
        VALK='G_BILI'
        CALL U2MESK('F','RUPTURE1_13',1,VALK)
      END IF

C- RECUPERATION (S'ILS EXISTENT) DES CHAMP
C  DE TEMPERATURE (TU, TV, TREF)

      CALL VRCREF(MODELE,MATE(1:8),'        ',CHVREF(1:19))
      CALL VRCINS(MODELE,MATE,' ',TIMEU,VRCMOI,CODRET)
      CALL VRCINS(MODELE,MATE,' ',TIMEV,VRCPLU,CODRET)

C - TRAITEMENT DES CHARGES U

      UCHVOL = '&&MBILGL.VOLU'
      UCF12D = '&&MBILGL.1D2D'
      UCF23D = '&&MBILGL.2D3D'
      UCHPRE = '&&MBILGL.PRES'
      UCHEPS = '&&MBILGL.EPSI'
      UCHPES = '&&MBILGL.PESA'
      UCHROT = '&&MBILGL.ROTA'
      CALL GCHARG(MODELE,NCHAR,LCHAR,UCHVOL,UCF12D,UCF23D,UCHPRE,
     &            UCHEPS,UCHPES,UCHROT,UFONC,EPSIV,TIMEU,INDI)

      IF (UFONC) THEN
        UPAVOL = 'UPFFVOL'
        UPA23D = 'UPFF23D'
        UPAPRE = 'UPRESSF'
        UPEPSI = 'UEPSINF'
        OPTI = 'G_BILI_F'
      ELSE
        UPAVOL = 'UPFRVOL'
        UPA23D = 'UPFR23D'
        UPAPRE = 'UPRESSR'
        UPEPSI = 'UEPSINR'
        OPTI = OPTION
      END IF

C - TRAITEMENT DES CHARGES V

      VCHVOL = '&&MBILGL.VOLU'
      VCF12D = '&&MBILGL.1D2D'
      VCF23D = '&&MBILGL.2D3D'
      VCHPRE = '&&MBILGL.PRES'
      VCHEPS = '&&MBILGL.EPSI'
      VCHPES = '&&MBILGL.PESA'
      VCHROT = '&&MBILGL.ROTA'
      CALL GCHARG(MODELE,NCHAR,LCHAR,VCHVOL,VCF12D,VCF23D,VCHPRE,
     &            VCHEPS,VCHPES,VCHROT,VFONC,EPSIU,TIMEV,INDJ)

      IF (VFONC) THEN
        VPAVOL = 'VPFFVOL'
        VPA23D = 'VPFF23D'
        VPAPRE = 'VPRESSF'
        VPEPSI = 'VEPSINF'
        OPTI = 'G_BILI_F'
      ELSE
        VPAVOL = 'VPFRVOL'
        VPA23D = 'VPFR23D'
        VPAPRE = 'VPRESSR'
        VPEPSI = 'VEPSINR'
        OPTI = OPTION
      END IF

      LPAOUT(1) = 'PGTHETA'
      LCHOUT(1) = '&&FICGELE'

      LPAIN(1) = 'PGEOMER'
      LCHIN(1) = CHGEOM
      LPAIN(2) = 'PDEPLAU'
      LCHIN(2) = DEPLA1
      LPAIN(3) = 'PTHETAR'
      LCHIN(3) = THETA
      LPAIN(4) = 'PMATERC'
      LCHIN(4) = MATE
      LPAIN(5) = 'PVARCMR'
      LCHIN(5) = VRCMOI
      LPAIN(6) = 'PDEPLAV'
      LCHIN(6) = DEPLA2
      LPAIN(7) = 'PVARCPR'
      LCHIN(7) = VRCPLU
      LPAIN(8) = UPAVOL
      LCHIN(8) = UCHVOL
      LPAIN(9) = VPAVOL
      LCHIN(9) = VCHVOL
      LPAIN(10) = UPA23D
      LCHIN(10) = UCF23D
      LPAIN(11) = VPA23D
      LCHIN(11) = VCF23D
      LPAIN(12) = UPAPRE
      LCHIN(12) = UCHPRE
      LPAIN(13) = VPAPRE
      LCHIN(13) = VCHPRE
      LPAIN(14) = UPEPSI
      LCHIN(14) = UCHEPS
      LPAIN(15) = VPEPSI
      LCHIN(15) = VCHEPS
      LPAIN(16) = 'UPESANR'
      LCHIN(16) = UCHPES
      LPAIN(17) = 'VPESANR'
      LCHIN(17) = VCHPES
      LPAIN(18) = 'UROTATR'
      LCHIN(18) = UCHROT
      LPAIN(19) = 'VROTATR'
      LCHIN(19) = VCHROT
      LPAIN(20) = 'PVARCRR'
      LCHIN(20) = CHVREF

      LIGRMO = MODELE//'.MODELE'
      NCHIN = 20
      CALL CALCUL('S',OPTI,LIGRMO,NCHIN,LCHIN,LPAIN,1,LCHOUT,LPAOUT,
     &            'V','OUI')

C  SOMMATION DES FIC ET G ELEMENTAIRES

      CALL MESOMM(LCHOUT(1),1,IBID,G,CBID,0,IBID)

      IF (SYMECH.NE.'NON') G = 2.D0*G

C IMPRESSION DE G ET ECRITURE DANS LA TABLE RESU

      RVAL(1) = G
      IVAL(1) = INDI
      IVAL(2) = INDJ
      CALL TBAJLI(RESULT,NBPRUP,NOPRUP,IVAL,RVAL,CBID,K8B,0)

      CALL JEDETR('&&MEBILG.VALG')
      CALL DETRSD('CHAMP_GD',VRCMOI)
      CALL DETRSD('CHAMP_GD',VRCPLU)
      CALL DETRSD('CHAMP_GD',CHVREF)
      CALL DETRSD('CHAMP_GD',UCHVOL)
      CALL DETRSD('CHAMP_GD',VCHVOL)
      CALL DETRSD('CHAMP_GD',UCF23D)
      CALL DETRSD('CHAMP_GD',VCF23D)
      CALL DETRSD('CHAMP_GD',UCHPRE)
      CALL DETRSD('CHAMP_GD',VCHPRE)
      CALL DETRSD('CHAMP_GD',UCHEPS)
      CALL DETRSD('CHAMP_GD',VCHEPS)
      CALL DETRSD('CHAMP_GD',UCHPES)
      CALL DETRSD('CHAMP_GD',VCHPES)
      CALL DETRSD('CHAMP_GD',UCHROT)
      CALL DETRSD('CHAMP_GD',VCHROT)

      CALL JEDEMA()
      END
