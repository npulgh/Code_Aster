      SUBROUTINE MSTGET(NOMCMP,MATRIC,MOTFAC,NBIND,DDLSTA)
      IMPLICIT REAL*8 (A-H,O-Z)
      INTEGER                                NBIND,DDLSTA(*)
      CHARACTER*(*)     NOMCMP,MATRIC,MOTFAC
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGELINE  DATE 21/06/2011   AUTEUR CORUS M.CORUS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2011  EDF R&D                  WWW.CODE-ASTER.ORG
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
C     ------------------------------------------------------------------
C     OPERATEUR : MODE_STATIQUE
C     RECUPERATION DES DDL SUR LESQUELS IL FAUT CALCULER DES MODES STATS
C     ------------------------------------------------------------------
C IN  : NOMCMP : NOM DE LA COMMANDE
C IN  : MATRIC : NOM DE LA MATRICE ASSEMBLEE DU SYSTEME
C IN  : MOTFAC : MOT FACTEUR  'MODE_STAT', 'FORCE_NODALE', 'PSEUDO_MODE'
C IN  : NBIND  : NOMBRE DE MOT CLE FACTEUR
C OUT : DDLSTA : TABLEAU DES DDL
C                DDLSTA(I) = 0  PAS DE MODE STATIQUE POUR LE DDL I
C                DDLSTA(I) = 1  MODE STATIQUE POUR LE DDL I
C     ------------------------------------------------------------------
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
      CHARACTER*32     JEXNOM, JEXNUM
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C     ------------------------------------------------------------------
      INTEGER      NEQ
      CHARACTER*8  NOMMA, NOMGR, NOMNOE, KBID
      CHARACTER*14 NUME
      CHARACTER*24 MANONO, MAGRNO, TEXTE, TEXT1, TEXT2, TEXT3
      CHARACTER*24 VALK(4)
C     ------------------------------------------------------------------
C
      CALL JEMARQ()
      MAGRNO = ' '
      MANONO = ' '
      TEXT1 = 'UN DDL N EST PAS BLOQUE '
      TEXT2 = 'UN DDL N EST PAS LIBRE  '
      TEXT3 = 'UN DDL EST UN LAGRANGE  '
C
      CALL DISMOI('F','NOM_MAILLA'  ,MATRIC,'MATR_ASSE',IBID,NOMMA,IERD)
      CALL DISMOI('F','NOM_NUME_DDL',MATRIC,'MATR_ASSE',IBID,NUME ,IERD)
      CALL DISMOI('F','NB_EQUA'     ,MATRIC,'MATR_ASSE',NEQ ,KBID ,IERD)
      MAGRNO = NOMMA//'.GROUPENO'
      MANONO = NOMMA//'.NOMNOE'
      CALL WKVECT('&&MSTGET.LISTE.LAGRAN','V V I',NEQ,LLAG)
      CALL WKVECT('&&MSTGET.LISTE.BLOQUE','V V I',NEQ,LBLO)
      CALL WKVECT('&&MSTGET.LISTE.ACTIF' ,'V V I',NEQ,LACT)
      CALL WKVECT('&&MSTGET.LISTE.ACTBLO','V V I',NEQ,LACB)
      CALL TYPDDL('LAGR',NUME,NEQ,ZI(LLAG),NBA,NBB,NBL,NBLIAI)
      CALL TYPDDL('BLOQ',NUME,NEQ,ZI(LBLO),NBA,NBB,NBL,NBLIAI)
      CALL TYPDDL('ACTI',NUME,NEQ,ZI(LACT),NBA,NBB,NBL,NBLIAI)
      CALL TYPDDL('ACBL',NUME,NEQ,ZI(LACB),NBA,NBB,NBL,NBLIAI)
C
      IF (MOTFAC(1:9).EQ.'MODE_STAT') THEN
         JIND1 = LBLO
         JIND2 = LACT
         TEXTE = TEXT1
      ELSEIF (MOTFAC(1:12).EQ.'FORCE_NODALE') THEN
         JIND1 = LACT
         JIND2 = LBLO
         TEXTE = TEXT2
      ELSEIF (MOTFAC(1:11).EQ.'PSEUDO_MODE') THEN
         JIND1 = LACB
         JIND2 = LLAG
         TEXTE = TEXT3
      ELSEIF (MOTFAC(1:11).EQ.'MODE_INTERF') THEN
         JIND1 = LBLO
         JIND2 = LACT
         TEXTE = TEXT1
      ELSE
         CALL U2MESS('F','ALGELINE2_5')
      ENDIF

      DO 10 I = 1,NBIND
         IF (MOTFAC(1:11).EQ.'PSEUDO_MODE') THEN
            CALL GETVTX(MOTFAC,'AXE',I,1,0,KBID,NA)
            CALL GETVTX(MOTFAC,'DIRECTION',I,1,0,KBID,ND)
            IF ((NA+ND).NE.0)  GOTO 10
         ENDIF

C
C        --- LES NOEUDS ---
         CALL GETVTX(MOTFAC,'TOUT',I,1,0,KBID,NT)
         IF (NT.NE.0) THEN
            LNOE = JIND1
         ENDIF
C
         CALL GETVEM(NOMMA,'NOEUD',MOTFAC,'NOEUD',
     &       I,1,0,KBID,NNOE)
         IF (NNOE.NE.0) THEN
            NNOE = -NNOE
            CALL WKVECT('&&MSTGET.NOM.NOEUD','V V K8',NNOE,JNOE)
            CALL GETVEM(NOMMA,'NOEUD',MOTFAC,'NOEUD',
     &          I,1,NNOE,ZK8(JNOE),NI)
            CALL WKVECT('&&MSTGET.LISTE.NOEUD','V V I',NEQ,LNOE)
            CALL NOEDDL(NUME,NNOE,ZK8(JNOE),NEQ,ZI(LNOE))
         ENDIF
C
         CALL GETVEM(NOMMA,'GROUP_NO',MOTFAC,'GROUP_NO',
     &          I,1,0,KBID,NBGR)
         IF (NBGR.NE.0) THEN
            NBGR = -NBGR
            CALL WKVECT('&&MSTGET.GROUP_NO','V V K8',NBGR,IDGN)
            CALL GETVEM(NOMMA,'GROUP_NO',MOTFAC,'GROUP_NO',
     &             I,1,NBGR,ZK8(IDGN),NI)
C           --- ECLATE LE GROUP_NO EN NOEUD ---
            CALL COMPNO(NOMMA,NBGR,ZK8(IDGN),NNOE)
            CALL WKVECT('&&MSTGET.POSITION.NOEUD','V V K8',NNOE,JNOE)
            II = -1
            DO 18 ING = 1,NBGR
               NOMGR = ZK8(IDGN+ING-1)
               CALL JELIRA(JEXNOM(MAGRNO,NOMGR),'LONUTI',NB,KBID)
               CALL JEVEUO(JEXNOM(MAGRNO,NOMGR),'L',LDGN)
               DO 20 IN = 0,NB-1
                  CALL JENUNO(JEXNUM(MANONO,ZI(LDGN+IN)),NOMNOE)
                  II = II + 1
                  ZK8(JNOE+II) = NOMNOE
 20            CONTINUE
 18         CONTINUE
            CALL WKVECT('&&MSTGET.LISTE.NOEUD','V V I',NEQ,LNOE)
            CALL NOEDDL(NUME,NNOE,ZK8(JNOE),NEQ,ZI(LNOE))
         ENDIF
C
C        --- LES COMPOSANTES ---
         CALL GETVTX(MOTFAC,'TOUT_CMP',I,1,0,KBID,NTC)
         IF (NTC.NE.0) THEN
            CALL WKVECT('&&MSTGET.LISTE.CMP','V V I',NEQ,LCMP)
            DO 26 IEQ = 0,NEQ-1
               ZI(LCMP+IEQ) = 1
 26         CONTINUE
         ENDIF
C
         CALL GETVTX(MOTFAC,'AVEC_CMP',I,1,0,KBID,NAC)
         IF (NAC.NE.0) THEN
            NCMP = -NAC
            CALL WKVECT('&&MSTGET.NOM.CMP','V V K8',NCMP,JCMP)
            CALL GETVTX(MOTFAC,'AVEC_CMP',I,1,NCMP,ZK8(JCMP),NI)
            CALL WKVECT('&&MSTGET.LISTE.CMP','V V I',NEQ*NCMP,LCMP)
            CALL PTEDDL('NUME_DDL',NUME,NCMP,ZK8(JCMP),NEQ,ZI(LCMP))
            DO 28 IC = 2,NCMP
               IND = (IC-1)*NEQ
               DO 30 IEQ = 0,NEQ-1
                  ZI(LCMP+IEQ)= MAX(ZI(LCMP+IND+IEQ),ZI(LCMP+IEQ))
 30            CONTINUE
 28         CONTINUE
         ENDIF
C
         CALL GETVTX(MOTFAC,'SANS_CMP',I,1,0,KBID,NSC)
         IF (NSC.NE.0) THEN
            NCMP = -NSC
            CALL WKVECT('&&MSTGET.NOM.CMP','V V K8',NCMP,JCMP)
            CALL GETVTX(MOTFAC,'SANS_CMP',I,1,NCMP,ZK8(JCMP),NI)
            NCMP = NCMP + 1
            ZK8(JCMP+NCMP-1) = 'LAGR'
            CALL WKVECT('&&MSTGET.LISTE.CMP','V V I',NEQ*NCMP,LCMP)
            CALL PTEDDL('NUME_DDL',NUME,NCMP,ZK8(JCMP),NEQ,ZI(LCMP))
            DO 32 IC = 2,NCMP
               IND = (IC-1)*NEQ
               DO 34 IEQ = 0,NEQ-1
                  ZI(LCMP+IEQ)= MAX(ZI(LCMP+IND+IEQ),ZI(LCMP+IEQ))
 34            CONTINUE
 32         CONTINUE
            DO 36 IEQ = 0,NEQ-1
               ZI(LCMP+IEQ)= 1 - ZI(LCMP+IEQ)
 36         CONTINUE
         ENDIF
C
C        --- ON VERIFIE :
C               POUR DDL_IMPO TOUS LES DDL DONNES SONT BLOQUES
C               POUR FORCE_NODALE TOUS LES DDL DONNES SONT LIBRES
C
         DO 38 IEQ = 0,NEQ-1
            II = IEQ + 1
            IMODE = ZI(LNOE+IEQ) * ZI(LCMP+IEQ)
            III   = ZI(JIND2+IEQ) * IMODE
            IF (III.NE.0) THEN
            CALL RGNDAS('NUME_DDL',NUME,II,NOMNOE,NOMCMP,KBID,KBID,KBID)
               VALK (1) = TEXTE
               VALK (2) = MOTFAC
               VALK (3) = NOMNOE
               VALK (4) = NOMCMP
               CALL U2MESG('E', 'ALGELINE4_24',4,VALK,0,0,0,0.D0)
               IMODE = 0
            ENDIF
            DDLSTA(II)= MAX(DDLSTA(II),IMODE)
 38      CONTINUE
C
C        --- NETTOYAGE ---
C
         CALL JEEXIN('&&MSTGET.LISTE.NOEUD',IRET)
         IF (IRET.GT.0) CALL JEDETR('&&MSTGET.LISTE.NOEUD')
         CALL JEDETR('&&MSTGET.LISTE.CMP')
         CALL JEEXIN('&&MSTGET.NOM.NOEUD',IRET)
         IF (IRET.GT.0) CALL JEDETR('&&MSTGET.NOM.NOEUD')
         CALL JEEXIN('&&MSTGET.POSITION.NOEUD',IRET)
         IF (IRET.GT.0) CALL JEDETR('&&MSTGET.POSITION.NOEUD')
         CALL JEEXIN('&&MSTGET.GROUP_NO',IRET)
         IF (IRET.GT.0) CALL JEDETR('&&MSTGET.GROUP_NO')
         CALL JEEXIN('&&MSTGET.NOM.CMP',IRET)
         IF (IRET.GT.0) CALL JEDETR('&&MSTGET.NOM.CMP')
C
 10   CONTINUE
      CALL JEDETR('&&MSTGET.LISTE.LAGRAN')
      CALL JEDETR('&&MSTGET.LISTE.BLOQUE')
      CALL JEDETR('&&MSTGET.LISTE.ACTIF' )
      CALL JEDETR('&&MSTGET.LISTE.ACTBLO')
C

      CALL JEDEMA()
      END
