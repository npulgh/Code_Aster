      SUBROUTINE OP0048()
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 11/10/2011   AUTEUR SELLENET N.SELLENET 
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
C     CALCUL MECANIQUE TRANSITOIRE PAR INTEGRATION DIRECTE
C     DIFFERENTS TYPES D'INTEGRATION SONT POSSIBLES:
C     - IMPLICITES :  THETA-WILSON
C                     NEWMARK
C     - EXPLICITE  :  DIFFERENCES CENTREES
C     ------------------------------------------------------------------
C
C  HYPOTHESES :                                                "
C  ----------   SYSTEME CONSERVATIF DE LA FORME  K.U    +    M.U = F
C           OU                                           '     "
C               SYSTEME DISSIPATIF  DE LA FORME  K.U + C.U + M.U = F
C
C     ------------------------------------------------------------------
C
      IMPLICIT NONE
C
C
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER           ZI
      COMMON / IVARJE / ZI(1)
      REAL*8            ZR
      COMMON / RVARJE / ZR(1)
      COMPLEX*16        ZC
      COMMON / CVARJE / ZC(1)
      LOGICAL           ZL
      COMMON / LVARJE / ZL(1)
      CHARACTER*8       ZK8
      CHARACTER*16              ZK16
      CHARACTER*24                       ZK24
      CHARACTER*32                                ZK32
      CHARACTER*80                                         ZK80
      COMMON / KVARJE / ZK8(1), ZK16(1), ZK24(1), ZK32(1), ZK80(1)
C     ----- FIN COMMUNS NORMALISES  JEVEUX  ----------------------------
C
      CHARACTER*6 NOMPRO
      PARAMETER ( NOMPRO = 'OP0048' )
C
      INTEGER NBPASE, NRORES, NVECA, NCHAR
      INTEGER IMAT(3), NUME, NIV, IBID, IFM, IONDP, LADPA
      INTEGER IALIFO, IAADVE, NONDP
      INTEGER NEQ, IDEPL0, IVITE0, IACCE0, IWK
      INTEGER IINTEG, NRPASE,IRET,IAINST
      INTEGER IAUX, JAUX, JORD,NBORD,JCHAR
      INTEGER LRESU,LCRRE,IRESU,NBEXRE,L
      INTEGER NBCHRE,IOCC,NFON
      REAL*8 T0,TIME,RUNDF,R8VIDE,ALPHA
      CHARACTER*1  BASE,TYPCOE
      CHARACTER*2  CODRET
      CHARACTER*8  K8B, MASSE, RIGID, AMORT, BASENO, RESULT
      CHARACTER*8 MATERI, CARAEL,KSTR,NOMFON,CHAREP
      CHARACTER*13 INPSCO
      CHARACTER*19 SOLVEU, INFCHA,LIGREL
      CHARACTER*24 MODELE, CARELE, CHARGE, FOMULT, MATE
      CHARACTER*24 NUMEDD,CHAMGD
      CHARACTER*24 INFOCH, CRITER
      CHARACTER*24 CHGEOM, CHCARA(18),CHHARM,CHTIME
      CHARACTER*24 CHVARC, CHVREF,CHSTRU,K24BLA,COMPOR
      COMPLEX*16   CALPHA(2)

      LOGICAL       LAMORT, LCREA, LPREM,EXIPOU
      INTEGER      IARG
C     -----------------------------------------------------------------
      DATA MODELE   /'                        '/
C                     123456789012345678901234
C     -----------------------------------------------------------------
C
      CALL JEMARQ()
      RUNDF=R8VIDE()
C
C====
C 1. LES DONNEES DU CALCUL
C====
C
C 1.1. ==> RECUPERATION DU NIVEAU D'IMPRESSION
C
      CALL GETVIS (' ','INFO',0,IARG,1,NIV,IBID)
      CALL INFMAJ
C
      CALL INFNIV(IFM,NIV)
C
C 1.2. ==> NOM DES STRUCTURES
C
C               12   345678   90123
      BASENO = '&&'//NOMPRO
      INPSCO = '&&'//NOMPRO//'_PSCO'
C
C               12   345678   9012345678901234
      SOLVEU = '&&'//NOMPRO//'.SOLVEUR   '
      INFCHA = '&&'//NOMPRO//'.INFCHA    '
      CHARGE = '&&'//NOMPRO//'.INFCHA    .LCHA'
      INFOCH = '&&'//NOMPRO//'.INFCHA    .INFC'
      CHVARC='&&OP0048.VARC'
      CHVREF='&&OP0048.VREF'
      ALPHA  = 0.D0
      CALPHA = (0.D0 , 0.D0)
      NFON   = 0
      TYPCOE = ' '
      CHAREP = ' '
      CHTIME = ' '
      BASE='G'

C
      LPREM  = .TRUE.
      LAMORT=.TRUE.
      AMORT = ' '
      CRITER = '&&RESGRA_GCPC'
C
C====
C 2. LES DONNEES DU CALCUL
C====
C
      CALL DLTLEC ( RESULT, MODELE, NUMEDD, MATERI,   MATE,
     &              CARAEL, CARELE,
     &              IMAT, MASSE, RIGID, AMORT, LAMORT,
     &              NCHAR, NVECA, INFCHA, CHARGE, INFOCH, FOMULT,
     &              IAADVE, IALIFO, NONDP, IONDP,
     &              SOLVEU, IINTEG, T0, NUME,
     &              NBPASE, INPSCO, BASENO )
C
      NEQ = ZI(IMAT(1)+2)
C
C====
C 3. CREATION DES VECTEURS DE TRAVAIL SUR BASE VOLATILE
C====
C
      CALL WKVECT(BASENO//'.DEPL0' ,'V V R',NEQ*(NBPASE+1),IDEPL0)
      CALL WKVECT(BASENO//'.VITE0' ,'V V R',NEQ*(NBPASE+1),IVITE0)
      CALL WKVECT(BASENO//'.ACCE0' ,'V V R',NEQ*(NBPASE+1),IACCE0)
      CALL WKVECT(BASENO//'.TRAV'  ,'V V R',NEQ,IWK)
C
      CALL GETFAC('EXCIT_RESU',NBEXRE)
      IF ( NBEXRE.NE.0 ) THEN
        CALL WKVECT(BASENO//'.COEF_RRE'    ,'V V R  ',NBEXRE,LCRRE)
        CALL WKVECT(BASENO//'.LISTRESU'    ,'V V K8 ',NBEXRE,LRESU)
        DO 252 IRESU = 1, NBEXRE
          CALL GETVID('EXCIT_RESU','RESULTAT',IRESU,IARG,1,
     &                ZK8(LRESU+IRESU-1),L)
          CALL GETVR8('EXCIT_RESU','COEF_MULT',IRESU,IARG,1,
     &                ZR(LCRRE+IRESU-1),L)
 252    CONTINUE
      ENDIF
C
C===
C 4. INITIALISATION DE L'ALGORITHME
C --- BOUCLE 40 SUR LES RESOLUTIONS
C          LE PREMIER PASSAGE, 0, EST CELUI DU CALCUL STANDARD
C          LES PASSAGES SUIVANTS SONT CEUX DES DERIVATIONS
C===
C
      DO 40 , NRORES = 0 , NBPASE
C
        NRPASE = NRORES
        IAUX = NEQ*NRPASE
C
        CALL DLTALI ( NRORES, NBPASE, INPSCO,
     &                NEQ,
     &                IMAT, MASSE, RIGID, ZI(IAADVE), ZK24(IALIFO),
     &                NCHAR, NVECA,
     &                LCREA, LPREM, LAMORT, T0,
     &                MATE,CARELE,CHARGE,INFOCH,FOMULT,
     &                MODELE, NUMEDD,NUME,
     &                SOLVEU, CRITER,
     &                ZR(IDEPL0+IAUX), ZR(IVITE0+IAUX), ZR(IACCE0+IAUX),
     &                BASENO, ZR(IWK) )
C
   40 CONTINUE
C
C====
C 5. INTEGRATION SELON LE TYPE SPECIFIE
C====
C
      IF ( IINTEG.EQ.1 ) THEN
C
        CALL DLNEWI(LCREA,LAMORT,IINTEG,NEQ,IMAT,
     &              MASSE,RIGID,AMORT,
     &              ZR(IDEPL0),ZR(IVITE0),ZR(IACCE0),T0,
     &              NCHAR,NVECA,ZI(IAADVE),ZK24(IALIFO),
     &              MODELE,MATE,CARELE,
     &              CHARGE,INFOCH,FOMULT,NUMEDD,NUME,SOLVEU,CRITER,
     &              ZK8(IONDP),NONDP,INPSCO,NBPASE)
C
      ELSEIF ( IINTEG.EQ.2 ) THEN
C
        CALL DLNEWI(LCREA,LAMORT,IINTEG,NEQ,IMAT,
     &              MASSE,RIGID,AMORT,
     &              ZR(IDEPL0),ZR(IVITE0),ZR(IACCE0),T0,
     &              NCHAR,NVECA,ZI(IAADVE),ZK24(IALIFO),
     &              MODELE,MATE,CARELE,
     &              CHARGE,INFOCH,FOMULT,NUMEDD,NUME,SOLVEU,CRITER,
     &              ZK8(IONDP),NONDP,INPSCO,NBPASE)
C
      ELSEIF ( IINTEG.EQ.3 ) THEN
C
        CALL DLDIFF(LCREA,LAMORT,NEQ,IMAT,
     &              MASSE,RIGID,AMORT,
     &              ZR(IDEPL0),ZR(IVITE0),ZR(IACCE0),T0,
     &              NCHAR,NVECA,ZI(IAADVE),ZK24(IALIFO),
     &              MODELE,MATE,CARELE,
     &              CHARGE,INFOCH,FOMULT,NUMEDD,NUME,INPSCO,NBPASE)
C
      ELSEIF ( IINTEG.EQ.4 ) THEN
C
        CALL DLADAP(T0,LCREA,LAMORT,NEQ,IMAT,
     &        MASSE,RIGID,AMORT,
     &        ZR(IDEPL0),ZR(IVITE0),ZR(IACCE0),
     &        NCHAR,NVECA,ZI(IAADVE),ZK24(IALIFO),
     &        MODELE,MATE,CARELE,
     &        CHARGE,INFOCH,FOMULT,NUMEDD,NUME,INPSCO,NBPASE)
C
      ENDIF
C
C====
C 6. RESULTATS
C====
C
      DO 60 , NRPASE = 0 , NBPASE
C
C       NOM DES STRUCTURES,  JAUX=3 => LE NOM DU RESULTAT
       JAUX = 3
       CALL PSNSLE ( INPSCO, NRPASE, JAUX, RESULT )
       CALL JEVEUO(RESULT//'           .ORDR','L',JORD)
       CALL JELIRA(RESULT//'           .ORDR','LONUTI',NBORD,K8B)
       DO 61 , IAUX = 1 , NBORD
        CALL RSADPA(RESULT,'E',1,'MODELE',ZI(JORD+IAUX-1),0,LADPA,K8B)
        ZK8(LADPA)=MODELE(1:8)
        CALL RSADPA(RESULT,'E',1,'CHAMPMAT',ZI(JORD+IAUX-1),0,LADPA,K8B)
        ZK8(LADPA)=MATERI
        CALL RSADPA(RESULT,'E',1,'CARAELEM',ZI(JORD+IAUX-1),0,LADPA,K8B)
        ZK8(LADPA)=CARAEL
   61  CONTINUE

C      ON CALCULE LE CHAMP DE STRUCTURE STRX_ELGA SI BESOIN
       CALL DISMOI('F','EXI_STRX',MODELE,'MODELE',IBID,KSTR,IRET)
       IF (KSTR(1:3).EQ.'OUI')THEN
         COMPOR = MATERI(1:8)//'.COMPOR'
         LIGREL = MODELE(1:8)//'.MODELE'
         EXIPOU=.FALSE.

         CALL DISMOI('F','EXI_POUX' ,MODELE,'MODELE',IBID,K8B,IRET)
         IF (K8B(1:3).EQ.'OUI') THEN
           EXIPOU = .TRUE.
           IF ( NCHAR.NE.0 ) THEN
             CALL JEVEUO(CHARGE,'L',JCHAR)
             CALL COCHRE (ZK24(JCHAR),NCHAR,NBCHRE,IOCC)
             IF ( NBCHRE .GT. 1 ) THEN
                CALL U2MESS('F','DYNAMIQUE_19')
             ENDIF
             IF (IOCC.GT.0) THEN
               CALL GETVID('EXCIT','CHARGE'   ,IOCC,IARG,1,CHAREP,IRET)
               CALL GETVID('EXCIT','FONC_MULT',IOCC,IARG,1,NOMFON,NFON)
             ENDIF
           ENDIF
           TYPCOE = 'R'
           ALPHA = 1.D0
         ENDIF
         DO 62 , IAUX = 0 , NBORD
           CALL RSEXCH(RESULT,'DEPL',IAUX,CHAMGD,IRET)
           IF (IRET.GT.0) GOTO 62
           CALL MECHAM('STRX_ELGA',MODELE(1:8),0,' ',CARAEL(1:8),0,
     &                            CHGEOM,CHCARA,CHHARM,IRET )
           IF (IRET.NE.0) GOTO 62
           CALL RSADPA(RESULT,'L',1,'INST',IAUX,0,LADPA,K8B)
           TIME = ZR(LADPA)
           CALL MECHTI(CHGEOM(1:8),TIME,RUNDF,RUNDF,CHTIME)
           CALL VRCINS(MODELE,MATE,CARAEL,TIME,CHVARC(1:19),CODRET)
           CALL VRCREF(MODELE(1:8),MATE(1:8),CARAEL(1:8),
     &                                        CHVREF(1:19))
           IF ( EXIPOU .AND. NFON.NE.0 ) THEN
             CALL FOINTE('F ',NOMFON,1,'INST',TIME,ALPHA,IRET)
           ENDIF
           CALL RSEXCH(RESULT,'STRX_ELGA',IAUX,CHSTRU,IRET)
           IF (IRET.EQ.0) GOTO 62
           IBID = 0
           CALL MECALC('STRX_ELGA',MODELE,CHAMGD,CHGEOM,MATE ,
     &                CHCARA,K24BLA,K24BLA,CHTIME,K24BLA,
     &                CHHARM,' ',' ',' ',' ',
     &                K24BLA,CHAREP,TYPCOE,ALPHA ,CALPHA,
     &                K24BLA,K24BLA,CHSTRU,K24BLA,LIGREL,BASE  ,
     &                CHVARC,CHVREF,K24BLA,COMPOR,K24BLA,
     &                K24BLA,K8B ,IBID  ,K24BLA,IRET )

            CALL RSNOCH(RESULT,'STRX_ELGA',IAUX,' ')

   62    CONTINUE
       ENDIF




   60 CONTINUE

C
C====
C 7. DESTRUCTION DES OBJETS DE TRAVAIL
C====
C
C
      CALL JEDEMA()
      END
