      SUBROUTINE DLNEWI ( RESULT,FORCE0,FORCE1,
     &                    LCREA,LAMORT,IINTEG,NEQ,IMAT,
     &                    MASSE,RIGID,AMORT,
     &                    DEP0,VIT0,ACC0,FEXTE,FAMOR,FLIAI,T0,
     &                    NCHAR,NVECA,LIAD,LIFO,MODELE,
     &                    MATE,CARELE,CHARGE,INFOCH,FOMULT,NUMEDD,NUME,
     &                    SOLVEU, CRITER,CHONDP,NONDP)
C     ------------------------------------------------------------------
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
C TOLE CRP_21
C TOLE CRP_20
C     ------------------------------------------------------------------
C     CALCUL MECANIQUE TRANSITOIRE PAR INTEGRATION DIRECTE
C     AVEC METHODES IMPLICITES :                  - THETA-WILSON
C                                                 - NEWMARK

C     ------------------------------------------------------------------

C  HYPOTHESES :                                                "
C  ----------   SYSTEME CONSERVATIF DE LA FORME  K.U    +    M.U = F
C           OU                                           '     "
C               SYSTEME DISSIPATIF  DE LA FORME  K.U + C.U + M.U = F

C     ------------------------------------------------------------------
C  IN  : LCREA     : LOGIQUE INDIQUANT SI IL Y A REPRISE
C  IN  : LAMORT    : LOGIQUE INDIQUANT SI IL Y A AMORTISSEMENT
C  IN  : IINTEG    : ENTIER INDIQUANT LA METHODE D'INTEGRATION
C  IN  : NEQ       : NOMBRE D'EQUATIONS
C  IN  : IMAT      : TABLEAU D'ADRESSES POUR LES MATRICES
C  IN  : MASSE     : MATRICE DE MASSE
C  IN  : RIGID     : MATRICE DE RIGIDITE
C  IN  : AMORT     : MATRICE D'AMORTISSEMENT
C  IN  : T0        : INSTANT DE CALCUL INITIAL
C  IN  : NCHAR     : NOMBRE D'OCCURENCES DU MOT CLE CHARGE
C  IN  : NVECA     : NOMBRE D'OCCURENCES DU MOT CLE VECT_ASSE
C  IN  : LIAD      : LISTE DES ADRESSES DES VECTEURS CHARGEMENT (NVECT)
C  IN  : LIFO      : LISTE DES NOMS DES FONCTIONS EVOLUTION (NVECT)
C  IN  : MODELE    : NOM DU MODELE
C  IN  : MATE      : NOM DU CHAMP DE MATERIAU
C  IN  : CARELE    : CARACTERISTIQUES DES POUTRES ET COQUES
C  IN  : CHARGE    : LISTE DES CHARGES
C  IN  : INFOCH    : INFO SUR LES CHARGES
C  IN  : FOMULT    : LISTE DES FONC_MULT ASSOCIES A DES CHARGES
C  IN  : NUMEDD    : NUME_DDL DE LA MATR_ASSE RIGID
C  IN  : NUME      : NUMERO D'ORDRE DE REPRISE
C  IN  : SOLVEU    : NOM DU SOLVEUR
C  IN  : CHONDP    : NOMS DES ONDES PLANES
C  IN  : NONDP     : NOMBRE D'ONDES PLANES
C  VAR : DEP0      : TABLEAU DES DEPLACEMENTS A L'INSTANT N
C  VAR : VIT0      : TABLEAU DES VITESSES A L'INSTANT N
C  VAR : ACC0      : TABLEAU DES ACCELERATIONS A L'INSTANT N
C
C CORPS DU PROGRAMME
      IMPLICIT NONE

C DECLARATION PARAMETRES D'APPELS
      INCLUDE 'jeveux.h'
      INTEGER IINTEG, NEQ, IMAT(3), NCHAR, NVECA, LIAD(*), NUME, NONDP
C
      CHARACTER*8 MASSE, RIGID, AMORT, CHONDP(NONDP)
      CHARACTER*8 RESULT
      CHARACTER*19 FORCE0,FORCE1
      CHARACTER*19 SOLVEU
      CHARACTER*24 MODELE, MATE, CARELE, CHARGE,INFOCH, FOMULT, NUMEDD
      CHARACTER*24 CRITER
      CHARACTER*24 LIFO(*)
C
      REAL*8 DEP0(*), VIT0(*), ACC0(*), T0, FEXTE(*), FAMOR(*), FLIAI(*)
C
      LOGICAL LCREA, LAMORT, LIMPED,LMODST

      CHARACTER*6 NOMPRO
      PARAMETER (NOMPRO = 'DLNEWI')

      INTEGER NBTYAR
      PARAMETER ( NBTYAR = 6 )
      INTEGER IGRPA, IPEPA
      INTEGER IBI,IBMAT, IDDEEQ, IE, IER, IERR
      INTEGER IGREL,IEXCI,IEXCL
      INTEGER IFIMPE
      INTEGER IDEPL1, IDEPLA
      INTEGER IVITE1, IVITEA, IVITA1
      INTEGER IACCE1, IACCEA
      INTEGER IALIEL, IARCHI
      INTEGER IWK1,IWK2,IFORC2
      INTEGER ALARM,ARCHIV
      INTEGER IBID, IRET
      INTEGER IFM, NIV, ETAUSR
      INTEGER IFONDE, IMTRES
      INTEGER IPAS, ISTOP, ITYPEL, ISTOC, JSTOC
      INTEGER JBINT, JFAMMO, JLPAS, JMLTAP, JNBPA
      INTEGER JNOACC, JNODEP, JNOVIT, JPSDEL
      INTEGER JVIEN, JVITE, JREFS
      INTEGER N1, NA, NBEXCI, NBEXCL, NBGREL, NBGRPA, NBMAT, NBORDR
      INTEGER NBPTPA, NBV, ND, NEL, NMODAM, NPATOT, NV
      CHARACTER*1 K1BID
      CHARACTER*3 REPK
      CHARACTER*4 TYP1(NBTYAR),TYPMAT
      CHARACTER*8 K8B,MATRES,MODSTA
      CHARACTER*8 TYPCST(3),NOMDDL
      CHARACTER*8 MAILLA
      CHARACTER*19 NOLIG
      CHARACTER*16 TYPEAR(NBTYAR),NOMTE,K16BID,TYPRES
      CHARACTER*14 NUMDDL
      CHARACTER*19 MAPREC
      CHARACTER*19 LISARC
      CHARACTER*24 LISPAS,LIBINT,LINBPA
      CHARACTER*24 LISINS
      CHARACTER*24 K24AMO
      CHARACTER*24 LIGREL
      CHARACTER*24 VITINI
      CHARACTER*24 VITENT
      CHARACTER*24 VEANEC,VAANEC,DEEQ,VAONDE,VEONDE
      CHARACTER*24 VALMOD,BASMOD,FAMOMO
      CHARACTER*24 NMTRES,NMAT(3)
      REAL*8 LCOEF(3)
      REAL*8 TPS1(4),TPS2(4)
      REAL*8 A0, A1, A2, A3, A4, A5, A6, A7, A8
      REAL*8 C0, C1, C2, C3, C4, C5
      REAL*8 BETA, GAMMA, DT, THETA, TF, TOL, RES
      REAL*8 TEMPM, TEMPS
      CHARACTER*8   VALK
      INTEGER       VALI(2)
      REAL*8        VALR(2)
      LOGICAL GASYMR, GSYRIE, ENER
      INTEGER      IARG

      DATA NOMDDL/'        '/
      DATA VITINI/'&&VITINI'/
      DATA VITENT/'&&VITENT'/
      DATA K24AMO/'&&K24AMO'/
      DATA VALMOD,BASMOD,FAMOMO/'&&VALMOD','&&BASMOD','&&FAMOMO'/
C     -----------------------------------------------------------------
      CALL JEMARQ()
C
C====
C 1. LES DONNEES DU CALCUL
C====
C 1.1. ==> RECUPERATION DU NIVEAU D'IMPRESSION

      CALL INFNIV(IFM,NIV)

      CALL GETRES ( K16BID, TYPRES, K8B )
C
C 1.2. ==> NOM DES STRUCTURES
C
      MAPREC = '&&'//NOMPRO//'.MAPREC    '
      LMODST = .FALSE.

C N: SAISIE DES DONNEES AMOR_MODAL
C    (  MOT CLE FACTEUR: AMOR_MODAL  )
      CALL GETFAC('AMOR_MODAL',NMODAM)
      IF (NMODAM.NE.0) THEN
        CALL NMMOAM(K24AMO,IBID)
        VALMOD=K24AMO(1:19)//'.VALM'
        BASMOD=K24AMO(1:19)//'.BASM'
      END IF

C 1.3. ==> VERIFICATION DE LA PRESENCE D'ELEMENTS AVEC L'OPTION
C         'IMPE_ABSO'

      LIGREL = MODELE(1:8)//'.MODELE'
      NOLIG = LIGREL(1:19)

      LIMPED = .TRUE.

      CALL JELIRA(NOLIG//'.LIEL','NUTIOC',NBGREL,K1BID)
      REPK = 'NON'
      DO 103 IGREL = 1,NBGREL
        CALL JEVEUO(JEXNUM(NOLIG//'.LIEL',IGREL),'L',IALIEL)
        CALL JELIRA(JEXNUM(NOLIG//'.LIEL',IGREL),'LONMAX',NEL,K1BID)
        ITYPEL = ZI(IALIEL-1+NEL)
        CALL JENUNO(JEXNUM('&CATA.TE.NOMTE',ITYPEL),NOMTE)
        IF ((NOMTE(1:9).EQ.'MEFA_FACE') .OR.
     &      (NOMTE(1:6).EQ.'MEFASE')) THEN
          REPK = 'OUI'
          GO TO 1039
        END IF
  103 CONTINUE

      IF (REPK.EQ.'NON') THEN
        LIMPED = .FALSE.
      END IF

 1039 CONTINUE

C 1.4. ==> ???

      K8B = ' '
      CALL DISMOI('F','CHAM_MATER',RIGID,'MATR_ASSE',IBID,K8B,IE)
      IF (K8B.EQ.' ') LIMPED = .FALSE.

      IF (LIMPED) CALL U2MESS('I','ALGORITH3_23')

C     --- CHARGEMENT PAR ONDES PLANES

C 1.5. ==> CREATION D'UN CHAMP_NO POUR LA VITESSE INITIALE

      CALL VTCREB(VITINI,NUMEDD,'V','R',NEQ)
      CALL JEVEUO(VITINI(1:19)//'.VALE','E',JVITE)
      CALL VTCREB(VITENT,NUMEDD,'V','R',NEQ)
      CALL JEVEUO(VITENT(1:19)//'.VALE','E',JVIEN)

C 1.6. ==> CREATION D'UN CHAMP_NO POUR L'AMORTISSEMENT MODAL
      CALL VTCREB(FAMOMO,NUMEDD,'V','R',NEQ)
      CALL JEVEUO(FAMOMO(1:19)//'.VALE','E',JFAMMO)

C 1.7. ==> VECTEURS DE TRAVAIL SUR BASE VOLATILE ---
C                  1234567890123456789
      CALL WKVECT('&&'//NOMPRO//'.F1','V V R',NEQ,IWK1)
      CALL WKVECT('&&'//NOMPRO//'.F2','V V R',NEQ,IWK2)
      CALL WKVECT('&&'//NOMPRO//'.FORCE2','V V R',NEQ,IFORC2)
      CALL VTCREB('&&'//NOMPRO//'.DEPL1',NUMEDD,'V','R',NEQ)
      CALL JEVEUO('&&'//NOMPRO//'.DEPL1     '//'.VALE','E',IDEPL1)
      CALL WKVECT('&&'//NOMPRO//'.VITE1','V V R',NEQ,IVITE1)
      CALL WKVECT('&&'//NOMPRO//'.ACCE1','V V R',NEQ,IACCE1)
      VEANEC = '&&VEANEC           '
      VAANEC = '?????'
      VEONDE = '&&VEONDE           '
      VAONDE = '?????'
      CALL WKVECT('&&'//NOMPRO//'.FOIMPE','V V R',NEQ,IFIMPE)
      CALL WKVECT('&&'//NOMPRO//'.FOONDE','V V R',NEQ,IFONDE)
      CALL WKVECT('&&'//NOMPRO//'.DEPLA','V V R',NEQ,IDEPLA)
      CALL WKVECT('&&'//NOMPRO//'.VITEA','V V R',NEQ,IVITEA)
      CALL WKVECT('&&'//NOMPRO//'.VITA1','V V R',NEQ,IVITA1)
      CALL WKVECT('&&'//NOMPRO//'.ACCEA','V V R',NEQ,IACCEA)
C    Verification de presence des modes_statiques
      CALL GETVID(' ','MODE_STAT',1,IARG,1,MODSTA,NBV)
      CALL GETFAC('EXCIT',NBEXCI)
      DO 69 , IEXCI = 1,NBEXCI
          CALL GETVTX('EXCIT','MULT_APPUI',IEXCI,IARG,1,K8B,ND)
          IF (K8B.EQ.'OUI' .AND. NBV.EQ.0) THEN
             CALL U2MESS('F', 'ALGORITH13_46')
          ENDIF
69      CONTINUE

C 1.8. ==> ???

      IF ( NBV.NE.0 ) THEN

        LMODST = .TRUE.
        CALL DISMOI('F','NOM_MAILLA',MASSE,'MATR_ASSE',IBI,MAILLA,IER)
        CALL DISMOI('F','NOM_NUME_DDL',MASSE,'MATR_ASSE',IBI,NUMDDL,
     &              IRET)
        DEEQ = NUMDDL//'.NUME.DEEQ'
        CALL JEVEUO(DEEQ,'L',IDDEEQ)
        CALL GETFAC('EXCIT',NBEXCI)
        CALL WKVECT('&&'//NOMPRO//'.FDEP','V V K8',NBEXCI,JNODEP)
        CALL WKVECT('&&'//NOMPRO//'.FVIT','V V K8',NBEXCI,JNOVIT)
        CALL WKVECT('&&'//NOMPRO//'.FACC','V V K8',NBEXCI,JNOACC)
        CALL WKVECT('&&'//NOMPRO//'.MLTP','V V I',NBEXCI,JMLTAP)
        CALL WKVECT('&&'//NOMPRO//'.IPSD','V V R',NBEXCI*NEQ,JPSDEL)
        DO 108 , IEXCI = 1,NBEXCI
C     --- CAS D'UN ACCELEROGRAMME
          CALL GETVTX('EXCIT','MULT_APPUI',IEXCI,IARG,1,K8B,ND)
          IF (K8B.EQ.'OUI') THEN
            ZI(JMLTAP+IEXCI-1) = 1
            CALL GETVID('EXCIT','ACCE',IEXCI,IARG,1,
     &                  ZK8(JNOACC+IEXCI-1),NA)
            CALL GETVID('EXCIT','VITE',IEXCI,IARG,1,
     &                  ZK8(JNOVIT+IEXCI-1),NV)
            CALL GETVID('EXCIT','DEPL',IEXCI,IARG,1,
     &                  ZK8(JNODEP+IEXCI-1),ND)
            CALL TRMULT(MODSTA,IEXCI,MAILLA,NEQ,IDDEEQ,
     &                  ZR(JPSDEL+ (IEXCI-1)*NEQ))
C     --- MISE A ZERO DES DDL DE LAGRANGE
            CALL ZERLAG(ZR(JPSDEL+ (IEXCI-1)*NEQ),NEQ,ZI(IDDEEQ))
          ELSE
            ZI(JMLTAP+IEXCI-1) = 0
          END IF
  108   CONTINUE

      END IF

C 1.9. ==> INTIALISATIONS DIVERSES

      LCOEF(1) = 1.D0
      TYPCST(1) = 'R'
      TYPCST(2) = 'R'
      TYPCST(3) = 'R'
      TYPMAT = 'R'
      IF (LAMORT) THEN
        NBMAT = 3
      ELSE
        NBMAT = 2
      END IF
      IARCHI = NUME
      LISINS = ' '
      ENER=.FALSE.
      CALL GETFAC('ENERGIE',N1)
      IF (N1.NE.0) THEN
        ENER=.TRUE.
      ENDIF

C 1.10. ==> --- PARAMETRES D'INTEGRATION ---

      IF ( IINTEG.EQ.1 ) THEN
        CALL GETVR8('SCHEMA_TEMPS','BETA',1,IARG,1,BETA,N1)
        CALL GETVR8('SCHEMA_TEMPS','GAMMA',1,IARG,1,GAMMA,N1)
        RES = 0.25D0* (0.5D0+GAMMA)* (0.5D0*GAMMA)
        TOL = 1.D-8
        IF ( GAMMA.LT.(0.5D0-TOL) .OR. BETA.LT.(RES-TOL) ) THEN
          WRITE (IFM,*) ' >>> NEWMARK <<<'//
     &      'CAS CONDITIONNELLEMENT STABLE.'
        END IF
        IF ( BETA.EQ.0) THEN
          CALL U2MESS('F','ALGORITH9_2')
        ENDIF
      ELSE
        CALL GETVR8('SCHEMA_TEMPS','THETA',1,IARG,1,THETA,N1)
      END IF

C 1.11. ==> --- LISTE DES INSTANTS DE CALCUL ET LES SORTIES ---

      CALL DLTINS(NBGRPA,LISPAS,LIBINT,LINBPA,NPATOT,T0,LISINS)
      CALL JEVEUO(LISPAS,'L',JLPAS)
      CALL JEVEUO(LIBINT,'L',JBINT)
      CALL JEVEUO(LINBPA,'L',JNBPA)


C 1.12. ==> --- ARCHIVAGE ---

      LISARC = '&&'//NOMPRO//'.ARCHIVAGE'
      CALL DYARCH ( NPATOT, LISINS, LISARC, NBORDR, 1, NBEXCL, TYP1 )
      CALL JEVEUO(LISARC,'E',JSTOC)
C
      TYPEAR(1) = 'DEPL'
      TYPEAR(2) = 'VITE'
      TYPEAR(3) = 'ACCE'
      IF (ENER) THEN
        TYPEAR(4) = 'FORC_EXTE'
        TYPEAR(5) = 'FORC_AMOR'
        TYPEAR(6) = 'FORC_LIAI'
      ELSE
        TYPEAR(4) = '         '
        TYPEAR(5) = '         '
        TYPEAR(6) = '         '
      ENDIF
      IF ( NBEXCL.EQ.NBTYAR ) THEN
        CALL U2MESS('F','ALGORITH3_14')
      ENDIF
      DO 112 , IEXCL = 1,NBEXCL
        IF (TYP1(IEXCL).EQ.'DEPL') THEN
          TYPEAR(1) = '    '
        ELSE IF (TYP1(IEXCL).EQ.'VITE') THEN
          TYPEAR(2) = '    '
        ELSE IF (TYP1(IEXCL).EQ.'ACCE') THEN
          TYPEAR(3) = '    '
        ENDIF
  112 CONTINUE

C 1.13. ==>  --- AFFICHAGE DE MESSAGES SUR LE CALCUL ---

      WRITE (IFM,*) '-------------------------------------------------'
      WRITE (IFM,*) '--- CALCUL PAR INTEGRATION TEMPORELLE DIRECTE ---'
      WRITE (IFM,*) '! LA MATRICE DE MASSE EST         : ',MASSE
      WRITE (IFM,*) '! LA MATRICE DE RIGIDITE EST      : ',RIGID
      IF (LAMORT) WRITE (IFM,*) '! LA MATRICE D''AMORTISSEMENT EST : ',
     &    AMORT
      WRITE (IFM,*) '! LE NB D''EQUATIONS EST          : ',NEQ
      IF (NUME.NE.0) WRITE (IFM,*)
     &    '! REPRISE A PARTIR DU NUME_ORDRE  : ',NUME
      DO 113 , IGRPA = 1,NBGRPA
        DT = ZR(JLPAS-1+IGRPA)
        NBPTPA = ZI(JNBPA-1+IGRPA)
        T0 = ZR(JBINT-1+IGRPA)
        TF = T0 + NBPTPA*DT
        WRITE (IFM,*) '! POUR LE GROUPE DE PAS NUMERO   : ',IGRPA
        WRITE (IFM,*) '! L''INSTANT INITIAL EST         : ',T0
        WRITE (IFM,*) '! L''INSTANT FINAL EST           : ',TF
        WRITE (IFM,*) '! LE PAS DE TEMPS DU CALCUL EST  : ',DT
        WRITE (IFM,*) '! LE NB DE PAS DE CALCUL EST : ',NBPTPA
  113 CONTINUE
      WRITE (IFM,*) '----------------------------------------------',' '
C
C====
C 2. CREATION DU CONCEPT RESULTAT
C====
C
      T0 = ZR(JBINT)
      CALL DLTCRR ( RESULT,
     &              NEQ, NBORDR, IARCHI, ' ', IFM,
     &              T0, LCREA, TYPRES,
     &              MASSE, RIGID, AMORT,
     &              DEP0, VIT0, ACC0,
     &              FEXTE,FAMOR,FLIAI,
     &              NUMEDD, NUME, NBTYAR, TYPEAR )
C
C====
C 3. CALCUL
C====
C
C 3.1. ==> CREATION DE LA MATRICE KTILD
      MATRES = '&&KTILD'
      IF (LAMORT) THEN
          CALL JEVEUO(AMORT//'           .REFA','L',JREFS)
          GASYMR=ZK24(JREFS-1+9) .EQ. 'MR'
      ELSE
          GASYMR=.FALSE.
      END IF
      CALL JEVEUO(RIGID//'           .REFA','L',JREFS)
      GSYRIE=ZK24(JREFS-1+9) .EQ. 'MS'
C SI LA MATRICE DE RIGIDITE EST SYMETRIQUE
C ET SI LA LA MATRICE AMORTISSEMENT EST ASYMETRIQUE ON CONSTRUIT
C LA MATRICE KTILDE SUR LE MODELE DE LA MATRICE AMORTISSEMENT
      IF (GASYMR .AND. GSYRIE) THEN
         CALL MTDEFS(MATRES,AMORT,'V',TYPMAT)
      ELSE
         CALL MTDEFS(MATRES,RIGID,'V',TYPMAT)
      END IF
      CALL MTDSCR(MATRES)
      CALL JEVEUO(MATRES//'           .&INT','E',IMTRES)

C 3.2. ==> BOUCLE SUR LES GROUPES DE PAS DE TEMPS
      ISTOC = 0
      ISTOP = 0
      IPAS = 0
      CALL UTTCPU('CPU.DLNEWI.1','INIT',' ')
      CALL UTTCPU('CPU.DLNEWI.2','INIT',' ')
      DO 32 IGRPA = 1,NBGRPA
C
C 3.2.1. ==> PREALABLES
C
        CALL UTTCPU('CPU.DLNEWI.1','DEBUT',' ')
        DT = ZR(JLPAS-1+IGRPA)
        NBPTPA = ZI(JNBPA-1+IGRPA)
        T0 = ZR(JBINT-1+IGRPA)
        IF ( IINTEG.EQ.2 ) THEN
          A0 = 6.D0/ (THETA*DT)/ (THETA*DT)
          A1 = 3.D0/THETA/DT
          A2 = 2.D0*A1
          A3 = THETA*DT/2.D0
          A4 = A0/THETA
          A5 = -A2/THETA
          A6 = 1.D0 - 3.D0/THETA
          A7 = DT/2.D0
          A8 = DT*DT/6.D0
          C0 = A0
          C1 = A2
          C2 = 2.0D0
          C3 = A1
          C4 = 2.0D0
          C5 = A3
        ELSE IF ( IINTEG.EQ.1 ) THEN
          A0 = 1.D0/BETA/DT/DT
          A1 = GAMMA/BETA/DT
          A2 = 1.D0/BETA/DT
          A3 = .5D0/BETA - 1.D0
          A4 = GAMMA/BETA - 1.D0
          A5 = DT/2.D0* (GAMMA/BETA-2.D0)
          A6 = DT* (1.D0-GAMMA)
          A7 = GAMMA*DT
          C0 = A0
          C1 = A2
          C2 = A3
          C3 = A1
          C4 = A4
          C5 = A5
        END IF

C 3.2.2. ==> CALCUL DE LA MATRICE DE PSEUDO-RAIDEUR
C                  K*  = K + A0*M + A1*C
        LCOEF(2) = A0
        LCOEF(3) = A1

        DO 322 , IBMAT = 1,NBMAT
          NMAT(IBMAT) = ZK24(ZI(IMAT(IBMAT)+1))
  322   CONTINUE
        NMTRES = ZK24(ZI(IMTRES+1))
        CALL MTCMBL(NBMAT,TYPCST,LCOEF,NMAT,NMTRES,NOMDDL,' ','ELIM=')

C 3.2.3. ==> DECOMPOSITION OU CALCUL DE LA MATRICE DE PRECONDITIONNEMENT
        CALL PRERES(SOLVEU,'V',IERR,MAPREC,MATRES,IBID,-9999)

C 3.2.4. ==> BOUCLE SUR LES NBPTPA "PETITS" PAS DE TEMPS

        DO 324 , IPEPA = 1,NBPTPA
C
          IPAS = IPAS + 1
          IF (IPAS.GT.NPATOT) GO TO 3900
          CALL UTTCPU('CPU.DLNEWI.2','DEBUT',' ')
          ISTOC = 0
          TEMPS = T0 + DT*IPEPA
          TEMPM = T0 + DT* (IPEPA-1)
          ARCHIV = ZI(JSTOC+IPAS-1)
          CALL DLNEW0 ( RESULT,FORCE0,FORCE1,
     &                  IINTEG, NEQ, ISTOC, IARCHI, IFM,
     &                  NBEXCI, NONDP, NMODAM,
     &                  LAMORT, LIMPED, LMODST, IMAT, MASSE, RIGID,
     &                  AMORT,NCHAR, NVECA, LIAD, LIFO, MODELE,
     &                  MATE, CARELE, CHARGE, INFOCH, FOMULT, NUMEDD,
     &                  ZR(IDEPLA), ZR(IVITEA), ZR(IACCEA),
     &                  DEP0, VIT0, ACC0,
     &                  FEXTE,FAMOR,FLIAI,
     &                  ZR(IDEPL1), ZR(IVITE1), ZR(IACCE1),
     &                  ZR(JPSDEL), ZR(JFAMMO), ZR(IFIMPE), ZR(IFONDE),
     &                  ZR(JVIEN), ZR(JVITE), ZR(IVITA1), ZI(JMLTAP),
     &                  A0, A2, A3, A4, A5, A6, A7, A8,
     &                  C0, C1, C2, C3, C4, C5,
     &                  ZK8(JNODEP), ZK8(JNOVIT), ZK8(JNOACC),
     &                  MATRES, MAPREC, SOLVEU, CRITER, CHONDP, ENER,
     &                  VITINI, VITENT, VALMOD, BASMOD,
     &                  VEANEC, VAANEC, VAONDE, VEONDE,
     &                  DT, THETA, TEMPM, TEMPS, IFORC2,
     &                  ZR(IWK1), ZR(IWK2), ARCHIV, NBTYAR, TYPEAR )


C 3.2.5. ==> VERIFICATION DU TEMPS DE CALCUL RESTANT
C
          CALL UTTCPU('CPU.DLNEWI.2','FIN',' ')
          CALL UTTCPR('CPU.DLNEWI.2',4,TPS2)
          IF (TPS2(1).LT.5.D0 .OR. TPS2(4).GT.TPS2(1)) THEN
            ISTOP = 1
            VALI(1) = IGRPA
            VALI(2) = IPEPA
            VALR(1) = TPS2(4)
            VALR(2) = TPS2(1)
            GO TO 3900
          END IF

C ---------- FIN DE LA BOUCLE SUR LES NBPTPA "PETITS" PAS DE TEMPS
  324   CONTINUE

        CALL UTTCPU('CPU.DLNEWI.1','FIN',' ')
        CALL UTTCPR('CPU.DLNEWI.1',4,TPS1)
        IF (TPS1(1).LT.5.D0 .AND. IGRPA.NE.NBGRPA) THEN
          ISTOP = 1
          VALI(1) = IGRPA
          VALI(2) = IPEPA
          VALR(1) = TPS1(4)
          VALR(2) = TPS1(1)
          GO TO 3900
        END IF

C ------- FIN BOUCLE SUR LES GROUPES DE PAS DE TEMPS

   32 CONTINUE

 3900 CONTINUE
C
C====
C 4. ARCHIVAGE DU DERNIER INSTANT DE CALCUL POUR LES CHAMPS QUI ONT
C    ETE EXCLUS DE L'ARCHIVAGE AU FIL DES PAS DE TEMPS
C====
C
      IF ( NBEXCL.NE.0 ) THEN
C
        DO 41 , IEXCL = 1,NBEXCL
          TYPEAR(IEXCL) = TYP1(IEXCL)
   41   CONTINUE
        ALARM = 0
        CALL DLARCH ( RESULT,NEQ, ISTOC, IARCHI, ' ',
     &                ALARM, IFM, TEMPS,
     &                NBEXCL, TYPEAR, MASSE,
     &                DEP0, VIT0, ACC0,
     &                FEXTE,FAMOR,FLIAI )
      ENDIF
C
C====
C 5. LA FIN
C====
C
C     --- VERIFICATION SI INTERRUPTION DEMANDEE PAR SIGNAL USR1
C
      IF ( ETAUSR().EQ.1 ) THEN
         CALL SIGUSR()
      ENDIF
C
      IF ( ISTOP.EQ.1 ) THEN
        CALL UTEXCM(28, 'DYNAMIQUE_10', 0, VALK, 2, VALI, 2, VALR)
      ENDIF

C     --- DESTRUCTION DES OBJETS DE TRAVAIL ---

      CALL JEEXIN(CRITER(1:19)//'.CRTI',IRET)
      IF (IRET.NE.0) THEN
        CALL JEDETR(CRITER(1:19)//'.CRTI')
        CALL JEDETR(CRITER(1:19)//'.CRTR')
        CALL JEDETR(CRITER(1:19)//'.CRDE')
      END IF
      CALL DETRSD('MATR_ASSE',MATRES)

      CALL JEDEMA()
C
      END
