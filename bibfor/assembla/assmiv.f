      SUBROUTINE ASSMIV(BASE,VEC,NBVEC,TLIVEC,LICOEF,NU,VECPRO,MOTCLE,
     &                  TYPE)
      IMPLICIT REAL*8(A-H,O-Z)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ASSEMBLA  DATE 02/02/2010   AUTEUR SELLENET N.SELLENET 
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
C TOLE CRP_20

      CHARACTER*(*) VEC,TLIVEC(*),VECPRO,BASE
      CHARACTER*(*) NU
      CHARACTER*4 MOTCLE
      INTEGER NBVEC,TYPE
      REAL*8 LICOEF(*),RCOEF,R
C ----------------------------------------------------------------------
C    ASSEMBLAGE "PARTICULIER" POUR CONVERGENCE EN CONTRAINTES
C    GENERALISEES
C    REALISE LE MIN DES VECT_
C    GROSSIEREMENT POMPE SUR ASSVEC
C OUT K19 VEC   : NOM DU CHAM_NO RESULTAT
C                CHAM_NO ::= CHAM_NO_GD + OBJETS PROVISOIRES POUR L'ASS.
C IN  K* BASE   : NOM DE LA BASE SUR LAQUELLE ON VEUT CREER LE CHAM_NO
C IN  I  NBVEC  : NOMBRE DE VECT_ELEM A ASSEMBLER DANS VEC
C IN  K* TLIVEC : LISTE DES VECT_ELEM A ASSEMBLER
C IN  R  LICOEF : LISTE DES COEF. MULTIPLICATEURS DES VECT_ELEM
C IN  K* NU     : NOM D'UN NUMERO_DDL
C IN  K* VECPRO: NOM D'UN CHAM_NO MODELE(NU OU VECPRO EST OBLIGATOIRE)
C IN  K4 MOTCLE : 'ZERO' OU 'CUMU'
C IN  I  TYPE   : TYPE DU VECTEUR ASSEMBLE : 1 --> REEL
C                                            2 --> COMPLEXE
C
C  S'IL EXISTE UN OBJET '&&POIDS_MAILLE' VR, PONDERATIONS POUR CHAQUE
C  MAILLE, ON S'EN SERT POUR LES OPTIONS RAPH_MECA ET FULL_MECA
C
C ----------------------------------------------------------------------
C ----------------------------------------------------------------------
C     FONCTIONS JEVEUX
C ----------------------------------------------------------------------
      CHARACTER*32 JEXNUM,JEXNOM,JEXATR
C ----------------------------------------------------------------------
C     COMMUNS   JEVEUX
C ----------------------------------------------------------------------
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      CHARACTER*8 ZK8,NOMACR,EXIELE
      CHARACTER*14 NUM2
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*24 VALK(5)
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C ----------------------------------------------------------------------
C     COMMUNS   LOCAUX DE L'OPERATEUR ASSE_VECTEUR
C ----------------------------------------------------------------------
      INTEGER GD,NEC,NLILI,DIGDEL
C ---------------------------------------------------------------------
C     VARIABLES LOCALES
C ---------------------------------------------------------------------
      PARAMETER(NBECMX=10)
      INTEGER ICODLA(NBECMX),ICODGE(NBECMX),RANG,NBPROC,IRET,IFM,NIV,
     &        IBID,IMUMPS,IFCPU
      CHARACTER*1 BAS
      CHARACTER*8 MA,MO,MO2,NOGDSI,NOGDCO,NOMCAS
      CHARACTER*8 KBID,PARTIT
      CHARACTER*14 NUDEV
      CHARACTER*19 VECAS,VPROF,VECEL
      CHARACTER*24 KMAILA,K24PRN,KNULIL,KVELIL,KVEREF,KVEDSC,RESU,NOMLI,
     &             KNEQUA,KVALE,NOMOPT,K24B
      CHARACTER*1 K1BID
      INTEGER ADMODL,LCMODL,NBEC,EPDMS,JPDMS
      LOGICAL LDIST
C ----------------------------------------------------------------------
C     FONCTIONS LOCALES D'ACCES AUX DIFFERENTS CHAMPS DES
C     S.D. MANIPULEES DANS LE SOUS PROGRAMME
C ----------------------------------------------------------------------
      INTEGER VALI(4)
      REAL*8 R8MAEM,TEMPS(6)

C --- DEBUT ------------------------------------------------------------
      CALL JEMARQ()

C-----RECUPERATION DU NIVEAU D'IMPRESSION

      CALL INFNIV(IFM,NIV)
C     IFM = IUNIFI('MESSAGE')
C----------------------------------------------------------------------

C --- VERIF DE MOTCLE:
      IF (MOTCLE(1:4).EQ.'ZERO') THEN

      ELSEIF (MOTCLE(1:4).EQ.'CUMU') THEN

      ELSE
        CALL U2MESK('F','ASSEMBLA_8',1,MOTCLE)
      ENDIF
C
      CALL JEVEUO(JEXATR('&CATA.TE.MODELOC','LONCUM'),'L',LCMODL)
      CALL JEVEUO(JEXNUM('&CATA.TE.MODELOC',1),'L',ADMODL)

      VECAS=VEC
      BAS=BASE

C ------------------------------------------------------------------
C     -- SI LES CALCULS ONT ETE "DISTRIBUES" :
C        CALCUL DE :
C           * LDIST : .TRUE. : LES CALCULS ONT ETE DISTRIBUES
C           * JNUMSD : ADRESSE DE PARTIT//'.NUPROC.MAILLE'
C
C     -- IL EXISTE TROIS FORMES DE CALCUL DISTRIBUE BASES SUR UNE PARTI
C        TION:
C        * FETI: LE FLAG A ACTIVER EST LE LOGICAL LFETI 
C              (PAS CONCERNE ICI, HORS PERIMETRE FETI)
C        * DISTRIBUE (AVEC OU SANS MUMPS) EN STD: FLAG LDIST
C        * DISTRIBUE AVEC MUMPS + OPTION MATR_DISTIBUEE: LDIST (PAS CON
C            CERNE ICI, ON NE RETAILLE QUE LES MATRICES)
C
C        AU SENS ASSMIV, LES DEUX DERNIERS CAS DE FIGURES SONT IDENTI
C        QUES. POUR PLUS D'INFO CF. COMMENTAIRES DS ASSMAM.
C
C         EN BREF ON A 4 CAS DE FIGURES DE CALCUL ASTER ET ILS SE DECLI
C         NENT COMME SUIT VIS-A-VIS DES VARIABLES DE ASSVEC:
C        1/ CALCUL STD SEQ PAS FETI: 
C            LFETI='F',LDIST='F' 
C        2/ CALCUL FETI SEQ OU PARALLELE (MATRICES MERE ET FILLES)
C            LFETI='T',LDIST='F'  (PAS CONCERNE ICI)
C        3/ CALCUL PARALLELE (AVEC OU SANS MUMPS) DISTRIBUE STD:
C            LFETI='F',LDIST='T'
C        4/ CAS PARTICULIER DU PRECEDENT: SOLVEUR=MUMPS + OPTION MATR
C          DISTRIBUEE ACTIVEE      (PAS CONCERNE ICI)
C            LFETI='F',LDIST='T'
C         
C ------------------------------------------------------------------
      LDIST=.FALSE.
      RANG=0
      NBPROC=1
      PARTIT=' '
      CALL PARTI0(NBVEC,TLIVEC,PARTIT)
      IF (PARTIT.NE.' ') THEN
        LDIST=.TRUE.
        CALL MUMMPI(2,IFM,NIV,K24B,RANG,IBID)
        CALL MUMMPI(3,IFM,NIV,K24B,NBPROC,IBID)
        CALL JEVEUO(PARTIT//'.NUPROC.MAILLE','L',JNUMSD)
      ENDIF


C --- SI LE CONCEPT VECAS EXISTE DEJA,ON LE DETRUIT:
      CALL DETRSD('CHAMP_GD',VECAS)
      CALL WKVECT(VECAS//'.LIVE',BAS//' V K24 ',NBVEC,ILIVEC)
      DO 10 I=1,NBVEC
        ZK24(ILIVEC-1+I)=TLIVEC(I)
   10 CONTINUE

C --- NOMS DES PRINCIPAUX OBJETS JEVEUX LIES A VECAS
      KMAILA='&MAILLA                 '
      KVELIL=VECAS//'.LILI'
      KVEREF=VECAS//'.REFE'
      KVALE=VECAS//'.VALE'
      KVEDSC=VECAS//'.DESC'

C --- CREATION DE REFE ET DESC
      CALL JECREO(KVEREF,BAS//' V K24')
      CALL JEECRA(KVEREF,'LONMAX',2,' ')
      CALL JEVEUO(KVEREF,'E',IDVERF)
      CALL JECREO(KVEDSC,BAS//' V I')
      CALL JEECRA(KVEDSC,'LONMAX',2,' ')
      CALL JEECRA(KVEDSC,'DOCU',IBID,'CHNO')
      CALL JEVEUO(KVEDSC,'E',IDVEDS)

C --- CALCUL D UN LILI POUR VECAS
C --- CREATION D'UN VECAS(1:19).ADNE ET VECAS(1:19).ADLI SUR 'V'
      CALL CRELIL('F',NBVEC,ILIVEC,KVELIL,'V',KMAILA,VECAS,GD,MA,NEC,
     &            NCMP,ILIM,NLILI,NBELM)

      CALL JEVEUO(VECAS(1:19)//'.ADLI','E',IADLIE)
      CALL JEVEUO(VECAS(1:19)//'.ADNE','E',IADNEM)
      CALL JEEXIN(MA(1:8)//'.CONNEX',IRET)
      IF (IRET.GT.0) THEN
        CALL JEVEUO(MA(1:8)//'.CONNEX','L',ICONX1)
        CALL JEVEUO(JEXATR(MA(1:8)//'.CONNEX','LONCUM'),'L',ICONX2)
      ENDIF

C --- ON SUPPOSE QUE LE LE LIGREL DE &MAILLA EST LE PREMIER DE LILINU
      ILIMNU=1

C --- NOMS DES PRINCIPAUX OBJETS JEVEUX LIES A NU
C --- IL FAUT ESPERER QUE LE CHAM_NO EST EN INDIRECTION AVEC UN
C     PROF_CHNO APPARTENANT A UNE NUMEROTATION SINON CA VA PLANTER
C     DANS LE JEVEUO SUR KNEQUA
      NUDEV=NU
      IF (NUDEV(1:1).EQ.' ') THEN
        VPROF=VECPRO
        CALL JEVEUO(VPROF//'.REFE','L',IDVREF)
        NUDEV=ZK24(IDVREF-1+2)(1:14)
      ENDIF

      KNEQUA=NUDEV//'.NUME.NEQU'
      K24PRN=NUDEV//'.NUME.PRNO'
      KNULIL=NUDEV//'.NUME.LILI'
      CALL JEVEUO(NUDEV//'.NUME.NUEQ','L',IANUEQ)

      CALL DISMOI('F','NOM_MODELE',NUDEV,'NUME_DDL',IBID,MO,IERD)
      CALL DISMOI('F','NOM_MAILLA',NUDEV,'NUME_DDL',IBID,MA,IERD)
      CALL DISMOI('F','NB_NO_SS_MAX',MA,'MAILLAGE',NBNOSS,KBID,IERD)

C     100 EST SUPPOSE ETRE LA + GDE DIMENSION D'UNE MAILLE STANDARD:
      NBNOSS=MAX(NBNOSS,100)
C     -- NUMLOC(K,INO) (K=1,3)(INO=1,NBNO(MAILLE))
      CALL WKVECT('&&ASSMIV.NUMLOC','V V I',3*NBNOSS,IANULO)

      CALL DISMOI('F','NOM_GD',NUDEV,'NUME_DDL',IBID,NOGDCO,IERD)
      CALL DISMOI('F','NOM_GD_SI',NOGDCO,'GRANDEUR',IBID,NOGDSI,IERD)
      CALL DISMOI('F','NB_CMP_MAX',NOGDSI,'GRANDEUR',NMXCMP,KBID,IERD)
      CALL DISMOI('F','NUM_GD_SI',NOGDSI,'GRANDEUR',NUGD,KBID,IERD)
      NEC=NBEC(NUGD)
      NCMP=NMXCMP


C     -- POSDDL(ICMP) (ICMP=1,NMXCMP(GD_SI))
      CALL WKVECT('&&ASSMIV.POSDDL','V V I',NMXCMP,IAPSDL)

      CALL DISMOI('F','NB_NO_MAILLA',MO,'MODELE',NM,KBID,IER)


C ---  RECUPERATION DE PRNO
      CALL JEVEUO(K24PRN,'L',IDPRN1)
      CALL JEVEUO(JEXATR(K24PRN,'LONCUM'),'L',IDPRN2)

C ---  RECUPERATION DE NEQUA
      CALL JEVEUO(KNEQUA,'L',IDNEQU)
      NEQUA=ZI(IDNEQU)

C ---  REMPLISSAGE DE REFE ET DESC
      ZK24(IDVERF)=MA
      ZK24(IDVERF+1)=K24PRN(1:14)//'.NUME'
      ZI(IDVEDS)=GD
      ZI(IDVEDS+1)=1


C --- ALLOCATION VALE
      CALL ASSERT(TYPE.EQ.1)
      CALL WKVECT(KVALE,BAS//' V R8',NEQUA,JVALE)

      DO 20 I=1,NEQUA
        ZR(JVALE+I-1)=R8MAEM()
   20 CONTINUE


C     -- REMPLISSAGE DE .VALE
C     ------------------------
      DO 90 IMAT=1,NBVEC
        RCOEF=LICOEF(IMAT)
        VECEL=ZK24(ILIVEC+IMAT-1)(1:19)

        CALL DISMOI('F','NOM_MODELE',VECEL,'VECT_ELEM',IBID,MO2,IERD)
        IF (MO2.NE.MO) CALL U2MESS('F','ASSEMBLA_5')

        CALL JEEXIN(VECEL//'.RELR',IRET)
        IF (IRET.EQ.0) GOTO 90

          CALL JEVEUO(VECEL//'.RELR','L',IDLRES)
          CALL JELIRA(VECEL//'.RELR','LONUTI ',NBRESU,K1BID)
          DO 80 IRESU=1,NBRESU
            RESU=ZK24(IDLRES+IRESU-1)
            CALL JEVEUO(RESU(1:19)//'.NOLI','L',IAD)
            NOMLI=ZK24(IAD)
            NOMOPT=ZK24(IAD+1)

            IF (NOMOPT(1:9).EQ.'FULL_MECA' .OR.
     &          NOMOPT(1:9).EQ.'RAPH_MECA') THEN
              CALL JEEXIN('&&POIDS_MAILLE',EPDMS)
              IF (EPDMS.GT.0) CALL JEVEUO('&&POIDS_MAILLE','L',JPDMS)
            ELSE
              EPDMS=0
            ENDIF

            CALL JENONU(JEXNOM(KVELIL,NOMLI),ILIVE)
            CALL JENONU(JEXNOM(KNULIL,NOMLI),ILINU)
            DO 70 IGR=1,ZI(IADLIE+3*(ILIVE-1))
              CALL JEVEUO(RESU(1:19)//'.DESC','L',IDDESC)
              MODE=ZI(IDDESC+IGR+1)
              IF (MODE.GT.0) THEN
                NNOE=NBNO(MODE)
                NEL=ZI(ZI(IADLIE+3*(ILIVE-1)+2)+IGR)-
     &              ZI(ZI(IADLIE+3*(ILIVE-1)+2)+IGR-1)-1
                CALL JEVEUO(JEXNUM(RESU(1:19)//'.RESL',IGR),'L',IDRESL)
                NCMPEL=DIGDEL(MODE)

                DO 60 IEL=1,NEL
                  NUMA=ZI(ZI(IADLIE+3*(ILIVE-1)+1)-1+
     &                 ZI(ZI(IADLIE+3*(ILIVE-1)+2)+IGR-1)+IEL-1)
                  R=RCOEF

                  IF (LDIST) THEN
                    IF (NUMA.GT.0) THEN
                      IF (ZI(JNUMSD-1+NUMA).NE.RANG) GOTO 60
                    ENDIF
                  ENDIF

                  IF (NUMA.GT.0) THEN
                    IF (EPDMS.GT.0)R=R*ZR(JPDMS-1+NUMA)
                    IL=0
                    DO 50 K1=1,NNOE
                      N1=ZI(ICONX1-1+ZI(ICONX2+NUMA-1)+K1-1)
                      IAD1=ZI(IDPRN1-1+ZI(IDPRN2+ILIMNU-1)+
     &                     (N1-1)*(NEC+2)+1-1)
                      CALL CORDDL(ADMODL,LCMODL,IDPRN1,IDPRN2,ILIMNU,
     &                            MODE,NEC,NCMP,N1,K1,NDDL1,ZI(IAPSDL))
                      IF (NDDL1.EQ.0)GOTO 50
                      IF (IAD1.EQ.0) THEN
                        VALI(1)=N1
                        VALK(1)=RESU
                        VALK(2)=VECEL
                        VALK(3)=NUDEV
                        CALL U2MESG('F','ASSEMBLA_41',3,VALK,1,VALI,0,
     &                              0.D0)
                      ENDIF

                      IF (IAD1.GT.NEQUA) THEN
                        VALI(1)=N1
                        VALI(2)=IAD1
                        VALI(3)=NEQUA
                        VALK(1)=RESU
                        VALK(2)=VECEL
                        CALL U2MESG('F','ASSEMBLA_42',2,VALK,3,VALI,0,
     &                              0.D0)
                      ENDIF

                      IF (NDDL1.GT.100) THEN
                        VALI(1)=NDDL1
                        VALI(2)=100
                        CALL U2MESG('F','ASSEMBLA_43',0,' ',2,VALI,0,
     &                              0.D0)
                      ENDIF

                      IF (TYPE.EQ.1) THEN
                        DO 30 I1=1,NDDL1
                          IL=IL+1
                          ZR(JVALE-1+ZI(IANUEQ-1+IAD1+ZI(IAPSDL-1+I1)-
     &                      1))=MIN(ZR(JVALE-1+ZI(IANUEQ-1+IAD1+
     &                          ZI(IAPSDL-1+I1)-1)),
     &                          ZR(IDRESL+(IEL-1)*NCMPEL+IL-1)*R)
   30                   CONTINUE
                      ENDIF
   50               CONTINUE
                  ENDIF
   60           CONTINUE
                CALL JELIBE(JEXNUM(RESU(1:19)//'.RESL',IGR))
              ENDIF
   70       CONTINUE
   80     CONTINUE

   90 CONTINUE
      CALL JEDETR(VECAS//'.LILI')
      CALL JEDETR(VECAS//'.LIVE')
      CALL JEDETR(VECAS//'.ADNE')
      CALL JEDETR(VECAS//'.ADLI')
      CALL JEDETR('&&ASSMIV.POSDDL')
      CALL JEDETR('&&ASSMIV.NUMLOC')

C        -- REDUCTION + DIFFUSION DE VECAS A TOUS LES PROC
      IF (LDIST) CALL MPICM1('MPI_MIN','R',NEQUA,IBID,ZR(JVALE))


      CALL JEDEMA()
      END
