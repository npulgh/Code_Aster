      SUBROUTINE CHARCI ( CHCINE, MFACT, MO, TYPE)
      IMPLICIT NONE
      CHARACTER*(*)       CHCINE, MFACT, MO
      CHARACTER*1         TYPE
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 01/03/2011   AUTEUR PELLET J.PELLET 
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
C-----------------------------------------------------------------------
C OBJET :
C        TRAITEMENT DES MOTS CLES FACTEURS DE L'OPERATEUR
C        CREATION D'UN CHAM_NO_S CONTENANT LES DEGRES IMPOSES
C
C-----------------------------------------------------------------------
C VAR  CHCINE  K*19    : NOM DE LA CHARGE CINEMATIQUE
C IN   MFACT   K*16    : MOT CLE FACTEUR A TRAITER
C                        MOTS CLES ADMIS : MECA_IMPO
C                                          THER_IMPO
C                                          ACOU_IMPO
C IN   MO      K*      : NOM DU MODELE
C IN   TYPE    K*1     : 'R','C' OU 'F' TYPE DES MOTS CLES
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR,RBID
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC,CBID
      COMMON /CVARJE/ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32,JEXNOM
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------
      INTEGER IBID, IFM, NIV, ICMP, CMP, IER, INO, NBNO, NUNO
      INTEGER IOC, JCNSV, JCNSL, IDINO, NBOBM, JDDL, JTYP, N
      INTEGER IDNDDL, IDVDDL, NBDDL, IDDL, I, IDPROL, JAFCK
      INTEGER ILA, INDIK8, NBCMP, JCMP, NOC, N1, IORD,IRET
      INTEGER JNOXFL,NLICMP
      CHARACTER*2   TYP
      CHARACTER*8   K8B, MA, NOMGD, NOGDSI, GDCNS
      CHARACTER*8   EVOIM,LICMP(20)
      CHARACTER*16  MFAC, K16B, MOTCLE(5), PHENOM,TYPCO
      CHARACTER*19  CHCI, CNS, CNS2, DEPLA, NOXFEM
      CHARACTER*24  CINO, CNUDDL, CVLDDL, NPROL
      CHARACTER*80  TITRE
      LOGICAL       LXFEM
      DATA NPROL/'                   .PROL'/
C --- DEBUT -----------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFNIV ( IFM, NIV )

      CHCI = CHCINE
      CALL JEVEUO(CHCI//'.AFCK','E',JAFCK)
      MFAC = MFACT
      CALL GETFAC(MFAC,NOC)

      CALL DISMOI('F','NOM_MAILLA',MO,'MODELE',IBID,MA,IER)
      CALL DISMOI('F','PHENOMENE',MO,'MODELE',IBID,PHENOM,IER)
      CALL DISMOI('F','NOM_GD',PHENOM,'PHENOMENE',IBID,NOMGD,IER)
      CALL DISMOI('F','NOM_GD_SI',NOMGD,'GRANDEUR',IBID,NOGDSI,IER)
      CALL JEVEUO(JEXNOM('&CATA.GD.NOMCMP',NOGDSI),'L',JCMP)
      CALL JELIRA(JEXNOM('&CATA.GD.NOMCMP',NOGDSI),'LONMAX',NBCMP,K8B)
      CNS='&&CHARCI.CNS'

C    --------------------------------------------------------
C    MODELE X-FEM
C    --------------------------------------------------------
      CALL JEEXIN(MO(1:8)//'.XFEM_CONT',IER)
      IF (IER.EQ.0) THEN
        LXFEM = .FALSE.
      ELSE
        LXFEM = .TRUE.
        NOXFEM = '&&CHARCI.NOXFEM'
        CALL CNOCNS(MO(1:8)//'.NOXFEM','V',NOXFEM)
        CALL JEVEUO(NOXFEM//'.CNSL','L',JNOXFL)
      ENDIF

C     -- CAS DE EVOL_IMPO : ON IMPOSE TOUS LES DDLS DU 1ER CHAMP
C     ------------------------------------------------------------
      EVOIM=' '
      IF (NOC.EQ.0) THEN
        CALL ASSERT(MFAC.EQ.'MECA_IMPO'.OR.MFAC.EQ.'THER_IMPO')
        CALL GETVID(' ','EVOL_IMPO',1,1,1,EVOIM,N1)
        CALL ASSERT(N1.EQ.1)
        CALL GETVTX(' ','NOM_CMP',1,1,20,LICMP,NLICMP)
        CALL ASSERT(NLICMP.GE.0)

        CALL GETTCO(EVOIM,TYPCO)
        IF (TYPCO.EQ.'EVOL_THER') THEN
          ZK8(JAFCK-1+1)='CITH_FT'
        ELSE IF (TYPCO.EQ.'EVOL_ELAS'.OR.TYPCO.EQ.'EVOL_NOLI') THEN
          ZK8(JAFCK-1+1)='CIME_FT'
        ELSE
          CALL ASSERT(.FALSE.)
        ENDIF
        ZK8(JAFCK-1+3)=EVOIM

C       -- C'EST LE CHAMP DU 1ER NUMERO D'ORDRE QUI IMPOSE SA LOI:
        CALL RSORAC (EVOIM,'PREMIER',IBID,RBID,K8B,CBID,0.D0,
     &               'ABSOLU',IORD,1,IRET)
        CALL ASSERT(IRET.EQ.1)
        IF (MFAC.EQ.'MECA_IMPO') THEN
          CALL RSEXCH(EVOIM,'DEPL',IORD,DEPLA,IRET)
        ELSE
          CALL RSEXCH(EVOIM,'TEMP',IORD,DEPLA,IRET)
        ENDIF
        CALL ASSERT(IRET.EQ.0)
        CALL CNOCNS(DEPLA,'V',CNS)

C       -- SI NOM_CMP EST UTILISE, IL FAUT "REDUIRE" CNS :
        IF (NLICMP.GT.0) THEN
          CNS2='&&CHARCI.CNS2'
          CALL CNSRED(CNS,0,0,NLICMP,LICMP,'V',CNS2)
          CALL DETRSD('CHAM_NO_S',CNS)
          CALL COPISD('CHAM_NO_S','V',CNS2,CNS)
          CALL DETRSD('CHAM_NO_S',CNS2)
        ENDIF
        CALL IMPRSD('CHAMP',CNS,6,'CNS APRES RED')
        GOTO 200
      ENDIF



C --- NOM DE TABLEAUX DE TRAVAIL :
      CINO   = '&&CHARCI.INO'
      CNUDDL = '&&CHARCI.NUMDDL'
      CVLDDL = '&&CHARCI.VALDDL'

      MOTCLE(1) = 'GROUP_MA'
      MOTCLE(2) = 'MAILLE'
      MOTCLE(3) = 'GROUP_NO'
      MOTCLE(4) = 'NOEUD'
      MOTCLE(5) = 'TOUT'
      CALL ASSERT((TYPE.EQ.'F').OR.(TYPE.EQ.'R').OR.(TYPE.EQ.'C'))

      IF (TYPE.EQ.'F') THEN
         TYP   = 'K8'
         GDCNS = NOMGD
         GDCNS(5:6) = '_F'
      ELSE IF (TYPE.EQ.'R') THEN
         TYP = TYPE
         GDCNS = NOMGD
      ELSE IF (TYPE.EQ.'C') THEN
         TYP = TYPE
         GDCNS = NOMGD
      ENDIF
C
C --- CREATION D'UN CHAM_NO_S
C
      CALL CNSCRE ( MA, GDCNS, NBCMP, ZK8(JCMP), 'V', CNS )
C
C --- REMPLISSAGE DU CHAM_NO_S
C
      CALL JEVEUO ( CNS//'.CNSV', 'E', JCNSV )
      CALL JEVEUO ( CNS//'.CNSL', 'E', JCNSL )

      DO 100 IOC = 1,NOC

C ----- NOEUDS A CONTRAINDRE :

        CALL RELIEM ( ' ', MA, 'NU_NOEUD', MFAC, IOC, 5, MOTCLE, MOTCLE,
     &                CINO, NBNO )
        IF (NBNO.EQ.0) GOTO 100
        CALL JEVEUO ( CINO, 'L', IDINO )

C ----- DDL A CONTRAINDRE :

        CALL GETMJM ( MFAC, IOC,0, K16B, K16B, NBOBM )
        NBOBM = -NBOBM
        CALL WKVECT ( '&&CHARCI.NOM', 'V V K16', NBOBM, JDDL )
        CALL WKVECT ( '&&CHARCI.TYP', 'V V K8' , NBOBM, JTYP )
        CALL GETMJM ( MFAC, IOC, NBOBM, ZK16(JDDL), ZK8(JTYP), N )

C ----- LECTURE DES MOTS CLES RELATIFS AUX VALEURS IMPOSEES

        CALL WKVECT ( CNUDDL, ' V V K8'   , NBOBM, IDNDDL )
        CALL WKVECT ( CVLDDL, ' V V '//TYP, NBOBM, IDVDDL )
        NBDDL = 0
        DO 110 IDDL = 1 , NBOBM
          K16B = ZK16(JDDL+IDDL-1)
          DO 112 I = 1,5
             IF (K16B.EQ.MOTCLE(I)) GOTO 110
 112      CONTINUE
C
          ZK8(IDNDDL+NBDDL) = K16B(1:8)
C
C ------- VERIFICATION QUE LA COMPOSANTE EXISTE DANS LA GRANDEUR
          ICMP = INDIK8( ZK8(JCMP), K16B(1:8), 1, NBCMP )
          CALL ASSERT( ICMP .NE. 0 )

C ------- VERIFICATION DE LA COMPOSANTE SUR LES NOEUDS XFEM
          IF (LXFEM) THEN
            IF (K16B(1:1).EQ.'D') THEN
              DO 113 INO = 1,NBNO
                NUNO = ZI(IDINO-1+INO)
                CALL ASSERT(.NOT.ZL(JNOXFL-1+2*NUNO))
 113          CONTINUE
            ENDIF
          ENDIF
C
          IF (TYPE.EQ.'R')
     &             CALL GETVR8(MFAC,K16B,IOC,1,1, ZR(IDVDDL+NBDDL),ILA)
          IF (TYPE.EQ.'C')
     &             CALL GETVC8(MFAC,K16B,IOC,1,1, ZC(IDVDDL+NBDDL),ILA)
          IF (TYPE.EQ.'F')
     &             CALL GETVID(MFAC,K16B,IOC,1,1,ZK8(IDVDDL+NBDDL),ILA)
          NBDDL = NBDDL+1
 110    CONTINUE

C --- ON RECHERCHE SI UNE QUAND ON A DES FONCT. IL Y EN A UNE = F(TPS)
C
        IF (TYPE.EQ.'F') THEN
          DO 120 I = 1,NBDDL
            NPROL(1:8) = ZK8(IDVDDL-1+I)
            CALL JEVEUO(NPROL,'L',IDPROL)
            IF ( ZK24(IDPROL+2).EQ.'INST') THEN
              ZK8(JAFCK)(5:7) = '_FT'
              GOTO 122
            ELSE IF (( ZK24(IDPROL).EQ.'NAPPE').AND.
     &               ( ZK24(IDPROL+6).EQ.'INST')) THEN
              ZK8(JAFCK)(5:7) = '_FT'
              GOTO 122
            ENDIF
 120      CONTINUE
        ENDIF
 122    CONTINUE

C ----- AFFECTATION DANS LE CHAM_NO_S

        IF ( TYPE .EQ. 'R') THEN
          DO 130 CMP = 1, NBDDL
            K8B = ZK8(IDNDDL-1+CMP)
            ICMP = INDIK8( ZK8(JCMP), K8B, 1, NBCMP )
            DO 132 INO = 1 , NBNO
               NUNO = ZI(IDINO-1+INO)
               ZR(JCNSV+(NUNO-1)*NBCMP+ICMP-1) = ZR(IDVDDL-1+CMP)
               ZL(JCNSL+(NUNO-1)*NBCMP+ICMP-1) = .TRUE.
 132        CONTINUE
 130      CONTINUE
        ELSEIF ( TYPE .EQ. 'C') THEN
          DO 140 CMP = 1, NBDDL
            K8B = ZK8(IDNDDL-1+CMP)
            ICMP = INDIK8( ZK8(JCMP), K8B, 1, NBCMP )
            DO 142 INO = 1 , NBNO
               NUNO = ZI(IDINO-1+INO)
               ZC(JCNSV+(NUNO-1)*NBCMP+ICMP-1) = ZC(IDVDDL-1+CMP)
               ZL(JCNSL+(NUNO-1)*NBCMP+ICMP-1) = .TRUE.
 142        CONTINUE
 140      CONTINUE
        ELSEIF ( TYPE .EQ. 'F') THEN
          DO 150 CMP = 1, NBDDL
            K8B = ZK8(IDNDDL-1+CMP)
            ICMP = INDIK8( ZK8(JCMP), K8B, 1, NBCMP )
            DO 152 INO = 1 , NBNO
               NUNO = ZI(IDINO-1+INO)
               ZK8(JCNSV+(NUNO-1)*NBCMP+ICMP-1) = ZK8(IDVDDL-1+CMP)
                ZL(JCNSL+(NUNO-1)*NBCMP+ICMP-1) = .TRUE.
 152        CONTINUE
 150      CONTINUE
        ENDIF
C
        CALL JEDETR ( CINO   )
        CALL JEDETR ( CNUDDL )
        CALL JEDETR ( CVLDDL )
        CALL JEDETR ( '&&CHARCI.NOM' )
        CALL JEDETR ( '&&CHARCI.TYP' )

 100  CONTINUE
 200  CONTINUE


      IF (( NIV.GE.2).AND.(EVOIM.EQ.' ')) THEN
        TITRE = '******* IMPRESSION DU CHAMP DES DEGRES IMPOSES *******'
        CALL IMPRSD ( 'CHAMP_S', CNS, IFM, TITRE )
      ENDIF


C --- CREATION DE LA SD AFFE_CHAR_CINE
      CALL CHCSUR( CHCI, CNS, TYPE, MO, NOGDSI )
      CALL DETRSD('CHAMP',CNS)

C     -- SI EVOL_IMPO : IL NE FAUT PAS UTILISER LES VALEURS DE CHCI :
      IF (EVOIM.NE.' ') CALL JEDETR(CHCI//'.AFCV')

      IF (LXFEM) THEN
        CALL JEDETR(NOXFEM)
      ENDIF
C
      CALL JEDEMA()
      END
