      SUBROUTINE RESLOC(MODELE,LIGREL,CHTIME,SIGMA,LCHAR,NCHAR,MATE,
     &                  CHVOIS,IATYMA,IAGD,IACMP,ICONX1,ICONX2,RESU)
      IMPLICIT REAL*8 (A-H,O-Z)
      CHARACTER*(*) LIGREL,MATE
C ......................................................................
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 08/11/2005   AUTEUR CIBHHLV L.VIVAN 
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
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
C     BUT:
C         CALCUL DE L'ESTIMATEUR D'ERREUR EN RESIDU
C                     OPTION : 'ERRE_ELGA_NORE'
C     ARGUMENTS:
C     ----------
C ENTREE :
C     LES NOMS QUI SUIVENT SONT LES PREFIXES UTILISATEUR K8:
C     MODELE : NOM DU MODELE
C     SIGMA  : NOM DU CHAMP DE CONTRAINTES CALCULEES (CHAM_ELEM_SIEF_R)
C     LCHAR  : LISTE DES CHARGES
C     NCHAR  : NOMBRE DE CHARGES
C     MATE   : NOM DU CONCEPT CHAMP_MATERIAU
C
C SORTIE :
C      RESU   : NOM DU CHAM_ELEM_ERREUR PRODUIT
C               SI RESU EXISTE DEJA, ON LE DETRUIT.
C ......................................................................

C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------
      CHARACTER*32 JEXNUM,JEXNOM,JEXR8,JEXATR
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------

      INTEGER      ICMP(12)
      LOGICAL      EXIGEO,EXIMAT
      CHARACTER*1  BASE
      CHARACTER*24 CHGEOM
      CHARACTER*8  K8B,MODELE,LCHAR(1),LIPARA(1),LICMP(12)
      CHARACTER*8  LPAIN(10),LPAOUT(1),MA,KCMP
      CHARACTER*16 OPTION, OPT, CONCEP, NOMCMD
      CHARACTER*19 CARTE1,CARTE2,NOMGD1,NOMGD2
      CHARACTER*24 LCHIN(10),LCHOUT(1),MOD,CHVOIS
      CHARACTER*24 RESU,CHFOR1,CHFOR2,CHFOR3,CHTIME,SIGMA
      COMPLEX*16   CCMP

C DEB-------------------------------------------------------------------
      BASE = 'V'
      CALL GETRES ( K8B, CONCEP, NOMCMD )
C
      CALL MEGEOM(MODELE,LCHAR(1),EXIGEO,CHGEOM)
      IF (.NOT.EXIGEO) CALL UTMESS('F',NOMCMD,'PAS DE CHGEOM')

C ------- TEST SUR LE TYPE DE CHARGEMENT DES BORDS --------------------

C   ATTENTION : POUR UN MEME CHARGEMENT (FORCE_FACE OU PRES_REP), SEULE
C   LA DERNIERE CHARGE EST CONSIDEREE (REGLE DE SURCHARGE ACTUELLEMENT)

      CARTE1 = ' '
      CARTE2 = ' '
      NOMGD1 = ' '
      NOMGD2 = ' '
      IRET1 = 0
      IRET2 = 0
      IRET3 = 0
      DO 10 I = 1,NCHAR
        CALL EXISD('CHAMP_GD',LCHAR(I)//'.CHME.F1D2D',IRET1)
        CALL EXISD('CHAMP_GD',LCHAR(I)//'.CHME.F2D3D',IRET2)
        CALL EXISD('CHAMP_GD',LCHAR(I)//'.CHME.PRESS',IRET3)
        IF (IRET1.NE.0) THEN
          CARTE1 = LCHAR(I)//'.CHME.F1D2D'
          CALL DISMOI('F','NOM_GD',CARTE1,'CARTE',IBID,NOMGD1,IER)
          CALL ETENCA(CARTE1,LIGREL,IRET)
          IF (IRET.NE.0) THEN
            CALL UTMESS('F',NOMCMD,'ERREUR DANS ETANCA')
          END IF
        ELSE IF (IRET2.NE.0) THEN
          CARTE1 = LCHAR(I)//'.CHME.F2D3D'
          CALL DISMOI('F','NOM_GD',CARTE1,'CARTE',IBID,NOMGD1,IER)
          CALL ETENCA(CARTE1,LIGREL,IRET)
          IF (IRET.NE.0) THEN
            CALL UTMESS('F',NOMCMD,'ERREUR DANS ETANCA')
          END IF
        END IF
        IF (IRET3.NE.0) THEN
          CARTE2 = LCHAR(I)//'.CHME.PRESS'
          CALL DISMOI('F','NOM_GD',CARTE2,'CARTE',IBID,NOMGD2,IER)
          CALL ETENCA(CARTE2,LIGREL,IRET)
          IF (IRET.NE.0) THEN
            CALL UTMESS('F',NOMCMD,'ERREUR DANS ETANCA')
          END IF
        END IF
   10 CONTINUE

C ------- CREATION DE 2 CARTES CONTENANT DES ADRESSES D'OBJETS JEVEUX
C         ----------------------------------- -----------------------

      LICMP(1) = 'X1'
      LICMP(2) = 'X2'
      LICMP(3) = 'X3'
      LICMP(4) = 'X4'
      LICMP(5) = 'X5'
      LICMP(6) = 'X6'
      LICMP(7) = 'X7'
      LICMP(8) = 'X8'
      LICMP(9) = 'X9'
      LICMP(10) = 'X10'
      LICMP(11) = 'X11'
      LICMP(12) = 'X12'
C
      CALL JEVEUO(LIGREL(1:19)//'.REPE','L',IAREPE)
      CALL JEVEUO(SIGMA(1:19)//'.CELD','L',JCELD)
      CALL JEVEUO(SIGMA(1:19)//'.CELV','L',JCELV)
C
      IF (CARTE1 .NE. ' ') THEN
        CALL JEVEUO (CARTE1//'.DESC','L',IADE1)
        CALL JEVEUO (CARTE1//'.VALE','L',IAVA1)
        CALL JEEXIN (CARTE1//'.PTMA',IRET)
        IF (IRET .EQ. 0) THEN
          IAPTM1 = 0
        ELSE
C            LA CARTE A ETE ETENDUE
          CALL JEVEUO (CARTE1//'.PTMA','L',IAPTM1)
        ENDIF
        CALL JENONU(JEXNOM('&CATA.GD.NOMGD',NOMGD1),NUMGD1)
      ELSE
        IADE1 = 0
        IAVA1 = 0
      ENDIF
C
      IF (CARTE2 .NE. ' ') THEN
        CALL JEVEUO (CARTE2//'.DESC','L',IADE2)
        CALL JEVEUO (CARTE2//'.VALE','L',IAVA2)
        CALL JEEXIN (CARTE2//'.PTMA',IRET)
        IF (IRET .EQ. 0) THEN
          IAPTM2 = 0
        ELSE
C            LA CARTE A ETE ETENDUE
          CALL JEVEUO (CARTE2//'.PTMA','L',IAPTM2)
        ENDIF
        CALL JENONU(JEXNOM('&CATA.GD.NOMGD',NOMGD2),NUMGD2)
      ELSE
        IADE2 = 0
        IAVA2 = 0
      ENDIF
C
      ICMP(1) = IAREPE
      ICMP(2) = JCELD
      ICMP(3) = JCELV
      ICMP(4) = IATYMA
      ICMP(5) = IAGD
      ICMP(6) = IACMP
      ICMP(11) = ICONX1
      ICMP(12) = ICONX2
C      
      ICMP(7) = IADE1
      ICMP(8) = IAVA1
      ICMP(9) = IAPTM1
      ICMP(10) = NUMGD1

      CALL MECACT(BASE,'&&RESLOC.CH_FORCE','MODELE',LIGREL,'NEUT_I',12,
     &            LICMP,ICMP,RCMP,CCMP,KCMP)

      ICMP(7) = IADE2
      ICMP(8) = IAVA2
      ICMP(9) = IAPTM2
      ICMP(10) = NUMGD2

      CALL MECACT(BASE,'&&RESLOC.CH_PRESS','MODELE',LIGREL,'NEUT_I',12,
     &            LICMP,ICMP,RCMP,CCMP,KCMP)


C --- ON ALARME POUR LES CHARGES NON TRAITEES

      DO 12 I = 1,NCHAR
        CALL EXISD('CHAMP_GD',LCHAR(I)//'.CHME.F1D2D',IRET1)
        IF (IRET1.NE.0)  GOTO 12
        CALL EXISD('CHAMP_GD',LCHAR(I)//'.CHME.F2D3D',IRET2)
        IF (IRET2.NE.0)  GOTO 12
        CALL EXISD('CHAMP_GD',LCHAR(I)//'.CHME.PRESS',IRET3)
        IF (IRET3.NE.0)  GOTO 12
        CALL EXISD('CHAMP_GD',LCHAR(I)//'.CHME.PESAN',IRET4)
        IF (IRET4.NE.0)  GOTO 12
        CALL EXISD('CHAMP_GD',LCHAR(I)//'.CHME.ROTAT',IRET5)
        IF (IRET5.NE.0)  GOTO 12
        CALL EXISD('CHAMP_GD',LCHAR(I)//'.CHME.F2D2D',IRET6)
        IF (IRET6.NE.0)  GOTO 12
        CALL EXISD('CHAMP_GD',LCHAR(I)//'.CHME.F3D3D',IRET7)
        IF (IRET7.NE.0)  GOTO 12
        CALL EXISD('CHAMP_GD',LCHAR(I)//'.CHME.CIMPO',IRET8)
        IF (IRET8.NE.0)  GOTO 12
        CALL UTMESS('A',NOMCMD,'CHARGE NON PRISE EN COMPTE: '//LCHAR(I))
   12 CONTINUE


C --- CHARGEMENTS VOLUMIQUES : PESANTEUR, ROTATION OU FORCES DE VOLUME
C     ATTENTION : SEULE LA DERNIERE CHARGE EST CONSIDEREE

      IRET4 = 0
      IRET5 = 0
      IRET6 = 0
      IRET7 = 0
      DO 20 I = 1,NCHAR
        CALL EXISD('CHAMP_GD',LCHAR(I)//'.CHME.PESAN',IRET4)
        CALL EXISD('CHAMP_GD',LCHAR(I)//'.CHME.ROTAT',IRET5)
        CALL EXISD('CHAMP_GD',LCHAR(I)//'.CHME.F2D2D',IRET6)
        CALL EXISD('CHAMP_GD',LCHAR(I)//'.CHME.F3D3D',IRET7)
        IF (IRET4.NE.0) THEN
          CHFOR1 = LCHAR(I)//'.CHME.PESAN.DESC'
        END IF
        IF (IRET5.NE.0) THEN
          CHFOR2 = LCHAR(I)//'.CHME.ROTAT.DESC'
        END IF
        IF (IRET6.NE.0) THEN
          CHFOR3 = LCHAR(I)//'.CHME.F2D2D.DESC'
        END IF
        IF (IRET7.NE.0) THEN
          CHFOR3 = LCHAR(I)//'.CHME.F3D3D.DESC'
        END IF
   20 CONTINUE

C --- SI ABSENCE D'UN CHAMP DE FORCES, CREATION D'UN CHAMP NUL

      IF (IRET4.EQ.0)  CHFOR1 = ' '

      IF (IRET5.EQ.0)  CHFOR2 = ' '

      IF (IRET6.EQ.0 .AND. IRET7.EQ.0) THEN
        CHFOR3 = '&&RESLOC.CH_NULLE'
        CALL MEFOR0(MODELE,CHFOR3,.FALSE.)
      END IF

      LPAIN(1) = 'PGEOMER'
      LCHIN(1) = CHGEOM
      LPAIN(2) = 'PCONTNO'
      LCHIN(2) = SIGMA
      LPAIN(3) = 'PFRVOLU'
      LCHIN(3) = CHFOR3
      LPAIN(4) = 'PPESANR'
      LCHIN(4) = CHFOR1
      LPAIN(5) = 'PROTATR'
      LCHIN(5) = CHFOR2
      LPAIN(6) = 'PMATERC'
      LCHIN(6) = MATE
      LPAIN(7) = 'PFORCE'
      LCHIN(7) = '&&RESLOC.CH_FORCE'
      LPAIN(8) = 'PPRESS'
      LCHIN(8) = '&&RESLOC.CH_PRESS'
      LPAIN(9) = 'PVOISIN'
      LCHIN(9) = CHVOIS
      LPAIN(10) = 'PTEMPSR'
      LCHIN(10) = CHTIME

      LPAOUT(1) = 'PERREUR'
      LCHOUT(1) = RESU
      OPTION = 'ERRE_ELGA_NORE'
      CALL CALCUL('C',OPTION,LIGREL,10,LCHIN,LPAIN,1,LCHOUT,LPAOUT,'G')
      CALL EXISD('CHAMP_GD',LCHOUT(1),IRET)
      IF (IRET.EQ.0) THEN
          CALL UTMESS('A',NOMCMD,'OPTION '//OPTION//' NON '//
     &         'DISPONIBLE SUR LES ELEMENTS DU MODELE'//
     &         '- PAS DE CHAMP CREE ')
           GOTO 9999
      END IF

      CALL JEDETR(CARTE1//'.PTMA')
      CALL JEDETR(CARTE2//'.PTMA')

      CALL DETRSD('CHAMP_GD','&&RESLOC.CH_FORCE')
      CALL DETRSD('CHAMP_GD','&&RESLOC.CH_PRESS')
      IF (IRET6.EQ.0 .AND. IRET7.EQ.0) THEN
        CALL DETRSD('CHAMP_GD',CHFOR3)
      END IF
9999  CONTINUE
      END
