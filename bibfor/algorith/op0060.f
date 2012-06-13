      SUBROUTINE OP0060()
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
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
C
      IMPLICIT NONE
C
C ----------------------------------------------------------------------
C
C  COMMANDE DYNA_LINE_HARM
C
C  CALCUL DYNAMIQUE HARMONIQUE POUR UN SYSTEME CONSERVATIF
C  OU DISSIPATIF Y COMPRIS LES SYSTEMES COUPLES FLUIDE-STRUCTURE
C
C
C
C
C
      INCLUDE 'jeveux.h'
      INTEGER      IBID,NBOLD
      REAL*8       R8BID
      COMPLEX*16   C16BID
      CHARACTER*8  K8BID
      CHARACTER*19 K19BID
      CHARACTER*8  BASENO,RESUCO,RESULT
      CHARACTER*19 CN2MBR,VEDIRI,VENEUM,VEVOCH,VASSEC
      CHARACTER*19 LISCHA
      INTEGER      NBSYM,I,N1,N2
      INTEGER      LAMOR1, LAMOR, LIMPE, LFREQ, NBFREQ
      INTEGER      NEQ, NBMAT
      INTEGER      IE,JREFA, ETAUSR
      INTEGER      IFREQ, IEQ, INOM, IER
      INTEGER      LREFE, LSECMB,JSECMB,JSOLUT,JVEZER
      INTEGER      ICOEF, ICODE
      INTEGER      LVALE, LINST, IRET, LADPA,JORD
      INTEGER      LMAT(4),NBORD,ICOMB
      INTEGER      JPOMR,JREFE
      LOGICAL      NEWCAL
      REAL*8       DEPI,OMEGA2,FREQ,OMEGA,R8DEPI
      REAL*8       RVAL,COEF(6),TPS1(4),RTAB(2)
      COMPLEX*16   CVAL,CZERO
      CHARACTER*1  TYPRES,TYPCST(4)
      CHARACTER*8  NOMSYM(3),NOMO
      CHARACTER*24 CARELE,MATE
      CHARACTER*14 NUMDDL,NUMDL1,NUMDL2,NUMDL3
      CHARACTER*16 TYPCON,NOMCMD,TYSD
      CHARACTER*19 LIFREQ,MASSE,RAIDE,AMOR,DYNAM,IMPE,CHAMNO
      CHARACTER*19 SOLVEU,MAPREC,SECMBR,SOLUTI,VEZERO,CRGC
      CHARACTER*19 NOMT,NOMI
      CHARACTER*24 NOMAT(4)
      CHARACTER*24 EXRECO,EXRESU
      INTEGER      NBEXRE
      INTEGER      IARG
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFMAJ()
      CALL TITRE()
C
C --- INITIALISATIONS DIVERSES
C
      DEPI   = R8DEPI()
      TYPRES = 'C'
      LAMOR1 = 0
      CZERO  = DCMPLX(0.D0,0.D0)
C
C --- NOM DES STRUCTURES
C
      BASENO = '&&OP0060'
      MAPREC = '&&OP0060.MAPREC'
      SOLUTI = '&&OP0060.SOLUTI'
      VEZERO = '&&OP0060.VEZERO'
      LISCHA = '&&OP0060.LISCHA'
      VEDIRI = '&&VEDIRI'
      VENEUM = '&&VENEUM'
      VEVOCH = '&&VEVOCH'
      VASSEC = '&&VASSEC'
      CRGC   = '&&OP0060_GCPC'
C
C --- NOM UTILISATEUR DU CONCEPT RESULTAT CREE PAR LA COMMANDE
C
      CALL GETRES(RESULT,TYPCON,NOMCMD)
C
C --- ON VERIFIE SI LE CONCEPT EST REENTRANT
C
      NEWCAL = .TRUE.
      CALL GCUCON(RESULT,TYPCON,IRET)
      IF (IRET.GT.0) THEN
        CALL GETVID(' ','RESULTAT',1,IARG,1,RESUCO,IBID)
        IF (IBID.EQ.0) THEN
          NEWCAL = .TRUE.
        ELSE
          CALL GETTCO(RESUCO,TYSD)
          IF (TYSD.EQ.TYPCON) THEN
            NEWCAL = .FALSE.
            IF (RESULT.NE.RESUCO) THEN
              CALL U2MESS('F','ALGORITH9_28')
            ENDIF
          ELSE
            CALL U2MESS('F','ALGORITH9_29')
          ENDIF
        ENDIF
      ENDIF
C
C --- LISTE DES FREQUENCES POUR LE CALCUL
C
      CALL GETVID(' ','LIST_FREQ',0,IARG,1,LIFREQ,N1)
      IF ( N1 .GT. 0 ) THEN
        CALL JEVEUO(LIFREQ//'.VALE','L',LFREQ)
        CALL JELIRA(LIFREQ//'.VALE','LONMAX',NBFREQ,K8BID)
      ELSE
        CALL GETVR8(' ','FREQ',0,IARG,0,R8BID,NBFREQ)
        NBFREQ = - NBFREQ
        CALL WKVECT(BASENO//'.LISTE.FREQ','V V R',NBFREQ,LFREQ)
        CALL GETVR8(' ','FREQ',0,IARG,NBFREQ,ZR(LFREQ),NBFREQ)
      ENDIF
C
C --- NOM DES CHAMPS CALCULES
C
      CALL GETVTX(' ','NOM_CHAM',1,IARG,3,NOMSYM,NBSYM)
      CALL ASSERT(NBSYM.LE.3)
      IF (TYPCON.EQ.'ACOU_HARMO') THEN
        NBSYM     = 1
        NOMSYM(1) = 'PRES'
      ELSE
        CALL GETVTX(' ','NOM_CHAM',1,IARG,3,NOMSYM,NBSYM)
        IF (NBSYM .EQ. 0) THEN
          NBSYM     = 3
          NOMSYM(1) = 'DEPL'
          NOMSYM(2) = 'VITE'
          NOMSYM(3) = 'ACCE'
        ENDIF
      ENDIF
C
C --- RECUPERATION DES DESCRIPTEURS DES MATRICES ET DES MATRICES
C
      RAIDE  = ' '
      MASSE  = ' '
      AMOR   = ' '
      CALL DYLEMA(BASENO,NBMAT ,NOMAT ,RAIDE ,MASSE ,
     &            AMOR  ,IMPE  )
      CALL ASSERT(NBMAT.LE.4)
      CALL GETVID(' '         ,'MATR_AMOR'    ,0,IARG,1,K19BID,LAMOR)
      CALL GETVID(' '         ,'MATR_IMPE_PHI',0,IARG,1,K19BID,LIMPE)
      CALL GETVR8('AMOR_MODAL','AMOR_REDUIT'  ,1,IARG,0,R8BID ,N1)
      CALL GETVID('AMOR_MODAL','LIST_AMOR'    ,1,IARG,0,K8BID ,N2)
      IF (N1.NE.0.OR.N2.NE.0) LAMOR1 = 1
C
C --- TEST: LES MATRICES SONT TOUTES BASEES SUR LA MEME NUMEROTATION ?
C
      NUMDL1 = ' '
      NUMDL2 = ' '
      NUMDL3 = ' '
      CALL DISMOI('F','NOM_NUME_DDL',RAIDE,'MATR_ASSE',IBID,
     &            NUMDL1,IE)
      CALL DISMOI('F','NOM_NUME_DDL',MASSE,'MATR_ASSE',IBID,
     &            NUMDL2,IE)
      IF (LAMOR.NE.0) THEN
        CALL DISMOI('F','NOM_NUME_DDL',AMOR,'MATR_ASSE',IBID,
     &              NUMDL3,IE)
      ELSE
        NUMDL3 = NUMDL2
      ENDIF
C
      IF ((NUMDL1.NE.NUMDL2).OR.
     &    (NUMDL1.NE.NUMDL3).OR.
     &    (NUMDL2.NE.NUMDL3)) THEN
        CALL U2MESS('F','ALGORITH9_34')
      ELSE
        NUMDDL = NUMDL2
      ENDIF
C
C --- LECTURE INFORMATIONS MECANIQUES
C
      CALL DYDOME(NOMO  ,MATE  ,CARELE)
C
C --- LECTURE DU CHARGEMENT
C
      CALL DYLECH(NOMO  ,LISCHA,NBEXRE,EXRECO,EXRESU)
C
C --- CALCUL ET PRE-ASSEMBLAGE DU CHARGEMENT
C
      CALL DYLACH(NOMO  ,MATE  ,CARELE,LISCHA,NUMDDL,
     &            VEDIRI,VENEUM,VEVOCH,VASSEC)
C
C============================================
C 3. ==> ALLOCATION DES RESULTATS
C============================================
C
      IF (NEWCAL) CALL UTCRRE(RESULT,NBFREQ)
C
C --- RENSEIGNEMENT DU .REFD
C
      IF (NEWCAL) THEN
        CALL WKVECT(RESULT//'           .REFD','G V K24',7,LREFE)
        NBOLD=0
      ELSE
        CALL JEVEUO(RESULT//'           .REFD','E',LREFE)
        CALL RSORAC(RESULT,'LONUTI',IBID,R8BID,K8BID,C16BID,R8BID,
     &             'ABSOLU',NBOLD,1,IBID)
        CALL RSAGSD(RESULT,NBFREQ+NBOLD)
      ENDIF
      ZK24(LREFE  ) = RAIDE
      ZK24(LREFE+1) = MASSE
      ZK24(LREFE+2) = AMOR
      ZK24(LREFE+3) = NUMDDL
      ZK24(LREFE+4) = ' '
      ZK24(LREFE+5) = ' '
      ZK24(LREFE+6) = ' '
      CALL JELIBE(RESULT//'           .REFD')
C

C============================================
C 4. ==> CALCUL DES TERMES DEPENDANT DE LA FREQUENCE ET RESOLUTION
C         DU SYSTEME FREQUENCE PAR FREQUENCE
C============================================

C====
C 4.1. ==> PREPARATION DU CALCUL ---
C====

      DO 41 I=1, NBMAT
        CALL JEVEUO(NOMAT(I),'L',LMAT(I))
 41   CONTINUE
      NEQ = ZI(LMAT(1)+2)
      TYPCST(1) = 'R'
      TYPCST(2) = 'R'
      TYPCST(3) = 'C'
      TYPCST(4) = 'C'
      COEF(1)   = 1.D0
C
C     CREATION DE LA MATRICE DYNAMIQUE
      DYNAM = BASENO//'.DYNAMIC_MX'

      JPOMR=0
      DO 15 ICOMB = 1,NBMAT
C        ON RECHERCHE UNE EVENTUELLE MATRICE NON SYMETRIQUE
         NOMI =NOMAT(ICOMB)(1:19)
         CALL JEVEUO(NOMI//'.REFA','L',JREFE)
         IF ( ZK24(JREFE-1+9).EQ.'MR' ) THEN
            JPOMR=ICOMB
         ENDIF
   15 CONTINUE
      IF (JPOMR.EQ.0) THEN
         IF (LAMOR.NE.0) THEN
            CALL MTDEFS(DYNAM,AMOR,'V',TYPRES)
         ELSE
            CALL MTDEFS(DYNAM,RAIDE,'V',TYPRES)
         ENDIF
      ELSE
         NOMT = NOMAT(JPOMR)(1:19)
         CALL MTDEFS(DYNAM,NOMT,'V',TYPRES)
      ENDIF
      CALL MTDSCR(DYNAM)
C
C --- CREATION DU VECTEUR SECOND-MEMBRE
C
      CN2MBR = '&&OP0060.SECOND.MBR'
      CALL WKVECT(CN2MBR,'V V C',NEQ,LSECMB)
C
C --- CREATION SD TEMPORAIRES
C
      SECMBR = '&&OP0060.SECMBR'
      CALL VTCREM(SECMBR,DYNAM,'V',TYPRES)
      CALL COPISD('CHAMP_GD','V',SECMBR,VEZERO)
      CALL JEVEUO(SECMBR(1:19)//'.VALE','E',JSECMB)
      CALL JEVEUO(VEZERO(1:19)//'.VALE','E',JVEZER)
      CALL ZINIT(NEQ,CZERO,ZC(JVEZER),1)
C
C --- INFORMATIONS SOLVEUR
C
      SOLVEU = '&&OP0060.SOLVEUR'
      CALL CRESOL(SOLVEU)

C====
C 4.2 ==> BOUCLE SUR LES FREQUENCES ---
C====
      CALL UTTCPU('CPU.OP0060', 'INIT',' ')

      DO 42 IFREQ = 1,NBFREQ
        CALL UTTCPU('CPU.OP0060', 'DEBUT',' ')
C
C ----- CALCUL DES COEFF. POUR LES MATRICES
C
        FREQ    = ZR(LFREQ-1+IFREQ)
        OMEGA   = DEPI*FREQ
        COEF(2) = - OMEGA2(FREQ)
        ICOEF   = 2
        IF ((LAMOR.NE.0).OR.(LAMOR1.NE.0)) THEN
          COEF(3) = 0.D0
          COEF(4) = OMEGA
          ICOEF   = 4
        ENDIF
        IF (LIMPE.NE.0) THEN
          COEF(ICOEF+1) = 0.D0
          COEF(ICOEF+2) = COEF(2) * DEPI * FREQ
        ENDIF
C
C ----- CALCUL DU SECOND MEMBRE
C
        CALL DY2MBR(NUMDDL,NEQ   ,LISCHA,FREQ ,VEDIRI,
     &              VENEUM,VEVOCH,VASSEC,LSECMB)
C
C ----- APPLICATION EVENTUELLE EXCIT_RESU
C
        IF (NBEXRE.NE.0) THEN
          CALL DYEXRE(NUMDDL,FREQ  ,NBEXRE,EXRECO,EXRESU,
     &                LSECMB)
        ENDIF
C
C ----- CALCUL DE LA MATRICE DYNAMIQUE
C
        CALL MTCMBL(NBMAT ,TYPCST,COEF  ,NOMAT ,DYNAM ,
     &              ' '   ,' '   ,'ELIM=')
        CALL JEVEUO(DYNAM(1:19)//'.REFA','E',JREFA)
        ZK24(JREFA-1+8) = ' '
C
C ----- FACTORISATION DE LA MATRICE DYNAMIQUE
C
        CALL PRERES(SOLVEU,'V',ICODE,MAPREC,DYNAM,IBID,-9999)
        IF ((ICODE.EQ.1).OR.(ICODE.EQ.2)) THEN
          CALL U2MESR('I', 'DYNAMIQUE_14', 1, FREQ)
        ENDIF
C
C ----- RESOLUTION DU SYSTEME, CELUI DU CHARGEMENT STANDARD
C
        CALL ZCOPY(NEQ,ZC(LSECMB),1,ZC(JSECMB),1)
        CALL RESOUD(DYNAM ,MAPREC,SECMBR,SOLVEU,VEZERO,
     &              'V'   ,SOLUTI,CRGC  ,0     ,R8BID ,
     &              C16BID,.TRUE.)
        CALL JEVEUO(SOLUTI(1:19)//'.VALE','L',JSOLUT)
        CALL ZCOPY(NEQ,ZC(JSOLUT),1,ZC(LSECMB),1)
        CALL JEDETR(SOLUTI)
C
C --- ARCHIVAGE ---
C        CREATION D'UN CHAMNO DANS L'OBJET RESULTAT
C
        DO 130 INOM = 1, NBSYM
          CALL RSEXCH(RESULT,NOMSYM(INOM),IFREQ+NBOLD,CHAMNO,IER)
          IF ( IER .EQ. 0 ) THEN
            CALL U2MESK('A','ALGORITH2_64',1,CHAMNO)
          ELSEIF ( IER .EQ. 100 ) THEN
            CALL VTCREM(CHAMNO,MASSE,'G',TYPRES)
C              -- VTCREM CREE TOUJOURS DES CHAM_NO. PARFOIS IL FAUT LES
C                 DECLARER CHAM_GENE :
            IF (TYPCON.EQ.'HARM_GENE') THEN
              CALL JEECRA(CHAMNO//'.DESC','DOCU',0,'VGEN')
C GLUTE CAR ON A UTILISE VTCRE[ABM] POUR UN CHAM_GENE QUI A UN .REFE
C DE TAILLE 2 ET NON 4 COMME UN CHAM_NO
              CALL JUVECA(CHAMNO//'.REFE',2)
            ENDIF
          ELSE
            CALL U2MESS('F','ALGORITH2_65')
          ENDIF
          CALL JEVEUO(CHAMNO//'.VALE','E',LVALE)
C
C ------- RECOPIE DANS L'OBJET RESULTAT
C
          IF ((NOMSYM(INOM) .EQ. 'DEPL' ).OR.
     &       ( NOMSYM(INOM) .EQ. 'PRES' ))THEN
            DO 131 IEQ = 0, NEQ-1
              ZC(LVALE+IEQ) = ZC(LSECMB+IEQ)
  131       CONTINUE
          ELSEIF ( NOMSYM(INOM) .EQ. 'VITE' ) THEN
            CVAL = DCMPLX(0.D0,DEPI*FREQ)
            DO 132 IEQ = 0, NEQ-1
              ZC(LVALE+IEQ) = CVAL * ZC(LSECMB+IEQ)
  132       CONTINUE
          ELSEIF ( NOMSYM(INOM) .EQ. 'ACCE' ) THEN
            RVAL = COEF(2)
            DO 133 IEQ = 0, NEQ-1
              ZC(LVALE+IEQ) = RVAL * ZC(LSECMB+IEQ)
  133       CONTINUE
          ENDIF
          CALL RSNOCH(RESULT,NOMSYM(INOM),IFREQ+NBOLD,' ')
          CALL JELIBE(CHAMNO//'.VALE')
  130   CONTINUE
C
C ------- RECOPIE DE LA FREQUENCE DE STOCKAGE
C
          CALL RSADPA(RESULT,'E',1,'FREQ',IFREQ+NBOLD,0,LINST,K8BID)
          ZR(LINST) = FREQ
C
C ----- VERIFICATION SI INTERRUPTION DEMANDEE PAR SIGNAL USR1
C
        IF ( ETAUSR().EQ.1 ) THEN
          CALL SIGUSR()
        ENDIF
C
C ----- MESURE CPU
C
        CALL UTTCPU('CPU.OP0060', 'FIN',' ')
        CALL UTTCPR('CPU.OP0060', 4, TPS1)
        IF ( TPS1(4) .GT. .90D0*TPS1(1)  .AND. I .NE. NBFREQ ) THEN
          RTAB(1) = TPS1(4)
          RTAB(2) = TPS1(1)
          CALL UTEXCM(28,'DYNAMIQUE_13',0,K8BID,1,IFREQ,2,RTAB)
        ENDIF
 42   CONTINUE
C
C --- STOCKAGE : MODELE,CARA_ELEM,CHAM_MATER
C
      IF (TYPCON(1:9).NE.'HARM_GENE')THEN
        CALL DISMOI('F','NOM_MODELE',RAIDE,'MATR_ASSE',IBID,NOMO  ,IRET)
        CALL DISMOI('F','CHAM_MATER',RAIDE,'MATR_ASSE',IBID,MATE  ,IRET)
        CALL DISMOI('F','CARA_ELEM' ,RAIDE,'MATR_ASSE',IBID,CARELE,IRET)
        CALL JEVEUO(RESULT//'           .ORDR','L',JORD)
        CALL JELIRA(RESULT//'           .ORDR','LONUTI',NBORD,K8BID)
        DO 43 I=1,NBORD
          CALL RSADPA(RESULT,'E'   ,1,'MODELE'  ,ZI(JORD+I-1),
     &                0     ,LADPA ,K8BID)
          ZK8(LADPA) = NOMO
          CALL RSADPA(RESULT,'E'   ,1,'CHAMPMAT',ZI(JORD+I-1),
     &                0     ,LADPA ,K8BID)
          ZK8(LADPA) = MATE(1:8)
          CALL RSADPA(RESULT,'E',1,'CARAELEM',ZI(JORD+I-1),
     &                0     ,LADPA ,K8BID)
          ZK8(LADPA) = CARELE(1:8)
 43     CONTINUE
      ENDIF
C
      CALL JEDEMA()
      END
