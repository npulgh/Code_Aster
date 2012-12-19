      SUBROUTINE DETRSD(TYPESD,NOMSD)
      IMPLICIT   NONE
      INCLUDE 'jeveux.h'
      CHARACTER*(*) TYPESD,NOMSD
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 19/12/2012   AUTEUR PELLET J.PELLET 
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
C TOLE CRP_20
C RESPONSABLE PELLET J.PELLET
C ----------------------------------------------------------------------
C  BUT : DETRUIRE UNE STRUCTURE DE DONNEE DONT ON CONNAIT LE TYPE
C  ATTENTION : QUAND ON UTILISE TYPESD=' ', ON APPELLE LA ROUTINE JEDETC
C              QUI EST TRES COUTEUSE EN CPU.
C  IN   TYPESD : TYPE DE LA STRUCTURE DE DONNEE A DETRUIRE
C          'NUME_DDL'     'PROF_CHNO'    'MLTF'
C          'MATR_ASSE'    'VECT_ASSE'    'MATR_ASSE_GENE'
C          'MATR_ELEM'    'VECT_ELEM'   'PARTITION'
C          'VARI_COM'     'FONCTION' (POUR LES FONCTIONS OU NAPPES)
C          'TABLE_SDASTER' 'TABLE_CONTAINER'
C          'SOLVEUR'      'CORRESP_2_MAILLA'
C          'CHAM_NO_S'    'CHAM_ELEM_S'
C          'CHAM_NO'      'CHAM_ELEM'  'CARTE'
C          'CHAMP' (CHAPEAU AUX CHAM_NO/CHAM_ELEM/CARTE/RESUELEM)
C          'CHAMP_GD' (CHAPEAU DESUET AUX CHAM_NO/CHAM_ELEM/...)
C          'RESULTAT'  'LIGREL'  'NUAGE'  'MAILLAGE' 'CRITERE'
C          'LISTR8'    'LISTIS'
C          (OU ' ' QUAND ON NE CONNAIT PAS LE TYPE).
C          'LISTE_CHARGE'
C          'NUML_DDL'
C       NOMSD   : NOM DE LA STRUCTURE DE DONNEES A DETRUIRE
C          NUME_DDL(K14),MATR_ASSE(K19),VECT_ASSE(K19)
C          CHAMP(K19), MATR_ELEM(K8), VECT_ELEM(K8), VARI_COM(K14)
C          DEFI_CONT(K16), RESO_CONT(K14), TABLE(K19)
C          CHAM_NO(K19), CHAM_NO_S(K19),CHAM_ELEM(K19),CHAM_ELEM_S(K19)
C          CRITERE(K19), LISTE_RELA(K19), CABL_PRECONT(K8), ...

C     RESULTAT:
C     ON DETRUIT TOUS LES OBJETS JEVEUX CORRESPONDANT A CES CONCEPTS.
C ----------------------------------------------------------------------
      REAL*8 RBID
      COMPLEX*16 CBID

      INTEGER IRET,IAD,LONG,I,NBCH,JRELR,IBID,NBSD,IFETS,ILIMPI,IDD
      INTEGER IFETM,IFETN,IFETC,ITYOBJ,INOMSD,NBLG,NBPA,NBLP,N1
      INTEGER JLTNS
      CHARACTER*1 K1BID
      CHARACTER*8 METRES,K8BID,K8
      CHARACTER*12 VGE
      CHARACTER*14 NU,COM
      CHARACTER*16 TYP2SD,CORRES
      CHARACTER*19 CHAMP,MATAS,TABLE,SOLVEU,FNC,RESU
      CHARACTER*19 LIGREL,NUAGE,LIGRET,MLTF,STOCK,K19,MATEL,LISTE
      CHARACTER*24 K24B,TYPOBJ,KNOMSD
      LOGICAL LFETI,LBID

C -DEB------------------------------------------------------------------

      CALL JEMARQ()
      TYP2SD = TYPESD

C     ------------------------------------------------------------------
      IF (TYP2SD.EQ.' ') THEN
C     -----------------------
C       TYPE_SD INCONNU => CALL JEDETC => COUT CPU IMPORTANT + DANGER
        CALL JEDETC(' ',NOMSD,1)

C     ------------------------------------------------------------------
      ELSE IF (TYP2SD.EQ.'CABL_PRECONT') THEN
C     ------------------------------------
        K8 = NOMSD
        CALL DETRS2('CARTE',K8//'.CHME.SIGIN')
        CALL DETRS2('LISTE_RELA',K8//'.LIRELA')
        CALL DETRS2('L_TABLE',K8)

C     ------------------------------------------------------------------
      ELSE IF (TYP2SD.EQ.'CHAM_NO_S') THEN
C     ------------------------------------
        K19 = NOMSD
        CALL JEDETR(K19//'.CNSD')
        CALL JEDETR(K19//'.CNSK')
        CALL JEDETR(K19//'.CNSC')
        CALL JEDETR(K19//'.CNSL')
        CALL JEDETR(K19//'.CNSV')

C     ------------------------------------------------------------------
      ELSE IF (TYP2SD.EQ.'CHAM_ELEM_S') THEN
C     --------------------------------------
        K19 = NOMSD
        CALL JEDETR(K19//'.CESD')
        CALL JEDETR(K19//'.CESK')
        CALL JEDETR(K19//'.CESC')
        CALL JEDETR(K19//'.CESL')
        CALL JEDETR(K19//'.CESV')

C     ------------------------------------------------------------------
      ELSE IF (TYP2SD.EQ.'LISTE_RELA') THEN
C     --------------------------------------
        K19 = NOMSD
        CALL JEDETR(K19//'.RLLA')
        CALL JEDETR(K19//'.RLBE')
        CALL JEDETR(K19//'.RLSU')
        CALL JEDETR(K19//'.RLTC')
        CALL JEDETR(K19//'.RLNO')
        CALL JEDETR(K19//'.RLCO')
        CALL JEDETR(K19//'.RLNT')
        CALL JEDETR(K19//'.RLPO')
        CALL JEDETR(K19//'.RLNR')
        CALL JEDETR(K19//'.RLTV')
        CALL JEDETR(K19//'.RLDD')

C     ------------------------------------------------------------------
      ELSE IF (TYP2SD.EQ.'PARTITION') THEN
C     -------------------------------------------
        K8 = NOMSD
        CALL JEDETR(K8//'.PRTI')
        CALL JEDETR(K8//'.PRTK')
        CALL JEDETR(K8//'.NUPROC.MAILLE')

C     ------------------------------------------------------------------
      ELSE IF (TYP2SD.EQ.'CORRESP_2_MAILLA') THEN
C     -------------------------------------------
        CORRES = NOMSD
        CALL JEDETR(CORRES//'.PJXX_K1')
        CALL JEDETR(CORRES//'.PJEF_NB')
        CALL JEDETR(CORRES//'.PJEF_NU')
        CALL JEDETR(CORRES//'.PJEF_M1')
        CALL JEDETR(CORRES//'.PJEF_CF')
        CALL JEDETR(CORRES//'.PJEF_TR')
        CALL JEDETR(CORRES//'.PJEF_CO')
        CALL JEDETR(CORRES//'.PJEF_EL')
        CALL JEDETR(CORRES//'.PJEF_MP')
        CALL JEDETR(CORRES//'.PJNG_I1')
        CALL JEDETR(CORRES//'.PJNG_I2')

C     ------------------------------------------------------------------
      ELSE IF (TYP2SD.EQ.'CRITERE') THEN
C     -----------------------------------
        K19  = NOMSD
        CALL JEDETR(K19//'.CRTI')
        CALL JEDETR(K19//'.CRTR')
        CALL JEDETR(K19//'.CRDE')

C     ------------------------------------------------------------------
      ELSE IF (TYP2SD.EQ.'FONCTION') THEN
C     -----------------------------------
        FNC = NOMSD
        CALL JEDETR(FNC//'.PARA')
        CALL JEDETR(FNC//'.PROL')
        CALL JEDETR(FNC//'.VALE')

C     ------------------------------------------------------------------
      ELSE IF (TYP2SD.EQ.'SOLVEUR') THEN
C     ----------------------------------
        SOLVEU = NOMSD
        CALL JEDETR(SOLVEU//'.SLVI')
        CALL JEDETR(SOLVEU//'.SLVK')
        CALL JEDETR(SOLVEU//'.SLVR')

C DESTRUCTION DE LA LISTE DE SD SOLVEUR LOCAUX SI FETI
        K24B = SOLVEU//'.FETS'
        CALL JEEXIN(K24B,IRET)
C FETI OR NOT ?
        IF (IRET.GT.0) THEN
          LFETI = .TRUE.

        ELSE
          LFETI = .FALSE.
        END IF

        IF (LFETI) THEN
          CALL JELIRA(K24B,'LONMAX',NBSD,K8BID)
          CALL JEVEUO(K24B,'L',IFETS)
          CALL JEVEUO('&FETI.LISTE.SD.MPI','L',ILIMPI)
          DO 10 IDD = 1,NBSD
            IF (ZI(ILIMPI+IDD).EQ.1) THEN
              K19 = ZK24(IFETS+IDD-1) (1:19)
              CALL DETRS2('SOLVEUR',K19)
            END IF

   10     CONTINUE
          CALL JEDETR(K24B)
        END IF

C     ------------------------------------------------------------------
      ELSE IF (TYP2SD.EQ.'VOISINAGE') THEN
C     ----------------------------------
        VGE = NOMSD
        CALL JEDETR(VGE//'.PTVOIS')
        CALL JEDETR(VGE//'.ELVOIS')

C     ------------------------------------------------------------------
      ELSE IF (TYP2SD.EQ.'LIGREL') THEN
C     ----------------------------------
        LIGREL = NOMSD
        CALL JEDETR(LIGREL//'.LGNS')
        CALL JEDETR(LIGREL//'.LIEL')
        CALL JEDETR(LIGREL//'.NEMA')
        CALL JEDETR(LIGREL//'.LGRF')
        CALL JEDETR(LIGREL//'.NBNO')
        CALL JEDETR(LIGREL//'.NVGE')
        CALL JEDETR(LIGREL//'.PRNM')
        CALL JEDETR(LIGREL//'.PRNS')
        CALL JEDETR(LIGREL//'.REPE')
        CALL JEDETR(LIGREL//'.SSSA')

C     ------------------------------------------------------------------
      ELSE IF (TYP2SD.EQ.'LIGRET') THEN
C     ----------------------------------
        LIGRET = NOMSD
        CALL JEDETR(LIGRET//'.APMA')
        CALL JEDETR(LIGRET//'.APNO')
        CALL JEDETR(LIGRET//'.LIMA')
        CALL JEDETR(LIGRET//'.LINO')
        CALL JEDETR(LIGRET//'.LITY')
        CALL JEDETR(LIGRET//'.MATA')
        CALL JEDETR(LIGRET//'.MODE')
        CALL JEDETR(LIGRET//'.NBMA')
        CALL JEDETR(LIGRET//'.LGRF')
        CALL JEDETR(LIGRET//'.PHEN')
        CALL JEDETR(LIGRET//'.POMA')
        CALL JEDETR(LIGRET//'.PONO')

C     ------------------------------------------------------------------
      ELSE IF (TYP2SD.EQ.'SQUELETTE') THEN
C     ----------------------------------
        K8 = NOMSD
        CALL DETRS2('MAILLAGE',K8)
        CALL JEDETR(K8//'.CORRES')
        CALL JEDETR(K8//'         .NOMSST')
        CALL JEDETR(K8//'.ANGL_NAUT')
        CALL JEDETR(K8//'.INV.SKELETON')
        CALL JEDETR(K8//'.TRANS')

C     ------------------------------------------------------------------
      ELSE IF (TYP2SD.EQ.'L_TABLE') THEN
C     ----------------------------------
        K19 = NOMSD
        CALL JEEXIN(K19//'.LTNS',IRET)
        IF (IRET.EQ.0) GOTO 70
        CALL JEVEUO(K19//'.LTNS','L',JLTNS)
        CALL JELIRA(K19//'.LTNS','LONMAX',N1,K1BID)
        DO 1, I=1,N1
          CALL DETRS2('TABLE',ZK24(JLTNS-1+I))
 1      CONTINUE
        CALL JEDETR(K19//'.LTNS')
        CALL JEDETR(K19//'.LTNT')

C     ------------------------------------------------------------------
      ELSE IF (TYP2SD.EQ.'MAILLAGE') THEN
C     ----------------------------------
        K8 = NOMSD
        CALL DETRS2('CHAM_NO',K8//'.COORDO')
        CALL DETRS2('L_TABLE',K8)
        CALL JEDETR(K8//'           .TITR')
        CALL JEDETR(K8//'.CONNEX')
        CALL JEDETR(K8//'.DIME')
        CALL JEDETR(K8//'.GROUPEMA')
        CALL JEDETR(K8//'.GROUPENO')
        CALL JEDETR(K8//'.NOMACR')
        CALL JEDETR(K8//'.NOMMAI')
        CALL JEDETR(K8//'.NOMNOE')
        CALL JEDETR(K8//'.PARA_R')
        CALL JEDETR(K8//'.SUPMAIL')
        CALL JEDETR(K8//'.TYPL')
        CALL JEDETR(K8//'.TYPMAIL')

C     ------------------------------------------------------------------
      ELSE IF (TYP2SD.EQ.'MODELE') THEN
C     ----------------------------------
        K8 = NOMSD
        CALL DETRS2('LIGREL',K8//'.MODELE')
        CALL DETRS2('L_TABLE',K8)

        CALL JEDETR(K8//'           .TITR')
        CALL JEDETR(K8//'.NOEUD')
        CALL JEDETR(K8//'.MAILLE')
        CALL JEDETR(K8//'.PARTIT')


C     ------------------------------------------------------------------
      ELSE IF (TYP2SD.EQ.'NUAGE') THEN
C     ----------------------------------
        NUAGE = NOMSD
        CALL JEDETR(NUAGE//'.NUAI')
        CALL JEDETR(NUAGE//'.NUAX')
        CALL JEDETR(NUAGE//'.NUAV')
        CALL JEDETR(NUAGE//'.NUAL')

C     ------------------------------------------------------------------
      ELSE IF (TYP2SD.EQ.'TABLE_CONTAINER') THEN
C     -----------------------------------
        TABLE = NOMSD
        CALL JEEXIN(TABLE//'.TBLP',IRET)
        IF (IRET.NE.0) THEN
          CALL JEVEUO(TABLE//'.TBNP','L',IAD)
          NBLG=ZI(IAD+1)
          NBPA=ZI(IAD)
          CALL ASSERT(NBPA.GE.3)
          CALL JEVEUO(TABLE//'.TBLP','L',IAD)
          CALL JELIRA(TABLE//'.TBLP','LONMAX',LONG,K1BID)
          NBLP=LONG/NBPA
          DO 25,I = 1,NBPA
            IF(ZK24(IAD+NBLP*(I-1))(1:10).EQ.'TYPE_OBJET')THEN
               TYPOBJ=ZK24(IAD+NBLP*(I-1)+3-1)
            ELSEIF(ZK24(IAD+NBLP*(I-1))(1:6).EQ.'NOM_SD')THEN
               KNOMSD=ZK24(IAD+NBLP*(I-1)+3-1)
            ENDIF
  25      CONTINUE
          CALL JEVEUO(TYPOBJ,'L',ITYOBJ)
          CALL JEVEUO(KNOMSD,'L',INOMSD)
          DO 26,I = 1,NBLG
            IF( ZK16(ITYOBJ+I-1)(1:9).EQ.'MATR_ELEM')THEN
               CALL DETRS2('MATR_ELEM',ZK24(INOMSD+I-1))
            ELSEIF( ZK16(ITYOBJ+I-1)(1:9).EQ.'VECT_ELEM')THEN
               CALL DETRS2('VECT_ELEM',ZK24(INOMSD+I-1))
            ELSEIF( ZK16(ITYOBJ+I-1)(1:9).EQ.'CHAM_ELEM')THEN
               CALL DETRS2('CHAM_ELEM',ZK24(INOMSD+I-1))
            ENDIF
   26     CONTINUE
          DO 27,I = 1,LONG
            CALL JEDETR(ZK24(IAD-1+I))
   27     CONTINUE
          CALL JEDETR(TABLE//'.TBLP')
          CALL JEDETR(TABLE//'.TBNP')
          CALL JEDETR(TABLE//'.TBBA')
        ENDIF
        CALL JEDETR(TABLE//'.TITR')


C     ------------------------------------------------------------------
      ELSE IF (TYP2SD.EQ.'TABLE') THEN
C     --------------------------------
        TABLE = NOMSD
        CALL JEEXIN(TABLE//'.TBLP',IRET)
        IF (IRET.NE.0) THEN
          CALL JEVEUO(TABLE//'.TBLP','L',IAD)
          CALL JELIRA(TABLE//'.TBLP','LONMAX',LONG,K1BID)
          DO 20,I = 1,LONG
            CALL JEDETR(ZK24(IAD-1+I))
   20     CONTINUE
          CALL JEDETR(TABLE//'.TBLP')
          CALL JEDETR(TABLE//'.TBNP')
          CALL JEDETR(TABLE//'.TBBA')
        END IF
        CALL JEDETR(TABLE//'.TITR')

C     ------------------------------------------------------------------
      ELSE IF (TYP2SD.EQ.'MATR_ASSE_GENE' .OR.
     &         TYP2SD.EQ.'MATR_ASSE') THEN
C     ---------------------------------------
        MATAS = NOMSD

C       -- DESTRUCTION DE L'EVENTUELLE INSTANCE MUMPS OU PETSC :
        CALL JEEXIN(MATAS//'.REFA',IRET)
        IF (IRET.GT.0) THEN
          CALL DISMOI('F','METH_RESO',MATAS,'MATR_ASSE',IBID,METRES
     &                                                      ,IBID)
          IF (METRES.EQ.'MUMPS') THEN
            CALL AMUMPH('DETR_MAT',' ',MATAS,RBID,CBID,' ',0,IBID,LBID)
          ELSE IF(METRES.EQ.'PETSC') THEN
            CALL APETSC('DETR_MAT',' ',MATAS,RBID,' ',0,IBID,IRET)
          END IF

        END IF

        CALL JEDETR(MATAS//'.CCID')
        CALL JEDETR(MATAS//'.CCII')
        CALL JEDETR(MATAS//'.CCLL')
        CALL JEDETR(MATAS//'.CCVA')
        CALL JEDETR(MATAS//'.CONL')
        CALL JEDETR(MATAS//'.DESC')
        CALL JEDETR(MATAS//'.DIGS')
        CALL JEDETR(MATAS//'.LIME')
        CALL JEDETR(MATAS//'.REFA')
        CALL JEDETR(MATAS//'.UALF')
        CALL JEDETR(MATAS//'.VALF')
        CALL JEDETR(MATAS//'.VALM')
        CALL JEDETR(MATAS//'.WALF')

C FETI OR NOT ?
        K24B = MATAS//'.FETM'
        CALL JEEXIN(K24B,IRET)
        IF (IRET.GT.0) THEN
          LFETI = .TRUE.
        ELSE
          LFETI = .FALSE.
        END IF

        IF (LFETI) THEN
          CALL JEDETR(MATAS//'.FETF')
          CALL JEDETR(MATAS//'.FETP')
          CALL JEDETR(MATAS//'.FETR')

          CALL JELIRA(K24B,'LONMAX',NBSD,K8BID)
          CALL JEVEUO(K24B,'L',IFETM)
          CALL JEEXIN('&FETI.LISTE.SD.MPI',IRET)
          IF (IRET.GT.0) THEN
            CALL JEVEUO('&FETI.LISTE.SD.MPI','L',ILIMPI)
            DO 30 IDD = 1,NBSD
              IF (ZI(ILIMPI+IDD).EQ.1) THEN
                K19 = ZK24(IFETM+IDD-1) (1:19)
                CALL DETRS2('MATR_ASSE',K19)
              END IF
   30       CONTINUE
          END IF

          CALL JEDETR(K24B)
        END IF

C     ------------------------------------------------------------------
      ELSE IF (TYP2SD.EQ.'CHAM_NO') THEN
C     ----------------------------------
        K19 = NOMSD

        CALL JEDETR(K19//'.DESC')
        CALL JEDETR(K19//'.REFE')
        CALL JEDETR(K19//'.VALE')
C FETI OR NOT ?
        K24B = K19//'.FETC'
        CALL JEEXIN(K24B,IRET)
        IF (IRET.GT.0) THEN
          LFETI = .TRUE.

        ELSE
          LFETI = .FALSE.
        END IF

        IF (LFETI) THEN
          CALL JELIRA(K24B,'LONMAX',NBSD,K8BID)
          CALL JEVEUO(K24B,'L',IFETC)
          CALL JEVEUO('&FETI.LISTE.SD.MPI','L',ILIMPI)
          DO 40 IDD = 1,NBSD
            IF (ZI(ILIMPI+IDD).EQ.1) THEN
              K19 = ZK24(IFETC+IDD-1) (1:19)
              CALL DETRS2('CHAM_NO',K19)
            END IF

   40     CONTINUE
          CALL JEDETR(K24B)
        END IF
C     ------------------------------------------------------------------
      ELSE IF (TYP2SD.EQ.'CARTE') THEN
C     ----------------------------------
        K19 = NOMSD
        CALL JEDETR(K19//'.DESC')
        CALL JEDETR(K19//'.VALE')
        CALL JEDETR(K19//'.NOMA')
        CALL JEDETR(K19//'.NOLI')
        CALL JEDETR(K19//'.LIMA')
        CALL JEDETR(K19//'.PTMA')
        CALL JEDETR(K19//'.PTMS')
        CALL JEDETR(K19//'.NCMP')
        CALL JEDETR(K19//'.VALV')
C     ------------------------------------------------------------------
      ELSE IF (TYP2SD.EQ.'PROF_CHNO') THEN
C     ------------------------------------
        K19 = NOMSD
        CALL JEDETR(K19//'.DEEQ')
        CALL JEDETR(K19//'.LILI')
        CALL JEDETR(K19//'.NUEQ')
        CALL JEDETR(K19//'.PRNO')

      ELSE IF (TYP2SD.EQ.'NUME_EQUA') THEN
C     ------------------------------------
        K19 = NOMSD
        CALL DETRS2('PROF_CHNO',K19)
        CALL JEDETR(K19//'.NEQU')
        CALL JEDETR(K19//'.REFN')
        CALL JEDETR(K19//'.DELG')

C     ------------------------------------------------------------------
      ELSE IF (TYP2SD.EQ.'CHAM_ELEM') THEN
C     ------------------------------------
        K19 = NOMSD
        CALL JEDETR(K19//'.CELD')
        CALL JEDETR(K19//'.CELK')
        CALL JEDETR(K19//'.CELV')

C     ------------------------------------------------------------------
      ELSE IF (TYP2SD.EQ.'RESUELEM') THEN
C     ------------------------------------
        K19 = NOMSD
        CALL JEDETR(K19//'.DESC')
        CALL JEDETR(K19//'.NOLI')
        CALL JEDETR(K19//'.RESL')
        CALL JEDETR(K19//'.RSVI')

C     ------------------------------------------------------------------
      ELSE IF (TYP2SD.EQ.'MLTF') THEN
C     -----------------------------------
        MLTF = NOMSD
        CALL JEDETR(MLTF//'.GLOB')
        CALL JEDETR(MLTF//'.LOCL')
        CALL JEDETR(MLTF//'.ADNT')
        CALL JEDETR(MLTF//'.PNTI')
        CALL JEDETR(MLTF//'.DESC')
        CALL JEDETR(MLTF//'.DIAG')
        CALL JEDETR(MLTF//'.ADRE')
        CALL JEDETR(MLTF//'.SUPN')
        CALL JEDETR(MLTF//'.PARE')
        CALL JEDETR(MLTF//'.FILS')
        CALL JEDETR(MLTF//'.FRER')
        CALL JEDETR(MLTF//'.LGSN')
        CALL JEDETR(MLTF//'.LFRN')
        CALL JEDETR(MLTF//'.NBAS')
        CALL JEDETR(MLTF//'.DEBF')
        CALL JEDETR(MLTF//'.DEFS')
        CALL JEDETR(MLTF//'.ADPI')
        CALL JEDETR(MLTF//'.ANCI')
        CALL JEDETR(MLTF//'.NBLI')
        CALL JEDETR(MLTF//'.LGBL')
        CALL JEDETR(MLTF//'.NCBL')
        CALL JEDETR(MLTF//'.DECA')
        CALL JEDETR(MLTF//'.NOUV')
        CALL JEDETR(MLTF//'.SEQU')
        CALL JEDETR(MLTF//'.RENU')


C     ------------------------------------------------------------------
      ELSE IF (TYP2SD.EQ.'STOCKAGE') THEN
C     -----------------------------------
        STOCK = NOMSD
        CALL JEDETR(STOCK//'.SCBL')
        CALL JEDETR(STOCK//'.SCDI')
        CALL JEDETR(STOCK//'.SCDE')
        CALL JEDETR(STOCK//'.SCHC')
        CALL JEDETR(STOCK//'.SCIB')

        CALL JEDETR(STOCK//'.SMDI')
        CALL JEDETR(STOCK//'.SMDE')
        CALL JEDETR(STOCK//'.SMHC')


C     ------------------------------------------------------------------
      ELSE IF (TYP2SD.EQ.'STOC_LCIEL') THEN
C     -----------------------------------
        STOCK = NOMSD
        CALL JEDETR(STOCK//'.SCBL')
        CALL JEDETR(STOCK//'.SCDI')
        CALL JEDETR(STOCK//'.SCDE')
        CALL JEDETR(STOCK//'.SCHC')
        CALL JEDETR(STOCK//'.SCIB')


C     ------------------------------------------------------------------
      ELSE IF (TYP2SD.EQ.'STOC_MORSE') THEN
C     -----------------------------------
        STOCK = NOMSD
        CALL JEDETR(STOCK//'.SMDI')
        CALL JEDETR(STOCK//'.SMDE')
        CALL JEDETR(STOCK//'.SMHC')

C     ------------------------------------------------------------------
      ELSE IF (TYP2SD.EQ.'NUME_DDL') THEN
C     -----------------------------------
        NU = NOMSD
        CALL DETRS2('NUME_EQUA',NU//'.NUME')
        CALL DETRS2('MLTF',NU//'.MLTF')
        CALL DETRS2('STOCKAGE',NU//'.SLCS')
        CALL DETRS2('STOCKAGE',NU//'.SMOS')
        CALL JEDETR(NU//'.NSLV')

        CALL JEDETR(NU//'.DERLI')
        CALL JEDETR(NU//'.EXISTE')
        CALL JEDETR(NU//'.NUM2')
        CALL JEDETR(NU//'.NUM21')
        CALL JEDETR(NU//'.LSUIVE')
        CALL JEDETR(NU//'.PSUIVE')
        CALL JEDETR(NU//'.VSUIVE')
        CALL JEDETR(NU//'.OLDN')
        CALL JEDETR(NU//'.NEWN')

C FETI OR NOT ?
        K24B = NU//'.FETN'
        CALL JEEXIN(K24B,IRET)
        IF (IRET.GT.0) THEN
          LFETI = .TRUE.

        ELSE
          LFETI = .FALSE.
        END IF

        IF (LFETI) THEN
          CALL JELIRA(K24B,'LONMAX',NBSD,K8BID)
          CALL JEVEUO(K24B,'L',IFETN)
          CALL JEVEUO('&FETI.LISTE.SD.MPI','L',ILIMPI)
          DO 50 IDD = 1,NBSD
            IF (ZI(ILIMPI+IDD).EQ.1) THEN
              K19 = ZK24(IFETN+IDD-1) (1:19)
C RECURSIVITE DE SECOND NIVEAU SUR DETRSD
              CALL DETRS2('NUME_DDL',K19(1:14))
            END IF

   50     CONTINUE
          CALL JEDETR(K24B)
        END IF

C     ------------------------------------------------------------------
      ELSE IF (TYP2SD.EQ.'NUML_DDL') THEN
C     -----------------------------------

        NU = NOMSD
        CALL JEDETR(NU//'.NUML.PRNO')
        CALL JEDETR(NU//'.NUML.NOPR')
        CALL JEDETR(NU//'.NUML.DELG')
        CALL JEDETR(NU//'.NUML.NEQU')
        CALL JEDETR(NU//'.NUML.NULG')
        CALL JEDETR(NU//'.NUML.NUGL')
        CALL JEDETR(NU//'.NUML.NUEQ')

C     ------------------------------------------------------------------
      ELSE IF (TYP2SD.EQ.'VARI_COM') THEN
C     -------------------------------------
        COM = NOMSD
        CALL ASSDE1(COM//'.TEMP')
        CALL ASSDE1(COM//'.HYDR')
        CALL ASSDE1(COM//'.SECH')
        CALL ASSDE1(COM//'.PHAS')
        CALL ASSDE1(COM//'.EPAN')
        CALL ASSDE1(COM//'.INST')
        CALL ASSDE1(COM//'.TOUT')
        CALL JEDETR(COM//'.EXISTENCE')

C     ------------------------------------------------------------------
      ELSE IF ((TYP2SD.EQ.'CHAMP') .OR. (TYP2SD.EQ.'CHAMP_GD')) THEN
C     ---------------------------------------
C       POUR LES CARTE, CHAM_NO, CHAM_ELEM, ET RESU_ELEM :
        CHAMP = NOMSD
        CALL ASSDE1(CHAMP)

C     ------------------------------------------------------------------
      ELSE IF ((TYP2SD.EQ.'MATR_ELEM') .OR.
     &         (TYP2SD.EQ.'VECT_ELEM')) THEN
C     ---------------------------------------
        MATEL = NOMSD
        CALL JEEXIN(MATEL//'.RELR',IRET)
        IF (IRET.LE.0) GO TO 61
        CALL JELIRA(MATEL//'.RELR','LONUTI',NBCH,K1BID)
        IF(NBCH.GT.0) CALL JEVEUO(MATEL//'.RELR','L',JRELR)
        DO 60,I = 1,NBCH
          CHAMP=ZK24(JRELR-1+I)(1:19)
          CALL ASSDE1(CHAMP)
   60   CONTINUE
   61   CONTINUE
        CALL JEDETR(MATEL//'.RELR')
        CALL JEDETR(MATEL//'.RELC')
        CALL JEDETR(MATEL//'.RECC')
        CALL JEDETR(MATEL//'.RERR')

C     ------------------------------------------------------------------
      ELSE IF (TYP2SD.EQ.'RESULTAT') THEN
C     -----------------------------------
        RESU = NOMSD
        CALL JEDETR(RESU//'.DESC')
        CALL JEDETR(RESU//'.TACH')
        CALL JEDETR(RESU//'.TAVA')
        CALL JEDETR(RESU//'.NOVA')
        CALL JEDETR(RESU//'.ORDR')
        CALL JEDETR(RESU//'.REFD')
        CALL JEDETR(RESU//'.RSPR')
        CALL JEDETR(RESU//'.RSPC')
        CALL JEDETR(RESU//'.RSPI')
        CALL JEDETR(RESU//'.RSP8')
        CALL JEDETR(RESU//'.RS16')
        CALL JEDETR(RESU//'.RS24')
        CALL JEDETR(RESU//'.RS32')
        CALL JEDETR(RESU//'.RS80')

C     ------------------------------------------------------------------
      ELSE IF (TYP2SD.EQ.'LISTE_CHARGES') THEN
C     -----------------------------------
        RESU = NOMSD
        CALL JEDETR(RESU//'.LCHA')
        CALL JEDETR(RESU//'.INFC')
        CALL JEDETR(RESU//'.FCHA')

C     ------------------------------------------------------------------
      ELSE IF (TYP2SD.EQ.'LISTR8'.OR.TYP2SD.EQ.'LISTIS') THEN
C     --------------------------------------------------------
        LISTE = NOMSD
        CALL JEDETR(LISTE//'.LPAS')
        CALL JEDETR(LISTE//'.NBPA')
        CALL JEDETR(LISTE//'.BINT')
        CALL JEDETR(LISTE//'.VALE')

C     ------------------------------------------------------------------
      ELSE
        CALL U2MESK('F','UTILITAI_47',1,TYP2SD)
      END IF

   70 CONTINUE
      CALL JEDEMA()
      END
