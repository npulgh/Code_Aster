      SUBROUTINE SPECT1(CASINT,NOMU,SPECTR,ISPECT,BASE,VITE,NUOR,
     &                  IMODI,IMODF,NBM,NBPF,NPV,NOMZON,VMOYZI,VMOYTO)
      IMPLICIT REAL*8 (A-H,O-Z)
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 13/06/2012   AUTEUR COURTOIS M.COURTOIS 
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
C TOLE CRP_7
C TOLE CRS_513
C-----------------------------------------------------------------------
C     PROJECTION D UN SPECTRE DE TURBULENCE DE TYPE "LONGUEUR DE
C     CORRELATION" SUR UNE BASE MODALE PERTURBEE PAR PRISE EN COMPTE
C     DU COUPLAGE FLUIDE STRUCTURE
C     APPELANT : OP0146 , OPERATEUR PROJ_SPEC_BASE
C-----------------------------------------------------------------------
C IN  : CASINT  : BOOLEEN, DONNE L'OPTION DE CALCUL
C       CASINT  = .TRUE.  => CALCUL DE TOUS LES INTERSPECTRES
C       CASINT  = .FALSE. => CALCUL DES AUTOSPECTRES UNIQUEMENT
C IN  : NOMU    : NOM UTILISATEUR
C IN  : SPECTR  : NOM DU CONCEPT SPECTRE
C IN  : ISPECT  : NUMERO DU SPECTRE
C IN  : BASE    : NOM DU CONCEPT MELASFLU
C IN  : VITE    : VITESSES ETUDIEES, VECTEUR DE DIM=NPV
C IN  : NUOR    : NUMEROS D'ORDRE DES MODES DU CONCEPT MELASFLU
C IN  : IMODI   : INDICE DU PREMIER MODE PRIS EN COMPTE
C IN  : IMODF   : INDICE DU DERNIER MODE PRIS EN COMPTE
C IN  : NBM     : NOMBRE DE MODES DU CONCEPT MELASFLU
C IN  : NBPF    : NOMBRE DE POINTS DE LA DISCRETISATION FREQUENTIELLE
C IN  : NPV     : NOMBRE DE VITESSES ETUDIEES
C IN  : NOMZON  : NOM DE LA ZONE (OU PROFI DE VITESSE) ASSOCIEE AU
C                 SPECTRE COURANT
C IN  : VMOYZI  : VITESSE MOYENNE DE LA ZONE NOMZON
C IN  : VMOYTO  : VITESSE MOYENNE DE L ENSEMBLE DES ZONES D EXCITATION
C                 DU FLUIDE
C-----------------------------------------------------------------------
C
      INCLUDE 'jeveux.h'
      LOGICAL      CASINT
      CHARACTER*8  NOMU,NOMZON,K8BID
      CHARACTER*19 SPECTR,BASE
      REAL*8       VITE(NPV),VMOYZI,VMOYTO
      INTEGER      NUOR(NBM),VALI(2)
C
      INTEGER      DIM,NBVAL,ICMP
      CHARACTER*8  NOMCMP,DEPLA(3)
      CHARACTER*19 TYPFLU,CAELEM,NOMFON
      CHARACTER*24 REFE,FSIC,FSVI,FSVK,PROFVN,FRHOE,NOMCHA,VALR,VALE
      CHARACTER*3  TOUT
      REAL*8       SPECT2,SPECT4,RBID,VALX(3)
      INTEGER      IARG
      EXTERNAL     SPECT4
      DATA DEPLA   /'DX      ','DY      ','DZ      '/
C-----------------------------------------------------------------------
      CALL JEMARQ()
      TOL = 1.D-05
      IER = 0
C
C
C --- 1.RECUPERATION D'INFORMATIONS PAR INDIRECTION ---
C
C --- 1.1.NOM DU CONCEPT TYPE_FLUI_STRU ASSOCIE A L'ETUDE
C
      REFE = BASE//'.REMF'
      CALL JEVEUO(REFE,'L',IREFE)
      TYPFLU = ZK8(IREFE)
C
C --- 1.2.TEST DE COMPATIBILITE TYPE DE SPECTRE/CONFIGURATION ETUDIEE
C
      FSIC = TYPFLU//'.FSIC'
      CALL JEVEUO(FSIC,'L',IFSIC)
      ITYPFL = ZI(IFSIC)
      IF (ITYPFL.NE.1) THEN
        CALL U2MESS('F','MODELISA7_4')
      ENDIF
C
C --- 1.3.RECUPERATION DE NOMS DE CONCEPTS PAR INDIRECTION
C
      FSVI = TYPFLU//'.FSVI'
      CALL JEVEUO(FSVI,'L',IFSVI)
      NZEX = ZI(IFSVI+1)
      FSVK = TYPFLU//'.FSVK'
      CALL JEVEUO(FSVK,'L',IFSVK)
      CAELEM = ZK8(IFSVK)
      NOMCMP = ZK8(IFSVK+1)
      FRHOE  = ZK8(IFSVK+3)
C
      DO 10 IZ = 1,NZEX
         IF(NOMZON.EQ.ZK8(IFSVK+3+IZ)) THEN
            PROFVN = NOMZON
            GOTO 11
         ENDIF
  10  CONTINUE
  11  CONTINUE
C
C
C --- 2.ACCES AU PROFIL DE VITESSE
C ---         AU PROFIL DE MASSE VOLUMIQUE DU FLUIDE EXTERNE ---
C
C --- 2.1.ACCES AUX OBJETS .VALE
C
      PROFVN = PROFVN(1:19)//'.VALE'
      CALL JEVEUO(PROFVN,'L',IPVN)
      FRHOE = FRHOE(1:19)//'.VALE'
      CALL JEVEUO(FRHOE,'L',IRHOE)
C
C --- 2.2.RECUPERATION DU NOMBRE DE NOEUDS DU MAILLAGE
C
      CALL JELIRA(PROFVN,'LONUTI',NBP,K8BID)
      NBP = NBP / 2
C
C
C --- 3.RECUPERATION DU DIAMETRE EXTERIEUR DU TUBE ---
C
      CALL RECUDE(CAELEM,PHIE,RBID)
C
C
C --- 4.RECUPERATION DE LA LONGUEUR DE CORRELATION PHYSIQUE ---
C
      VALR = SPECTR//'.VARE'
      CALL JEVEUO(VALR,'L',IRSP)
C
      XLC = ZR(IRSP)
      XLC = XLC*PHIE
C
C
C --- 5.CALCUL DES LONGUEURS DE CORRELATION GENERALISEES ---
C
C --- 5.1.RECHERCHE POUR L INTEGRALE DOUBLE DES BORNES
C ---     DE LA ZONE OU LA FONCTION EST NON NULLE
C
      X1 = 0.D0
      X2 = 0.D0
      DO 50 IK = 1,NBP
        IF (ZR(IPVN+NBP+IK-1).NE.0.D0) THEN
          X1 = ZR(IPVN+IK-1)
          N1 = IK
          GO TO 51
        ENDIF
  50  CONTINUE
  51  CONTINUE
C
      DO 60 IK = NBP,1,-1
        IF (ZR(IPVN+NBP+IK-1).NE.0.D0) THEN
          X2 = ZR(IPVN+IK-1)
          N2 = IK
          GO TO 61
        ENDIF
  60  CONTINUE
  61  CONTINUE
C
C --- 5.2.CREATION D UN PROFIL DE VITESSE NORMALISE POUR
C ---     LE CALCUL DES LONGUEURS DE CORRELATION GENERALISEES
C
      CALL WKVECT('&&SPECT1.TEMP.VITN','V V R',NBP*2,IVITN)
      DO 70 I = N1,N2
         ZR(IVITN+I-1+NBP) = ZR(IPVN+I-1+NBP) / VMOYZI
  70  CONTINUE
      DO 71 I = 1,NBP
         ZR(IVITN+I-1    ) = ZR(IPVN+I-1    )
  71  CONTINUE
C
C --- 5.3.CREATION D UN VECTEUR DE TRAVAIL POUR STOCKER
C ---     LES LONGUEURS DE CORRELATION GENERALISEES
C
      DIM = (IMODF-IMODI)+1
      NBFONC = (DIM* (DIM+1))/2
      CALL WKVECT('&&SPECT1.TEMP.LC2','V V R',NBFONC,ILC2)
C
C --- 5.4 CREATION ET REMPLISSAGE DU VECTEUR DE TRAVAIL .DEFM ---
C     (DEFORMEE POUR CHAQUE MODE, EN CHAQUE NOEUD, DANS LA DIRECTION
C      CHOISIE PAR L'UTILISATEUR OU PRISE EN COMPTE DE TOUTES
C      LES DIRECTIONS)
C
      CALL WKVECT('&&SPECT1.TEMP.DEFM','V V R',NBP*NBM,IDEFM)
C
      CALL GETVTX (' ','TOUT_CMP',0,IARG,1,TOUT,NBVAL)
      IF ( TOUT.EQ.'NON') THEN
        NBCMP = 1
        DO 20 IDE = 1,3
          IF (DEPLA(IDE).EQ.NOMCMP) THEN
            IDEP = IDE
          ENDIF
  20    CONTINUE
      ELSE
        NBCMP=3
      ENDIF
C
      DO 105 ICMP=1,NBCMP
        NOMCHA(1:13)  = BASE(1:8)//'.C01.'
        NOMCHA(17:24) = '001.VALE'
        IF ( TOUT.EQ.'NON') THEN
          DO 40 IM = 1,NBM
            WRITE(NOMCHA(14:16),'(I3.3)') NUOR(IM)
            CALL JEVEUO(NOMCHA,'L',ICHA)
            DO 30 IP = 1,NBP
              ZR(IDEFM+NBP*(IM-1)+IP-1) = ZR(ICHA+6*(IP-1)+IDEP-1)
  30        CONTINUE
            CALL JELIBE(NOMCHA)
  40      CONTINUE
        ELSE
          DO 45 IM = 1,NBM
            WRITE(NOMCHA(14:16),'(I3.3)') NUOR(IM)
            CALL JEVEUO(NOMCHA,'L',ICHA)
            DO 35 IP = 1,NBP
              ZR(IDEFM+NBP*(IM-1)+IP-1) = ZR(ICHA+6*(IP-1)+ICMP-1)
  35        CONTINUE
            CALL JELIBE(NOMCHA)
  45      CONTINUE
        ENDIF

        DO 90 JM = IMODI,IMODF
          IDEB = JM
          IF (CASINT) IDEB = IMODI
          DO 80 IM = IDEB,JM
            JMB = JM - IMODI + 1
            IMB = IM - IMODI + 1
            KK = (JMB* (JMB-1))/2 + IMB
            ZR(ILC2+KK-1) = ZR(ILC2+KK-1)+SPECT2(X1,X2,XLC,ZR(IVITN),
     &                           ZR(IRHOE),ZR(IDEFM),SPECT4,TOL,IER,
     &                           R1,ERR,NBP,IM,JM)
C
            IF (IER.NE.0) THEN
              VALI(1)=NUOR(JM)
              VALI(2)=NUOR(IM)
              VALX(1)=ZR(ILC2+KK-1)
              VALX(2)=R1
              VALX(3)=ERR
              CALL U2MESG('A','MODELISA7_7',0,' ',2,VALI,3,VALX)
            END IF
   80     CONTINUE
   90   CONTINUE
  105 CONTINUE
C
C
C --- 6.CALCUL DES INTERSPECTRES D'EXCITATIONS MODALES ---
C
C --- 6.1.CREATION D UN VECTEUR DE TRAVAIL POUR STOCKER
C ---     LES VALEURS DU SPECTRE
C
      CALL WKVECT('&&SPECT1.TEMP.SWR ','V V R',NBPF,LWR)
C
C --- 6.2.BOUCLE POUR CHAQUE VITESSE
C
      DO 180 IV = 1,NPV
      VITEZI = VITE(IV)*VMOYZI/VMOYTO
C
C --- 6.2.1.RECUPERATION DE LA DISCRETISATION FREQUENTIELLE
C     (NBPF PREMIERES VALEURS DE L'OBJET .VALE DE LA PREMIERE
C      FONCTION DE LA TABLE)
C
        WRITE(NOMFON,'(A8,A2,3I3.3)') NOMU,'.S',IV,NUOR(IMODI),
     &                                NUOR(IMODI)
        VALE = NOMFON//'.VALE'
        CALL JEVEUO(VALE,'L',IVALE)
C
C --- 6.2.2.CALCUL DES VALEURS DU SPECTRE
C
        IF (ISPECT.EQ.1) THEN
C
          XNU = ZR(IRSP+1)
          REN = (VITEZI*PHIE)/XNU
          REN = DBLE(ABS(REN))
C
          CALL COESP1(REN,PHI0,EPS,FRC,BETA)
C
          DO 100 IFRE = 1,NBPF
            FR = ZR(IVALE+IFRE-1)
            FR = (FR*PHIE)/VITEZI
            FR = DBLE(ABS(FR))
            SX = (FR/FRC)** (BETA/2.D0)
            SX = (1.D0-SX)* (1.D0-SX) + 4.D0*EPS*EPS*SX
            ZR(LWR+IFRE-1) = PHI0/SX
  100     CONTINUE
C
        ELSE IF (ISPECT.EQ.2) THEN
C
          FRC  = ZR(IRSP+1)
          PHI0 = ZR(IRSP+2)
          BETA = ZR(IRSP+3)
C
          DO 110 IFRE = 1,NBPF
            FR = ZR(IVALE+IFRE-1)
            FR = (FR*PHIE)/VITEZI
            FR = DBLE(ABS(FR))
            SX = PHI0/ (1.D0+ (FR/FRC)**BETA)
            ZR(LWR+IFRE-1) = SX
 110      CONTINUE
C
        ELSE IF (ISPECT.EQ.3) THEN
C
          DO 120 IFRE = 1,NBPF
            FR = ZR(IVALE+IFRE-1)
            FR = (FR*PHIE)/VITEZI
            FR = DBLE(ABS(FR))
C
            FRC    = ZR(IRSP+1)
            PHI01 = ZR(IRSP+2)
            BETA1 = ZR(IRSP+3)
            PHI02 = ZR(IRSP+4)
            BETA2 = ZR(IRSP+5)
C
            IF (FR.LE.FRC) THEN
              PHI0 = PHI01
              BETA = BETA1
            ELSE
              PHI0 = PHI02
              BETA = BETA2
            END IF
C
            SX = PHI0/ (FR**BETA)
            ZR(LWR+IFRE-1) = SX
 120      CONTINUE
C
        ELSE IF (ISPECT.EQ.4) THEN
C
          ROM = 0.D0
          IC  = 0
          DO 130 II = 1,NBP
            IF (ZR(IPVN+NBP+II-1).NE.0.D0) THEN
              ROM = ROM + ZR(IRHOE+NBP+II-1)
              IC = IC + 1
            END IF
 130      CONTINUE
C
          ROM = ROM/DBLE(IC)
          ROV = ROM*VITEZI
          ROV = DBLE(ABS(ROV))
          TAUXV = ZR(IRSP+1)
          BETA  = ZR(IRSP+2)
          GAMMA = ZR(IRSP+3)
C
          CALL COESP4(TAUXV,PHI0)
C
          DO 140 IFRE = 1,NBPF
            FR = ZR(IVALE+IFRE-1)
            FR = (FR*PHIE)/VITEZI
            FR = DBLE(ABS(FR))
            SX = PHI0/ ((FR**BETA)* (ROV**GAMMA))
            ZR(LWR+IFRE-1) = SX
 140      CONTINUE
C
        END IF
C
        CALL JELIBE(VALE)
C
C --- 6.2.3.CALCUL DES INTERSPECTRES
C
        DO 170 IM2 = IMODI,IMODF
          IDEB = IM2
          IF (CASINT) IDEB = IMODI
          DO 160 IM1 = IDEB,IM2
            WRITE (NOMFON,'(A8,A2,3I3.3)') NOMU,'.S',IV,NUOR(IM1),
     &                                     NUOR(IM2)
            VALE = NOMFON(1:19)//'.VALE'
            CALL JEVEUO(VALE,'E',IVALE)
C
            IM2B = IM2 - IMODI + 1
            IM1B = IM1 - IMODI + 1
            KK = IM2B* (IM2B-1)/2 + IM1B
C
            DO 150 IL = 1,NBPF
              ZR(IVALE+NBPF+2* (IL-1)) = ZR(IVALE+NBPF+2* (IL-1)) +
     &                                   0.25D0*PHIE*PHIE*PHIE*VITEZI*
     &                                   VITEZI*DBLE(ABS(VITEZI))*
     &                                   ZR(ILC2+KK-1)*ZR(LWR+IL-1)
              ZR(IVALE+NBPF+2* (IL-1)+1) = 0.D0
 150        CONTINUE
            CALL JELIBE(VALE)
 160      CONTINUE
 170    CONTINUE
 180  CONTINUE
C
      CALL JEDETR('&&SPECT1.TEMP.DEFM')
      CALL JEDETR('&&SPECT1.TEMP.VITN')
      CALL JEDETR('&&SPECT1.TEMP.LC2' )
      CALL JEDETR('&&SPECT1.TEMP.SWR ')
C
      CALL JEDEMA()
      END
