      SUBROUTINE RDTMAI(NOMA,NOMARE,BASE,CORRN,CORRM,NBMAL,LIMA)
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      CHARACTER*8 NOMA,NOMARE
      CHARACTER*(*) CORRN,CORRM
      CHARACTER*1 BASE
      INTEGER NBMAL, LIMA(*)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
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
C RESONSABLE
C
C ======================================================================
C     BUT: REDUIRE UN MAILLAGE SUR UNE LISTE DE MAILLES
C
C  NOMA : IN  : MAILLAGE A REDUIRE
C  NOMARE : OUT : MAILLAGE REDUIT
C  BASE   : IN  : 'G' OU 'V' : BASE POUR LA CREATION DE NOMARE
C  CORRN  : IN/JXOUT : SI != ' ' : NOM DE L'OBJET QUI CONTIENDRA
C           LA CORRESPONDANCE INO_RE -> INO
C  CORRM  : IN/JXOUT : SI != ' ' : NOM DE L'OBJET QUI CONTIENDRA
C           LA CORRESPONDANCE IMA_RE -> IMA
C  NBMAL  : IN   : / =0 => LA LISTE DE MAILLES EST OBTENUE EN SCRUTANT
C                          LE MOT CLE RESTREINT
C                : / >0 => LA LISTE DE MAILLE EST FOURNIE PAR LIMA
C  LIMA   : IN   : SI NBMAL> 0 : LISTE DES NUMEROS DE MAILLES SUR
C                  LESQUELLES IL FAUT REDUIRE LE MAILLAGE.
C ======================================================================
C
      INTEGER NBMAOU,NBNOIN,IRET,JNUMA,JWK1,JCONX1,JCONX2,IMA,NUMA,NBNO
      INTEGER INO,NUNO,JDIM,ITYPOU,ITYPIN,JADIN,JADOU,IBID,JCORIN,JCOROU
      INTEGER IAD,NTGEO,NBNOOU,NBNOMX,JWK2,NBGMA,JGMA,IGM,NBMA,NBMAIN
      INTEGER JWK3,NBGMIN,JGMANV,NBGMNV,K,JNMPG,NMPG,NBGNO
      INTEGER NBGNIN,JGNONV,JNNPG,NBGNNV,IGN,NNPG,JNUGN,NUMGNO
      INTEGER JCORRM,IMAIN,IMAOU
      CHARACTER*4 DOCU
      CHARACTER*8 TYPMCL(2),NOMRES
      CHARACTER*16 MOTCLE(2),NOMCMD,TYPRES
      CHARACTER*8 K8B,NOMMA,NOMNO,NOMGMA,TTGRMA,TTGRNO,NOMGNO,VALK(2)
      CHARACTER*24 NOMMAI,NOMNOE,GRPNOE,COOVAL,COOREF,COODSC
      CHARACTER*24 GRPMAI,CONNEX,TYPMAI,DIMIN,DIMOU
      LOGICAL LVIDE,LCAAY
      INTEGER      IARG

      CALL JEMARQ()

      CALL ASSERT(NOMA.NE.NOMARE)
      CALL ASSERT(BASE.EQ.'V' .OR. BASE.EQ.'G')
C
C
C -1- PRELIMINAIRES
C     ============

      CALL GETRES(NOMRES,TYPRES,NOMCMD)
      LCAAY=(NOMCMD.EQ.'IMPR_CAAY')
C     LCAAY => ON IMPRIME AUSSI LES GROUPES VIDES
      IF (LCAAY) CALL ASSERT(NBMAL.GT.0)

C
C --- CALCUL DE LA LISTE DES MAILLES SUR LESQUELLES IL FAUT REDUIRE :
      IF (NBMAL.EQ.0) THEN
      MOTCLE(1)='GROUP_MA'
      MOTCLE(2)='MAILLE'
      TYPMCL(1)='GROUP_MA'
      TYPMCL(2)='MAILLE'
      CALL RELIEM(' ',NOMA,'NU_MAILLE','RESTREINT',1,2,MOTCLE,TYPMCL,
     &            '&&RDTMAI.NUM_MAIL_IN',NBMAOU)
      CALL JEVEUO('&&RDTMAI.NUM_MAIL_IN','L',JNUMA)
      ELSE
        NBMAOU=NBMAL
        CALL WKVECT('&&RDTMAI.NUM_MAIL_IN','V V I',NBMAOU,JNUMA)
        DO 11, K=1,NBMAOU
          ZI(JNUMA-1+K)=LIMA(K)
11      CONTINUE
      ENDIF

      CALL DISMOI('F','NB_NO_MAILLA',NOMA,'MAILLAGE',NBNOIN,K8B,IRET)
      CALL DISMOI('F','NB_MA_MAILLA',NOMA,'MAILLAGE',NBMAIN,K8B,IRET)

C --- CREATION DE TABLEAUX DE TRAVAIL:
C     ZI(JWK1) :
C     - DIMENSIONNE AU NOMBRE DE NOEUDS DU MAILLAGE IN
C     - CORRESPONDANCE : NUMEROS DES NOEUDS MAILLAGE IN => MAILLAGE OUT
C     - EX: ZI(JWK1+INO1-1)=INO2
C         -> SI INO2!=0:LE NOEUD INO1 DU MAILLAGE IN CORRESPOND AU NOEUD
C                       INO2 DU MAILLAGE OUT.
C         -> SI INO2=0: LE NOEUD INO1 DU MAILLAGE IN N'EST PAS PRESENT
C                       DANS LE MAILLAGE OUT.

      CALL WKVECT('&&RDTMAI_WORK_1','V V I',NBNOIN,JWK1)

C     ZI(JWK2) : (L'INVERSE DE ZI(JWK1))
C     - DIMENSIONNE AU NOMBRE DE NOEUDS DU MAILLAGE IN
C     - CORRESPONDANCE : NUMEROS DES NOEUDS MAILLAGE OUT => MAILLAGE IN
C     - EX: ZI(JWK1+INO1-1)=INO2
C        -> LE NOEUD INO1 DU MAILLAGE OUT CORRESPOND AU NOEUD
C           INO2 DU MAILLAGE IN.
      CALL WKVECT('&&RDTMAI_WORK_2','V V I',NBNOIN,JWK2)

C     ZI(JWK3) :
C     - DIMENSIONNE AU NOMBRE DE MAILLES DU MAILLAGE IN
C     - CORRESPONDANCE : NUMEROS DES MAILLES MAILLAGE IN => MAILLAGE OUT
C     - EX: ZI(JWK3+IMA1-1)=IMA2
C         -> SI IMA2!=0:LA MAILLE IMA1 DU MAILLAGE IN CORRESPOND A
C                       LA MAILLE IMA2 DU MAILLAGE OUT.
C         -> SI IMA2=0: LA MAILLE IMA1 DU MAILLAGE IN N'EST PAS PRESENTE
C                       DANS LE MAILLAGE OUT.
      CALL WKVECT('&&RDTMAI_WORK_3','V V I',NBMAIN,JWK3)


C ---  REMPLISSAGE DES TABLEAUX DE TRAVAIL
      CALL JEVEUO(NOMA//'.CONNEX','L',JCONX1)
      CALL JEVEUO(JEXATR(NOMA//'.CONNEX','LONCUM'),'L',JCONX2)
      NBNOOU=0
      DO 20 IMA=1,NBMAOU
        NUMA=ZI(JNUMA+IMA-1)
        ZI(JWK3+NUMA-1)=IMA
        NBNO=ZI(JCONX2+NUMA)-ZI(JCONX2+NUMA-1)
        DO 10 INO=1,NBNO
          NUNO=ZI(JCONX1-1+ZI(JCONX2+NUMA-1)+INO-1)
          IF (ZI(JWK1+NUNO-1).EQ.0) THEN
            NBNOOU=NBNOOU+1
            ZI(JWK1+NUNO-1)=NBNOOU
            ZI(JWK2+NBNOOU-1)=NUNO
          ENDIF
   10   CONTINUE
   20 CONTINUE

C
C -2- CREATION DU NOUVEAU MAILLAGE
C     ============================
C
      NOMMAI=NOMARE//'.NOMMAI         '
      NOMNOE=NOMARE//'.NOMNOE         '
      GRPNOE=NOMARE//'.GROUPENO       '
      GRPMAI=NOMARE//'.GROUPEMA       '
      CONNEX=NOMARE//'.CONNEX         '
      TYPMAI=NOMARE//'.TYPMAIL        '
      COOVAL=NOMARE//'.COORDO    .VALE'
      COODSC=NOMARE//'.COORDO    .DESC'
      COOREF=NOMARE//'.COORDO    .REFE'

C --- OBJET .DIME
      DIMIN=NOMA//'.DIME'
      DIMOU=NOMARE//'.DIME'
      CALL JEDUPO(DIMIN,BASE,DIMOU,.FALSE.)
      CALL JEVEUO(DIMOU,'E',JDIM)
      ZI(JDIM-1+1)=NBNOOU
      ZI(JDIM-1+3)=NBMAOU

C --- OBJET .NOMMAI
      CALL JECREO(NOMMAI,BASE//' N K8')
      CALL JEECRA(NOMMAI,'NOMMAX',NBMAOU,' ')
      DO 30 IMA=1,NBMAOU
        CALL JENUNO(JEXNUM(NOMA//'.NOMMAI',ZI(JNUMA+IMA-1)),NOMMA)
        CALL JECROC(JEXNOM(NOMMAI,NOMMA))
   30 CONTINUE

C --- OBJET .TYPMAIL
      CALL WKVECT(TYPMAI,BASE//' V I',NBMAOU,ITYPOU)
      CALL JEVEUO(NOMA//'.TYPMAIL','L',ITYPIN)
      DO 40 IMA=1,NBMAOU
        ZI(ITYPOU-1+IMA)=ZI(ITYPIN-1+ZI(JNUMA+IMA-1))
   40 CONTINUE

C --- OBJET .CONNEX
      CALL JECREC(CONNEX,BASE//' V I','NU','CONTIG','VARIABLE',NBMAOU)
      CALL DISMOI('F','NB_NO_MAX','&CATA','CATALOGUE',NBNOMX,K8B,IRET)

      CALL JEECRA(CONNEX,'LONT',NBNOMX*NBMAOU,' ')
      DO 60 IMA=1,NBMAOU
        CALL JELIRA(JEXNUM(NOMA//'.CONNEX',ZI(JNUMA+IMA-1)),'LONMAX',
     &              NBNO,K8B)
        CALL JEECRA(JEXNUM(CONNEX,IMA),'LONMAX',NBNO,K8B)
        CALL JEVEUO(JEXNUM(NOMA//'.CONNEX',ZI(JNUMA+IMA-1)),'L',JADIN)
        CALL JEVEUO(JEXNUM(CONNEX,IMA),'E',JADOU)
        DO 50 INO=1,NBNO
          ZI(JADOU+INO-1)=ZI(JWK1+ZI(JADIN+INO-1)-1)
   50   CONTINUE
   60 CONTINUE

C --- OBJET .NOMNOE
      CALL JECREO(NOMNOE,BASE//' N K8')
      CALL JEECRA(NOMNOE,'NOMMAX',NBNOOU,' ')
      DO 70 INO=1,NBNOOU
        CALL JENUNO(JEXNUM(NOMA//'.NOMNOE',ZI(JWK2+INO-1)),NOMNO)
        CALL JECROC(JEXNOM(NOMNOE,NOMNO))
   70 CONTINUE

C --- OBJET .COORDO.VALE
      CALL JECREO(COOVAL,BASE//' V R')
      CALL JEECRA(COOVAL,'LONMAX',NBNOOU*3,' ')
      CALL JELIRA(NOMA//'.COORDO    .VALE','DOCU',IBID,DOCU)
      CALL JEECRA(COOVAL,'DOCU',IBID,DOCU)
      CALL JEVEUO(NOMA//'.COORDO    .VALE','L',JCORIN)
      CALL JEVEUO(COOVAL,'E',JCOROU)
      DO 80 INO=1,NBNOIN
        IF (ZI(JWK1+INO-1).NE.0) THEN
          ZR(JCOROU+3*(ZI(JWK1+INO-1)-1))=ZR(JCORIN+3*(INO-1))
          ZR(JCOROU+3*(ZI(JWK1+INO-1)-1)+1)=ZR(JCORIN+3*(INO-1)+1)
          ZR(JCOROU+3*(ZI(JWK1+INO-1)-1)+2)=ZR(JCORIN+3*(INO-1)+2)
        ENDIF
   80 CONTINUE


C --- OBJET COORDO.DESC
      CALL JECREO(COODSC,BASE//' V I')
      CALL JEECRA(COODSC,'LONMAX',3,' ')
      CALL JEECRA(COODSC,'DOCU',0,'CHNO')
      CALL JEVEUO(COODSC,'E',IAD)
      CALL JENONU(JEXNOM('&CATA.GD.NOMGD','GEOM_R'),NTGEO)
      ZI(IAD)=NTGEO
      ZI(IAD+1)=-3
      ZI(IAD+2)=14


C --- OBJET COORDO.REFE
      CALL WKVECT(COOREF,BASE//' V K24',4,IAD)
      ZK24(IAD)=NOMARE


C     --- OBJET .GROUPEMA
C     --------------------
      IF (NBMAL.EQ.0) THEN
        CALL GETVTX('RESTREINT','TOUT_GROUP_MA',1,IARG,1,TTGRMA,IRET)
      ELSE
        TTGRMA='OUI'
      ENDIF
      IF (TTGRMA.EQ.'NON') THEN
C       'TOUT_GROUP_MA'='NON'
        CALL GETVTX('RESTREINT','GROUP_MA',1,IARG,0,K8B,NBGMA)
        NBGMA=-NBGMA
        IF (NBGMA.EQ.0) GOTO 141
        CALL WKVECT('&&RDTMAI_GRMA_FOURNIS','V V K8',NBGMA,JGMA)
        CALL GETVTX('RESTREINT','GROUP_MA',1,IARG,NBGMA,ZK8(JGMA),IRET)
        CALL JECREC(GRPMAI,BASE//' V I','NO','DISPERSE','VARIABLE',
     &              NBGMA)
        DO 100 IGM=1,NBGMA
          NOMGMA=ZK8(JGMA+IGM-1)
          CALL JECROC(JEXNOM(GRPMAI,NOMGMA))
          CALL JELIRA(JEXNOM(NOMA//'.GROUPEMA',NOMGMA),'LONUTI',NBMA,
     &                K8B)
          CALL JEECRA(JEXNOM(GRPMAI,NOMGMA),'LONMAX',MAX(NBMA,1),K8B)
          CALL JEECRA(JEXNOM(GRPMAI,NOMGMA),'LONUTI',NBMA,K8B)
          CALL JEVEUO(JEXNOM(NOMA//'.GROUPEMA',NOMGMA),'L',JADIN)
          CALL JEVEUO(JEXNOM(GRPMAI,NOMGMA),'E',JADOU)
          DO 90 IMA=1,NBMA
            ZI(JADOU+IMA-1)=ZI(JWK3+ZI(JADIN+IMA-1)-1)
   90     CONTINUE
  100   CONTINUE
      ELSE
C       TOUT_GROUP_MA='OUI'
        CALL JELIRA(NOMA//'.GROUPEMA','NOMUTI',NBGMIN,K8B)
        CALL WKVECT('&&RDTMAI_GRMA_NON_VIDES','V V I',NBGMIN,JGMANV)
        CALL WKVECT('&&RDTMAI_NB_MA_PAR_GRMA','V V I',NBGMIN,JNMPG)
        NBGMNV=0
        IF (LCAAY) NBGMNV=NBGMIN
        DO 120 IGM=1,NBGMIN
          CALL JEVEUO(JEXNUM(NOMA//'.GROUPEMA',IGM),'L',JADIN)
          CALL JELIRA(JEXNUM(NOMA//'.GROUPEMA',IGM),'LONUTI',NBMA,K8B)
          NMPG=0
          LVIDE=.TRUE.
          IF (LCAAY) THEN
            LVIDE=.FALSE.
            ZI(JGMANV-1+IGM)=IGM
          ENDIF
          DO 110 IMA=1,NBMA
            IF (ZI(JWK3+ZI(JADIN+IMA-1)-1).NE.0) THEN
              IF (LVIDE) THEN
                NBGMNV=NBGMNV+1
                ZI(JGMANV+NBGMNV-1)=IGM
                LVIDE=.FALSE.
              ENDIF
              NMPG=NMPG+1
            ENDIF
  110     CONTINUE
          IF (.NOT.LVIDE) THEN
            IF (.NOT.LCAAY) THEN
              ZI(JNMPG+NBGMNV-1)=NMPG
            ELSE
              ZI(JNMPG+IGM-1)=NMPG
            ENDIF
          ENDIF
  120   CONTINUE
        CALL JECREC(GRPMAI,BASE//' V I','NO','DISPERSE','VARIABLE',
     &              NBGMNV)
        DO 140 IGM=1,NBGMNV
          CALL JENUNO(JEXNUM(NOMA//'.GROUPEMA',ZI(JGMANV+IGM-1)),NOMGMA)
          CALL JECROC(JEXNOM(GRPMAI,NOMGMA))
          CALL JELIRA(JEXNOM(NOMA//'.GROUPEMA',NOMGMA),'LONUTI',NBMA,
     &                K8B)
          IBID=MAX(ZI(JNMPG+IGM-1),1)
          CALL JEECRA(JEXNOM(GRPMAI,NOMGMA),'LONMAX',IBID,K8B)
          CALL JEECRA(JEXNOM(GRPMAI,NOMGMA),'LONUTI',ZI(JNMPG+IGM-1),
     &                K8B)
          CALL JEVEUO(JEXNOM(NOMA//'.GROUPEMA',NOMGMA),'L',JADIN)
          CALL JEVEUO(JEXNOM(GRPMAI,NOMGMA),'E',JADOU)
          K=0
          DO 130 IMA=1,NBMA
            IF (ZI(JWK3+ZI(JADIN+IMA-1)-1).NE.0) THEN
              K=K+1
              ZI(JADOU+K-1)=ZI(JWK3+ZI(JADIN+IMA-1)-1)
            ENDIF
  130     CONTINUE
  140   CONTINUE
      ENDIF
  141 CONTINUE



C     --- OBJET .GROUPENO
C     --------------------
      IF (NBMAL.EQ.0) THEN
        CALL GETVTX('RESTREINT','TOUT_GROUP_NO',1,IARG,1,TTGRNO,IRET)
        CALL GETVTX('RESTREINT','GROUP_NO',1,IARG,0,K8B,NBGNO)
      ELSE
        TTGRNO='OUI'
        NBGNO=0
      ENDIF

      IF (NBGNO.NE.0) THEN
        NBGNO=-NBGNO
        CALL WKVECT('&&RDTMAI.GRP_NOEU_IN','V V K8',NBGNO,JNUGN)
        CALL GETVTX('RESTREINT','GROUP_NO',1,IARG,NBGNO,ZK8(JNUGN),IRET)
      ENDIF

C     SI 'TOUT_GROUP_NO'='NON' ET 'GROUP_NO' ABSENT => ON SORT
      IF (TTGRNO.EQ.'NON' .AND. NBGNO.EQ.0)GOTO 210

      IF (TTGRNO.EQ.'NON') THEN
C       'TOUT_GROUP_MA'='NON' ET 'GROUP_NO' PRESENT
        CALL ASSERT(.NOT.LCAAY)
        CALL WKVECT('&&RDTMAI_GRNO_NON_VIDES','V V I',NBNOOU,JGNONV)
        CALL WKVECT('&&RDTMAI_NB_NO_PAR_GRNO','V V I',NBNOOU,JNNPG)
        NBGNNV=0
        DO 160 IGN=1,NBGNO
          CALL JENONU(JEXNOM(NOMA//'.GROUPENO',ZK8(JNUGN+IGN-1)),NUMGNO)
          IF(NUMGNO.EQ.0) THEN
             VALK(1) = ZK8(JNUGN+IGN-1)
             VALK(2) = NOMA
             CALL U2MESK('F','CALCULEL6_82', 2 ,VALK)
          ENDIF
          CALL JEVEUO(JEXNOM(NOMA//'.GROUPENO',ZK8(JNUGN+IGN-1)),'L',
     &                JADIN)
          CALL JELIRA(JEXNOM(NOMA//'.GROUPENO',ZK8(JNUGN+IGN-1)),
     &                'LONMAX',NBNO,K8B)
          NNPG=0
          LVIDE=.TRUE.
          DO 150 INO=1,NBNO
            IF (ZI(JWK1+ZI(JADIN+INO-1)-1).NE.0) THEN
              IF (LVIDE) THEN
                NBGNNV=NBGNNV+1
                ZI(JGNONV+NBGNNV-1)=NUMGNO
                LVIDE=.FALSE.
              ENDIF
              NNPG=NNPG+1
            ENDIF
  150     CONTINUE
          IF (.NOT.LVIDE)ZI(JNNPG+NBGNNV-1)=NNPG
  160   CONTINUE

      ELSE
C       TOUT_GROUP_NO='OUI'
        CALL JELIRA(NOMA//'.GROUPENO','NOMUTI',NBGNIN,K8B)
        CALL WKVECT('&&RDTMAI_GRNO_NON_VIDES','V V I',NBGNIN,JGNONV)
        CALL WKVECT('&&RDTMAI_NB_NO_PAR_GRNO','V V I',NBGNIN,JNNPG)
        NBGNNV=0
        IF (LCAAY) NBGNNV=NBGNIN
        DO 180 IGN=1,NBGNIN
          CALL JEVEUO(JEXNUM(NOMA//'.GROUPENO',IGN),'L',JADIN)
          CALL JELIRA(JEXNUM(NOMA//'.GROUPENO',IGN),'LONUTI',NBNO,K8B)
          NNPG=0
          LVIDE=.TRUE.
          IF (LCAAY) THEN
            LVIDE=.FALSE.
            ZI(JGNONV-1+IGN)=IGN
          ENDIF
          DO 170 INO=1,NBNO
            IF (ZI(JWK1+ZI(JADIN+INO-1)-1).NE.0) THEN
              IF (LVIDE) THEN
                NBGNNV=NBGNNV+1
                ZI(JGNONV+NBGNNV-1)=IGN
                LVIDE=.FALSE.
              ENDIF
              NNPG=NNPG+1
            ENDIF
  170     CONTINUE
          IF (.NOT.LVIDE) THEN
            IF (.NOT.LCAAY) THEN
              ZI(JNNPG+NBGNNV-1)=NNPG
            ELSE
              ZI(JNNPG+IGN-1)=NNPG
            ENDIF
          ENDIF
  180   CONTINUE
      ENDIF

C     SI AUCUN GROUPE DE NOEUD N'EST A CREER, ON SORT
      IF (NBGNNV.EQ.0)GOTO 210

      CALL JECREC(GRPNOE,BASE//' V I','NO','DISPERSE','VARIABLE',NBGNNV)
      DO 200 IGN=1,NBGNNV
        CALL JENUNO(JEXNUM(NOMA//'.GROUPENO',ZI(JGNONV+IGN-1)),NOMGNO)
        CALL JECROC(JEXNOM(GRPNOE,NOMGNO))
        CALL JELIRA(JEXNOM(NOMA//'.GROUPENO',NOMGNO),'LONUTI',NBNO,K8B)
        IBID=MAX(ZI(JNNPG+IGN-1),1)
        CALL JEECRA(JEXNOM(GRPNOE,NOMGNO),'LONMAX',IBID,K8B)
        CALL JEECRA(JEXNOM(GRPNOE,NOMGNO),'LONUTI',ZI(JNNPG+IGN-1),K8B)
        CALL JEVEUO(JEXNOM(NOMA//'.GROUPENO',NOMGNO),'L',JADIN)
        CALL JEVEUO(JEXNOM(GRPNOE,NOMGNO),'E',JADOU)
        K=0
        DO 190 INO=1,NBNO
          IF (ZI(JWK1+ZI(JADIN+INO-1)-1).NE.0) THEN
            K=K+1
            ZI(JADOU+K-1)=ZI(JWK1+ZI(JADIN+INO-1)-1)
          ENDIF
  190   CONTINUE
  200 CONTINUE
  210 CONTINUE

      CALL CARGEO(NOMARE)



C     -- SI L'ON SOUHAITE RECUPERER LES TABLEAUX DE CORRESPONDANCE :
      IF (CORRN.NE.' ') THEN
        CALL JUVECA('&&RDTMAI_WORK_2',NBNOOU)
        CALL JEDUPO('&&RDTMAI_WORK_2','V',CORRN,.FALSE.)
      ENDIF
      IF (CORRM.NE.' ') THEN
        CALL WKVECT(CORRM,'V V I',NBMAOU,JCORRM)
        DO 220,IMAIN=1,NBMAIN
          IMAOU=ZI(JWK3-1+IMAIN)
          IF (IMAOU.NE.0) THEN
            ZI(JCORRM-1+IMAOU)=IMAIN
          ENDIF
  220   CONTINUE
      ENDIF

      CALL JEDETR('&&RDTMAI_WORK_1')
      CALL JEDETR('&&RDTMAI_WORK_2')
      CALL JEDETR('&&RDTMAI_WORK_3')

      CALL JEDETR('&&RDTMAI_GRMA_FOURNIS')
      CALL JEDETR('&&RDTMAI_GRNO_FOURNIS')
      CALL JEDETR('&&RDTMAI_GRMA_NON_VIDES')
      CALL JEDETR('&&RDTMAI_GRNO_NON_VIDES')
      CALL JEDETR('&&RDTMAI_NB_MA_PAR_GRMA')
      CALL JEDETR('&&RDTMAI_NB_NO_PAR_GRNO')
      CALL JEDETR('&&RDTMAI.GRP_NOEU_IN')
      CALL JEDETR('&&RDTMAI.NUM_MAIL_IN')

      CALL JEDEMA()

      END
