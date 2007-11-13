      SUBROUTINE SSDMTE(MAG)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF SOUSTRUC  DATE 12/11/2007   AUTEUR PELLET J.PELLET 
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
C     ARGUMENTS:
C     ----------
      CHARACTER*8 MAG
C ----------------------------------------------------------------------
C     BUT:
C        - TERMINER LE TRAITEMENT
C          DES COMMANDES DEFI_MAILLAGE ET CONC_MAILLAGE.
C        - CREER LES OBJETS :
C            BASE GLOBALE : .COORDO , .NOMNOE
C        - MODIFIER LES OBJETS :
C            BASE GLOBALE : .SUPMAIL, .GROUPENO ET .CONNEX
C            POUR TENIR COMPTE DES NOEUDS CONFONDUS.
C
C     IN:
C        MAG : NOM DU MAILLAGE RESULTAT.
C
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER          ZI
      COMMON  /IVARJE/ ZI(1)
      REAL*8           ZR
      COMMON  /RVARJE/ ZR(1)
      COMPLEX*16       ZC
      COMMON  /CVARJE/ ZC(1)
      LOGICAL          ZL
      COMMON  /LVARJE/ ZL(1)
      CHARACTER*8      ZK8
      CHARACTER*16            ZK16
      CHARACTER*24                    ZK24
      CHARACTER*32                            ZK32
      CHARACTER*80                                    ZK80
      COMMON  /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      CHARACTER*32     JEXNUM, JEXNOM, JEXATR
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
      CHARACTER*8  KBI81,KBI82,NOMACR,NOMAIL,KBID,MA,NOMNOE
      LOGICAL      RECOM
      CHARACTER*19 COORDO
C ----------------------------------------------------------------------
C     VARIABLES LOCALES:
C     ------------------
C     NBNOPH : NOMBRE DE NOEUDS PHYSIQUES DE MAG "AVANT"
C              (AVANT DE CONFONDRE CERTAINS NOEUDS)
C     NBNOP2 : NOMBRE DE NOEUDS PHYSIQUES DE MAG "APRES"
C              (APRES AVOIR CONFONDU CERTAINS NOEUDS)
C     NBNOCO : NOMBRE DE NOEUDS CONFONDUS.
C              (NBNOCO=NBNOP2-NBNOPH)
C     NBNOLA : NOMBRE DE NOEUDS "LAGRANGE" DE MAG.
C     NBNOT2 : NOMBRE DE NOEUDS TOTAL DE MAG "APRES"
C              (APRES AVOIR CONFONDU CERTAINS NOEUDS)
C              (NBNOT2= NBNOLA+NBNOP2)
C
C ----------------------------------------------------------------------
      CALL JEMARQ()
      CALL JEVEUO(MAG//'.DIME','E',IADIME)
      NBNOPH= ZI(IADIME-1+1)
      NBNOLA= ZI(IADIME-1+2)
      NBMA = ZI(IADIME-1+3)
      NBSMA= ZI(IADIME-1+4)
      CALL JEVEUO(MAG//'.COORDO_2','L',IACOO2)
      CALL JEVEUO(MAG//'.NOEUD_CONF','E',IANCNF)
      CALL JEVEUO(MAG//'.NOMNOE_2','L',IANON2)
C
      IF (NBSMA.GT.0) CALL JEVEUO(MAG//'.DIME_2','L',IADIM2)
      IF (NBSMA.GT.0) CALL JEVEUO(MAG//'.NOMACR','L',IANMCR)
C
C
C     -- ON COMPTE LES NOEUDS PHYSIQUES REELLEMENT CONSERVES :
C     -------------------------------------------------------
      ICO=0
      DO 1, INO=1,NBNOPH
        IF (ZI(IANCNF-1+INO).EQ.INO) ICO=ICO+1
 1    CONTINUE
      NBNOP2=ICO
      NBNOT2= NBNOP2+NBNOLA
      NBNOCO= NBNOPH-NBNOP2
C
      CALL JECREO(MAG//'.NOMNOE','G N K8')
      CALL JEECRA(MAG//'.NOMNOE','NOMMAX',NBNOT2,KBID)
C
C
C     -- CREATION DE .TYPL :
C     ----------------------
      IF(NBNOLA.GT.0) THEN
        CALL WKVECT(MAG//'.TYPL','G V I',NBNOLA,IATYPL)
        DO 2 ,ISMA=1,NBSMA
          NOMACR= ZK8(IANMCR-1+ISMA)
          CALL JEVEUO(NOMACR//'.CONX','L',IACONX)
          CALL JEVEUO(JEXNUM(MAG//'.SUPMAIL',ISMA),'L',IASUPM)
          NBNOE=ZI(IADIM2-1+4*(ISMA-1)+1)
          NBNOL=ZI(IADIM2-1+4*(ISMA-1)+2)
          NBNOET= NBNOE+NBNOL
          DO 21, I=1,NBNOET
            INO=ZI(IASUPM-1+I)
            IF (INO.GT.NBNOPH) THEN
              ZI(IATYPL-1+INO-NBNOPH)= ZI(IACONX-1+3*(I-1)+3)
            END IF
 21       CONTINUE
 2      CONTINUE
      END IF
C
C
C     -- CREATION DU CHAMP .COORDO :
C     ------------------------------
      COORDO= MAG//'.COORDO'
C
      CALL JENONU(JEXNOM('&CATA.GD.NOMGD','GEOM_R'),IGEOMR)
      CALL WKVECT(COORDO//'.DESC','G V I',3,IADESC)
      CALL JEECRA(COORDO//'.DESC','DOCU',IBID,'CHNO')
      ZI (IADESC-1+1)= IGEOMR
C     -- TOUJOURS 3 COMPOSANTES X, Y ET Z
      ZI (IADESC-1+2)= -3
C     -- 14 = 2**1 + 2**2 + 2**3
      ZI (IADESC-1+3)= 14
C
      CALL WKVECT(COORDO//'.REFE','G V K24',2,IAREFE)
      ZK24(IAREFE-1+1)= MAG
      CALL WKVECT(COORDO//'.VALE','G V R',3*NBNOP2,IAVALE)
C     -- NOM DES NOEUDS PHYSIQUES (ET LEUR COORDONNEES) :
      ICO=0
      DO 3 , INO=1, NBNOPH
        JNO=ZI(IANCNF-1+INO)
        IF (INO.NE.JNO) GO TO 3
        ICO= ICO+1
        IF (ZK8(IANON2-1+INO).NE.' ') THEN
          NOMNOE=ZK8(IANON2-1+INO)
        ELSE
          NOMNOE='N?'
          CALL CODENT(ICO,'G',NOMNOE(2:8))
        END IF
        CALL JECROC(JEXNOM(MAG//'.NOMNOE',NOMNOE))
        DO 31, K=1,3
          ZR(IAVALE-1+3*(ICO-1)+K)=ZR(IACOO2-1+3*(INO-1)+K)
 31     CONTINUE
 3    CONTINUE
C     -- NOM DES NOEUDS DE LAGRANGE :
      NOMNOE='&?'
      DO 4 , INO=1, NBNOLA
        CALL CODENT(INO,'G',NOMNOE(2:8))
        CALL JECROC(JEXNOM(MAG//'.NOMNOE',NOMNOE))
 4    CONTINUE
C
C
C     -- ON OTE LA "RECURSIVITE" DE .NOEUD_CONF:
C     ------------------------------------------
 5    CONTINUE
      RECOM=.FALSE.
      DO 6 ,INO=1,NBNOPH
        JNO=ZI(IANCNF-1+INO)
        IF (JNO.NE.INO) THEN
          CALL ASSERT(JNO.LE.INO)
          KNO=ZI(IANCNF-1+JNO)
          IF (KNO.NE.JNO) THEN
            ZI(IANCNF-1+INO)= KNO
            RECOM= .TRUE.
          END IF
        END IF
 6    CONTINUE
      IF (RECOM) GO TO 5
C
C
C     -- ON COMPACTE LES NUMEROS DES NOEUDS CONSERVES:
C     ------------------------------------------------
      CALL WKVECT(MAG//'.NENO','V V I',NBNOPH,IANENO)
      ICO = 0
      DO 7 ,INO=1,NBNOPH
        JNO=ZI(IANCNF-1+INO)
        IF (JNO.EQ.INO) THEN
          ICO= ICO+1
          ZI(IANENO-1+INO)=ICO
        END IF
 7    CONTINUE
C
C
C     -- MODIFICATION DES OBJETS POUR TENIR COMPTE DE .NOEUD_CONF:
C     -------------------------------------------------------------
C
C     -- MODIFICATION DE .CONNEX:
C     ---------------------------
      IF (NBMA.GT.0) THEN
        CALL JEVEUO(MAG//'.CONNEX','E',IACOEX)
        CALL JEVEUO(JEXATR(MAG//'.CONNEX','LONCUM'),'L',ILCOEX)
      END IF
      DO 81,IMA=1,NBMA
        NBNO= ZI(ILCOEX-1+IMA+1)-ZI(ILCOEX-1+IMA)
        I2COEX=IACOEX-1+ZI(ILCOEX-1+IMA)
        DO 811, I=1,NBNO
          INO=ZI(I2COEX-1+I)
          IF (INO.LE.NBNOPH) THEN
            JNO=ZI(IANENO-1+ ZI(IANCNF-1+INO))
            ZI(I2COEX-1+I)=JNO
          ELSE
            ZI(I2COEX-1+I)=INO-NBNOCO
          END IF
 811    CONTINUE
 81   CONTINUE
C
C     -- MODIFICATION DE .SUPMAIL:
C     ----------------------------
      DO 82,ISMA=1,NBSMA
        CALL JEVEUO(JEXNUM(MAG//'.SUPMAIL',ISMA),'E',IASUPM)
        NBNOE=ZI(IADIM2-1+4*(ISMA-1)+1)
        NBNOL=ZI(IADIM2-1+4*(ISMA-1)+2)
        NBNOET= NBNOE+NBNOL
        DO 821, I=1,NBNOET
          INO=ZI(IASUPM-1+I)
          IF (INO.LE.NBNOPH) THEN
            JNO=ZI(IANENO-1+ ZI(IANCNF-1+INO))
            ZI(IASUPM-1+I)=JNO
          ELSE
            ZI(IASUPM-1+I)=INO-NBNOCO
          END IF
 821    CONTINUE
 82   CONTINUE
C
C     -- MODIFICATION DE .GROUPENO:
C     ----------------------------
      CALL JEEXIN(MAG//'.GROUPENO',IRET)
      IF (IRET.GT.0) THEN
        CALL JELIRA(MAG//'.GROUPENO','NUTIOC',NBGNO,KBID)
        DO 9 ,IGNO=1,NBGNO
          CALL JEVEUO(JEXNUM(MAG//'.GROUPENO',IGNO),'E',IAGNO)
          CALL JELIRA(JEXNUM(MAG//'.GROUPENO',IGNO),'LONMAX',
     &                NBNOGN,KBID)
          DO 91, I=1,NBNOGN
            INO=ZI(IAGNO-1+I)
            JNO=ZI(IANENO-1+ ZI(IANCNF-1+INO))
            ZI(IAGNO-1+I)=JNO
 91       CONTINUE
 9      CONTINUE
      END IF
C
C
C     -- REMISE A JOUR DEFINITIVE DU NOMBRE DE NOEUDS PHYSIQUES:
C     ----------------------------------------------------------
      ZI(IADIME-1+1)=NBNOP2
C
C
 9999 CONTINUE
      CALL JEDEMA()
      END
