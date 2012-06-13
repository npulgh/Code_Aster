      SUBROUTINE MTCMBL(NBCOMB,TYPCST,CONST,LIMAT,
     &                  MATREZ,DDLEXC,NUMEDD,ELIM)
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      INTEGER NBCOMB
      CHARACTER*(*) TYPCST(NBCOMB),DDLEXC
      CHARACTER*(*) MATREZ,NUMEDD
      CHARACTER*(*) LIMAT(NBCOMB)
      CHARACTER*5 ELIM
      REAL*8 CONST(*)
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGELINE  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
C RESPONSABLE VABHHTS J.PELLET
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
C     COMBINAISON LINEAIRE DE MATRICES  :
C     -------------------------------------
C     MAT_RES= SOMME(ALPHA_I*MAT_I)

C       *  LES MATRICES (MAT_I) DOIVENT AVOIR LA MEME NUMEROTATION DES
C           DDLS MAIS ELLES PEUVENT AVOIR DES CONNECTIVITES DIFFERENTES
C          (I.E. DES STOCKAGES DIFFERENTS)
C       *  LES MATRICES (MAT_I) SONT REELLES OU COMPLEXES
C       *  LES MATRICES (MAT_I) SONT SYMETRIQUES OU NON
C       *  LES COEFFICIENTS (ALPHA_I) SONT REELS OU COMPLEXES
C       *  ON PEUT MELANGER MATRICES REELLES ET COMPLEXES ET LES TYPES
C          (R/C) DES COEFFICIENTS. ON PEUT FAIRE PAR EXEMPLE :
C          MAT_RES= ALPHA_R1*MAT_C1 + ALPHA_C2*MAT_R2
C       *  MAT_RES DOIT ETRE ALLOUEE AVANT L'APPEL A MTCMBL
C          CELA VEUT DIRE QUE SON TYPE (R/C) EST DEJA DETERMINE.
C       *  SI TYPE(MAT_RES)=R ET QUE CERTAINS (MAT_I/ALPHA_I) SONT C,
C          CELA VEUT SIMPLEMENT DIRE QUE MAT_RES CONTIENDRA LA PARTIE
C          REELLE DE LA COMBINAISON LINEAIRE (QUI EST COMPLEXE)
C
C---------------------------------------------------------------------
C IN  I  NBCOMB = NOMBRE DE MATRICES A COMBINER
C IN  V(K1) TYPCST = TYPE DES CONSTANTES (R/C)
C IN  V(R)  CONST  = TABLEAU DE R*8    DES COEFICIENTS
C     ATTENTION : CONST PEUT ETRE DE DIMENSION > NBCOMB CAR
C                 LES COEFS COMPLEXES SONT STOCKES SUR 2 REELS
C IN  V(K19) LIMAT = LISTE DES NOMS DES MATR_ASSE A COMBINER
C IN/JXOUT K19 MATREZ = NOM DE LA MATR_ASSE RESULTAT
C        CETTE MATRICE DOIT AVOIR ETE CREEE AU PREALABLE (MTDEFS)
C IN  K* DDLEXC = NOM DU DDL A EXCLURE ("LAGR"/" " )

C SI LES MATRICES COMBINEES N'ONT PAS LE MEME STOCKAGE, IL FAUT
C CREER UN NOUVEAU NUME_DDL POUR CE STOCKAGE :
C IN/JXOUT  K14 NUMEDD = NOM DU NUME_DDL SUR LEQUEL S'APPUIERA MATREZ
C        SI NUMEDD ==' ', LE NOM DU NUME_DDL SERA OBTENU PAR GCNCON
C        SI NUMEDD /=' ', ON PRENDRA NUMEDD COMME NOM DE NUME_DDL
C IN    K5  : / 'ELIM=' : SI LES MATRICES A COMBINER N'ONT PAS LES MEMES
C                         DDLS ELIMINES (CHAR_CINE) => ERREUR <F>
C             / 'ELIM1' : LA MATRICE RESULTAT AURA LES MEMES DDLS
C                         ELIMINES QUE LA 1ERE MATRICE DE LA LISTE LIMAT
C---------------------------------------------------------------------
C     -----------------------------------------------------------------
      CHARACTER*1 BASE,BAS2,TYPRES
      CHARACTER*8 KBID,TYPMAT,KMPIC,KMPIC1,KMATD
      CHARACTER*19 MATEMP,MAT1,MATRES,MATI
      CHARACTER*24 VALK(2)
C     -----------------------------------------------------------------
      INTEGER JREFAR,JREFA1,JREFAI,IER,IBID,IDLIMA,IER1
      INTEGER I,LRES,NBLOC,JREFA,LGBLOC
      LOGICAL REUTIL,SYMR,SYMI,IDENOB,MATD
C     -----------------------------------------------------------------

      CALL JEMARQ()

      CALL ASSERT(ELIM.EQ.'ELIM=' .OR. ELIM.EQ.'ELIM1')

      MATRES = MATREZ
      MAT1=LIMAT(1)
      CALL ASSERT(NBCOMB.GE.1)
      CALL JELIRA(MATRES//'.REFA','CLAS',IBID,BASE)
      CALL JELIRA(MATRES//'.VALM','TYPE',IBID,TYPRES)
      CALL JELIRA(MATRES//'.VALM','NMAXOC',NBLOC,KBID)
      CALL JELIRA(MATRES//'.VALM','LONMAX',LGBLOC,KBID)
      CALL ASSERT(NBLOC.EQ.1.OR.NBLOC.EQ.2)
      CALL JEVEUO(MATRES//'.REFA','E',JREFAR)
      CALL ASSERT(ZK24(JREFAR-1+9) (1:1).EQ.'M')
      SYMR = ZK24(JREFAR-1+9) .EQ. 'MS'
      IF (SYMR) THEN
        CALL ASSERT(NBLOC.EQ.1)
      ELSE
        CALL ASSERT(NBLOC.EQ.2)
      ENDIF

      CALL ASSERT(DDLEXC.EQ.' '.OR.DDLEXC.EQ.'LAGR')
      CALL WKVECT('&&MTCMBL.LISPOINT','V V I',NBCOMB,IDLIMA)
      REUTIL=.FALSE.
      DO 10 I = 1,NBCOMB
        CALL ASSERT(TYPCST(I).EQ.'R'.OR.TYPCST(I).EQ.'C')
        MATI=LIMAT(I)
        CALL JEVEUO(MATI//'.REFA','L',JREFAI)
        IF (ZK24(JREFAI-1+3).EQ.'ELIMF') CALL MTMCHC(MATI,'ELIML')
        CALL MTDSCR(MATI)
        CALL JEVEUO(MATI//'.&INT','E',ZI(IDLIMA+I-1))
        CALL JELIRA(MATI//'.VALM','TYPE',IBID,TYPMAT)
        CALL JELIRA(MATI//'.VALM','NMAXOC',NBLOC,KBID)
        CALL JEVEUO(MATI//'.REFA','L',JREFAI)
        SYMI = ZK24(JREFAI-1+9) .EQ. 'MS'
        IF (SYMI) THEN
          CALL ASSERT(NBLOC.EQ.1)
        ELSE
          CALL ASSERT(NBLOC.EQ.2)
          CALL ASSERT(.NOT.SYMR)
        ENDIF
C        IF ((.NOT.SYMI).AND.SYMR) CHGSYM=.TRUE.
        IF (MATI.EQ.MATRES) REUTIL=.TRUE.
   10 CONTINUE


C     -- SI LA MATRICE RESULTAT EST L'UNE DE CELLES A COMBINER,
C        IL NE FAUT PAS LA DETRUIRE !
C     ------------------------------------------------------------
      IF (REUTIL) THEN
        MATEMP='&&MTCMBL.MATEMP'
        CALL MTDEFS(MATEMP,MATRES,'V',TYPRES)
      ELSE
        MATEMP = MATRES
      ENDIF
      CALL JELIRA(MATEMP//'.REFA','CLAS',IBID,BAS2)


C --- VERIF. DE LA COHERENCE MPI DES MATRICES A COMBINER
C     ----------------------------------------------------
      CALL DISMOI('F','MPI_COMPLET',MAT1,'MATR_ASSE',IBID,
     &            KMPIC1,IBID)
      IF (KMPIC1.EQ.'OUI') THEN
        ZK24(JREFAR-1+11)='MPI_COMPLET'
      ELSE
        ZK24(JREFAR-1+11)='MPI_INCOMPLET'
      ENDIF
      MATD = .FALSE.
      CALL DISMOI('F','MATR_DISTR',MAT1,'MATR_ASSE',IBID,
     &            KMATD,IBID)
      IF (KMATD.EQ.'OUI') THEN
        MATD = .TRUE.
        ZK24(JREFAR-1+11)='MATR_DISTR'
      ENDIF
      DO 19 I = 2,NBCOMB
        MATI=LIMAT(I)
        CALL DISMOI('F','MPI_COMPLET',MATI,'MATR_ASSE',IBID,KMPIC,IBID)
        IF (KMPIC.NE.KMPIC1) THEN
          VALK(1)=MAT1
          VALK(2)=MATI
          CALL U2MESK('F','CALCULEL6_55',2,VALK)
        ENDIF
        CALL DISMOI('F','MATR_DISTR',MATI,'MATR_ASSE',IBID,
     &              KMATD,IBID)
C       IL EST NECESSAIRE QUE TOUTES LES MATRICES QU'ON CHERCHE A
C       COMBINER SOIT DU MEME TYPE (SOIT TOUTES DISTRIBUEES,
C       SOIT TOUTES COMPLETES MAIS SURTOUT PAS DE MELANGE !)
        IF (KMATD.EQ.'OUI') THEN
          IF ( .NOT.MATD ) CALL ASSERT(.FALSE.)
        ELSE
          IF ( MATD ) CALL ASSERT(.FALSE.)
        ENDIF
   19 CONTINUE


C --- VERIF. DE LA COHERENCE DES NUMEROTATIONS DES MATRICES A COMBINER
C     ------------------------------------------------------------------
      CALL JEVEUO(MAT1//'.REFA','L',JREFA1)
      IER1 = 0
      DO 20 I = 2,NBCOMB
        MATI=LIMAT(I)
        CALL JEVEUO(MATI//'.REFA','L',JREFAI)
        IF (ZK24(JREFA1-1+2).NE.ZK24(JREFAI-1+2)) IER1 = 1
        IF (ZK24(JREFA1-1+2).NE.ZK24(JREFAI-1+2)) IER1 = 1
        IF (ZK24(JREFA1-1+1).NE.ZK24(JREFAI-1+1)) THEN
          CALL U2MESS('F','ALGELINE2_9')
        END IF
        IF (ELIM.EQ.'ELIM=') THEN
           IF (.NOT.IDENOB(MAT1//'.CCID',MATI//'.CCID')) THEN
              VALK(1)=MAT1
              VALK(2)=MATI
              CALL U2MESK('F','ALGELINE2_10',2,VALK)
           ENDIF
        ENDIF
   20 CONTINUE



C --- 2) COMBINAISON LINEAIRE DES .VALM DES MATRICES :
C     ================================================

C ---   CAS OU LES MATRICES A COMBINER ONT LE MEME PROFIL :
C       -------------------------------------------------
      IF (IER1.EQ.0) THEN
        CALL MTDSCR(MATEMP)
        CALL JEVEUO(MATEMP//'.&INT','E',LRES)
        CALL CBVALE(NBCOMB,TYPCST,CONST,ZI(IDLIMA),TYPRES,LRES,
     &              DDLEXC,MATD)

C ---   CAS OU LES MATRICES A COMBINER N'ONT PAS LE MEME PROFIL :
C       -------------------------------------------------------
      ELSE
C       SI LES MATRICES SONT DISTRIBUEE MAIS N'ONT PAS LE MEME
C       PROFIL, ON PLANTE !
        IF ( MATD ) THEN
          CALL U2MESS('F','ALGELINE5_1')
        ENDIF
        CALL PROSMO(MATEMP,LIMAT,NBCOMB,BASE,NUMEDD,SYMR,TYPRES)
        CALL MTDSCR(MATEMP)
        CALL JEVEUO(MATEMP//'.&INT','E',LRES)
        CALL CBVAL2(NBCOMB,TYPCST,CONST,ZI(IDLIMA),TYPRES,LRES,
     &              DDLEXC)
      END IF

C
C --- DDL ELIMINES :
C     ===================
      CALL JEVEUO(MATEMP//'.REFA','L',JREFA)
      CALL JEDETR(MATEMP//'.CCID')
      CALL JEDETR(MATEMP//'.CCVA')
      CALL JEDETR(MATEMP//'.CCLL')
      CALL JEDETR(MATEMP//'.CCII')
      CALL JEDUP1(MAT1//'.CCID',BAS2,MATEMP//'.CCID')
      CALL JEEXIN(MATEMP//'.CCID',IER)
      IF (IER.GT.0) ZK24(JREFA-1+3)='ELIML'


C --- CONSTRUCTION DU DESCRIPTEUR DE LA MATRICE RESULTAT :
C     ==================================================
      CALL MTDSCR(MATEMP)
      CALL JEVEUO(MATEMP(1:19)//'.&INT','E',LRES)


C --- COMBINAISON LINEAIRE DES .CONL DES MATRICES SI NECESSAIRE :
C     =========================================================
      IF (DDLEXC.NE.'LAGR') THEN
        CALL MTCONL(NBCOMB,TYPCST,CONST,ZI(IDLIMA),TYPRES,LRES)
      ELSE
        CALL JEDETR(ZK24(ZI(LRES+1))(1:19)//'.CONL')
      END IF


C     -- ON REMET LA MATRICE DANS L'ETAT 'ASSE' :
      CALL JEVEUO(MATRES//'.REFA','E',JREFAR)
      ZK24(JREFAR-1+8)='ASSE'

      IF (REUTIL) THEN
        CALL COPISD('MATR_ASSE',BASE,MATEMP,MATRES)
        CALL DETRSD('MATR_ASSE',MATEMP)
      ENDIF

      CALL JEDETR('&&MTCMBL.LISPOINT')

      CALL JEDEMA()
      END
