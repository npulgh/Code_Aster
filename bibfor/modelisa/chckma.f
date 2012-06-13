      SUBROUTINE CHCKMA (NOMU,CMD,DTOL)
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
C-----------------------------------------------------------------------
      IMPLICIT NONE
C-----------------------------------------------------------------------
C
C       ROUTINE DE VERIFICATION DU MAILLAGE :
C       1- RECHERCHE (ET ELIMINATION SI DEMANDEE) DES NOEUDS ORPHELINS
C       2- RECHERCHE (ET ELIMINATION SI DEMANDEE) DES MAILLES DOUBLES
C       3- RECHERCHE DES MAILLES APLATIES
C
C       IN,OUT : NOMU   NOM DU CONCEPT MAILLAGE PRODUIT PAR LA COMMANDE
C       IN     : CMD    NOM DE LA COMMANDE
C       IN     : DTOL   TOLERANCE POUR TESTER L APPLATISST DES MAILLES
C
C-----------------------------------------------------------------------
C
      INCLUDE 'jeveux.h'
      CHARACTER*8     NOMU
      CHARACTER*16    CMD
      REAL*8          DTOL
C
C
C ----- DECLARATIONS
C
      INTEGER         IACONX,ILCONX,IMA,NBNM,NBNM2,IT,JCOOR,IFM,NIV
      INTEGER         JDRVLC,JCNCIN,NUMAIL,IMAIL
      INTEGER         IADR,IADR0,NBM,NBM0,IADTYP,NB200
      INTEGER         JA,JB,TABMA(200),I,J,K1,K2,KNSO,KMDB,L,IRET
      CHARACTER*8     NOXA,NOXB,K8B,TYMA
      CHARACTER*24    NCNCIN
      REAL*8          DM,DP,APLAT,DRAP,R8MAEM,R8MIEM
      REAL*8          XA,XB,YA,YB,ZA,ZB
      CHARACTER*24    COOVAL,CONNEX,NOMMAI,NOMNOE,NSOLO,MDOUBL
      INTEGER         NBMAIL , NBNOEU
      INTEGER         INSOLO , IMDOUB, IATYMA, NMDOUB
      LOGICAL         INDIC  , ALARME  , ERREUR
C
      CALL JEMARQ ( )
      CALL INFNIV(IFM,NIV)
C
      NOMMAI  = NOMU// '.NOMMAI         '
      NOMNOE  = NOMU// '.NOMNOE         '
      COOVAL  = NOMU// '.COORDO    .VALE'
      CONNEX  = NOMU// '.CONNEX         '
      CALL DISMOI('F','NB_MA_MAILLA',NOMU,'MAILLAGE',NBMAIL,K8B,IRET)
      CALL DISMOI('F','NB_NO_MAILLA',NOMU,'MAILLAGE',NBNOEU,K8B,IRET)
      CALL JEVEUO(NOMU//'.TYPMAIL','L',IATYMA)
C
      CALL JEVEUO(CONNEX,'L',IACONX)
      CALL JEVEUO(JEXATR(CONNEX,'LONCUM'),'L',ILCONX)
      CALL JEVEUO(COOVAL,'L',JCOOR)
C
      NCNCIN = '&&CHCKMA.CONNECINVERSE  '
      CALL CNCINV(NOMU,0,0, 'V', NCNCIN )
      CALL JEVEUO(JEXATR(NCNCIN,'LONCUM'),'L',JDRVLC)
      CALL JEVEUO(JEXNUM(NCNCIN,1)       ,'L',JCNCIN)




C
C     -----------------------------------------------------------
C     RECHERCHE DES NOEUDS ORPHELINS (ATTACHES A AUCUNE MAILLE)
C     A PARTIR DE LA CONNECTIVITE INVERSE RENVOYEE PAR CNCINV
C     -----------------------------------------------------------
      NSOLO='&&CHCKMA.NSOLO          '
      CALL WKVECT(NSOLO,'V V I',NBNOEU,INSOLO)
C
      IT=0
      KNSO=0
      ALARME = .FALSE.
      NB200=0
      WRITE(IFM,*) ' ====== VERIFICATION DU MAILLAGE ======'
      WRITE(IFM,*)
      DO 10 JA=1,NBNOEU
         IADR = ZI(JDRVLC + JA-1)
         NBM  = ZI(JDRVLC + JA+1-1) -
     &          ZI(JDRVLC + JA-1)
         IF (NBM.GT.200) THEN
           NB200=1
           CALL JENUNO(JEXNUM(NOMNOE,JA),NOXA)
           WRITE(IFM,*) 'NOEUD CONNECTANT PLUS DE 200 MAILLES: ',NOXA
         END IF
         DO 11 IMAIL = 1, NBM
            NUMAIL = ZI(JCNCIN+IADR-1+IMAIL-1)
            IF (NUMAIL.EQ.0) THEN
              KNSO=KNSO+1
              ZI(INSOLO-1+KNSO)= JA
              CALL JENUNO(JEXNUM(NOMNOE,JA),NOXA)
              WRITE(IFM,*) ' LE NOEUD  '//NOXA//' EST ORPHELIN'
              ALARME=.TRUE.
            ENDIF
  11     CONTINUE
 10   CONTINUE
      IF (ALARME) THEN
         CALL U2MESS('A','MODELISA4_6')
      ENDIF
      IF (NB200.EQ.1) THEN
         CALL U2MESS('A','MODELISA4_7')
      ENDIF

C
C     -----------------------------------------------------------
C     RECHERCHE DES MAILLES DOUBLES : C EST A DIRE LES MAILLES
C     DE NUMEROS DIFFERENTS QUI ONT LES MEMES NOEUDS EN SUPPORT :
C     POUR CHAQUE PREMIER NOEUD DE CHAQUE MAILLE, ON
C     REGARDE LES AUTRES MAILLES POSSEDANT CE NOEUD DANS LA
C     CONNECTIVITE INVERSE : LES CANDIDATS AU DOUBLON Y SONT
C     FORCEMMENT. CA EVITE UN ALGO EN N2.
C     -----------------------------------------------------------
C
      MDOUBL='&&CHCKMA.MDOUBLE'
      NMDOUB=NBMAIL
      CALL WKVECT(MDOUBL,'V V I',NMDOUB,IMDOUB)
C
C     BOUCLE SUR TOUTES LES MAILLES DU MAILLAGE
C
      IT=0
      KMDB=0
      ALARME = .FALSE.
      ERREUR = .FALSE.
      DO 100 IMA=1,NBMAIL
        NBNM  = ZI(ILCONX-1+IMA+1)-ZI(ILCONX+IMA-1)
        IADR0 = ZI(JDRVLC + ZI(IACONX+1+IT-1)-1)
        NBM0  = ZI(JDRVLC + ZI(IACONX+1+IT-1)+1-1) -
     &          ZI(JDRVLC + ZI(IACONX+1+IT-1)-1)
        I=1
        DO 101 JA=1,NBM0
          IF (ZI(JCNCIN+IADR0-1+JA-1).NE.IMA) THEN
            TABMA(I)=ZI(JCNCIN+IADR0-1+JA-1)
            I=I+1
          ENDIF
C         -- POUR NE PAS DEBORDER DE  TABMA :
          IF (I.GT.199) GOTO 99
 101    CONTINUE
C
C     SI NBM0 DIFFERENT DE I : UN NOEUD DE LA MAILLE EST PRESENT
C     PLUSIEURS FOIS DANS LA CONNECTIVITE DE CELLE CI
        IF (NBM0.NE.I) THEN
            ERREUR=.TRUE.
            CALL JENUNO(JEXNUM(NOMMAI,IMA),NOXA)
            IADTYP=IATYMA-1+IMA
            CALL JENUNO(JEXNUM('&CATA.TM.NOMTM',ZI(IADTYP)),TYMA)
            WRITE(IFM,*)
            WRITE(IFM,*) ' LA MAILLE ',NOXA,'EST TOPOLOGIQUEMENT '//
     &          'DEGENEREE : NOEUD REPETE DANS LA CONNECTIVITE'
            WRITE(IFM,*) ' TYPE DE LA MAILLE: ',TYMA
         ENDIF
        NBM0 = I
C
C     TABMA CONTIENT LA LISTE DES MAILLES (HORS IMA) QUI
C     CONTIENNENT LE PREMIER NOEUD DE IMA
C
        IF (NBNM.GT.1) THEN
          DO 102 I=1,NBM0-1
            NBNM2  = ZI(ILCONX-1+TABMA(I)+1)-ZI(ILCONX+TABMA(I)-1)
C
C     COMPARAISON DES NOEUDS DE IMA AVEC CEUX DES MAILLES DE TABMA
C     SI LES CARDINAUX SONT DEJA DIFFERENTS (NBNM) : ON SAUTE
C
            IF ((NBNM2.EQ.NBNM).AND.(TABMA(I).LT.IMA)) THEN
              DO 103 J=1,NBNM2
                 K1=ZI(IACONX-1+ZI(ILCONX+TABMA(I)-1)+J-1)
                 INDIC=.FALSE.
                 DO 104 L=1,NBNM
                    K2=ZI(IACONX-1+ZI(ILCONX+IMA-1)+L-1)
                    IF (K1.EQ.K2) INDIC=.TRUE.
 104             CONTINUE
                 IF (.NOT.INDIC) GOTO 102
 103          CONTINUE
              KMDB=KMDB+1
              IF (KMDB.GT.NMDOUB) THEN
                 NMDOUB=2*NMDOUB
                 CALL JUVECA(MDOUBL,NMDOUB)
              END IF
              CALL JEVEUO(MDOUBL,'E',IMDOUB)
              ZI(IMDOUB-1+KMDB)= TABMA(I)
              CALL JENUNO(JEXNUM(NOMMAI,IMA),NOXA)
              CALL JENUNO(JEXNUM(NOMMAI,TABMA(I)),NOXB)
              IADTYP=IATYMA-1+IMA
              CALL JENUNO(JEXNUM('&CATA.TM.NOMTM',ZI(IADTYP)),TYMA)
              WRITE(IFM,*) ' LES MAILLES '//NOXA//' ET '//NOXB//' '
     &      //' SONT DOUBLES (MEME NOEUDS EN SUPPORT)'
              WRITE(IFM,*) ' TYPE DES MAILLES:',TYMA
              ALARME=.TRUE.
            ENDIF
C
 102      CONTINUE
C
        ELSE IF (NBM0.GT.1) THEN
          CALL JENUNO(JEXNUM(NOMMAI,IMA),NOXA)
          WRITE(IFM,*) ' MAILLE POI1 '//NOXA//'INCLUSE DANS UNE AUTRE'
        ENDIF
C
 99     CONTINUE
        IT=IT+NBNM
 100  CONTINUE
      IF (ALARME) THEN
         CALL U2MESS('A','MODELISA4_8')
      ENDIF
C
C     -----------------------------------------------------------
C     CALCUL POUR CHAQUE MAILLE DU RAPPORT MINIMUM ENTRE LA PLUS
C     PETITE ARRETE ET LA PLUS GRANDE POUR REPERER LES ELEMENTS
C     TRES APLATIS VOIRE DEGENERES. LE RAPPORT MIN TOLERE EST :
C     DTOL = 1 POURCENT
C     -----------------------------------------------------------
C
      IT=0
      ALARME = .FALSE.
      DO 200 IMA=1,NBMAIL
        NBNM   = ZI(ILCONX-1+IMA+1)-ZI(ILCONX+IMA-1)
        DM=R8MAEM()
        DP=R8MIEM()
        IF(NBNM.GT.1) THEN
C
          DO 210 JA=1,NBNM-1
            DO 220 JB=JA+1,NBNM
              XA=ZR(JCOOR-1+3*(ZI(IACONX+JA+IT-1)-1)+1)
              YA=ZR(JCOOR-1+3*(ZI(IACONX+JA+IT-1)-1)+2)
              ZA=ZR(JCOOR-1+3*(ZI(IACONX+JA+IT-1)-1)+3)
              XB=ZR(JCOOR-1+3*(ZI(IACONX+JB+IT-1)-1)+1)
              YB=ZR(JCOOR-1+3*(ZI(IACONX+JB+IT-1)-1)+2)
              ZB=ZR(JCOOR-1+3*(ZI(IACONX+JB+IT-1)-1)+3)
              APLAT = (XA-XB)**2 + (YA-YB)**2 + (ZA-ZB)**2
              IF (APLAT.LT.DM) DM=APLAT
              IF (APLAT.GT.DP) DP=APLAT
 220        CONTINUE
 210      CONTINUE
          IF(DP.GT.0.D0) THEN
            DRAP=SQRT(DM/DP)
            IF(DRAP.LT.DTOL) THEN
              ALARME=.TRUE.
              CALL JENUNO(JEXNUM(NOMMAI,IMA),NOXA)
              IADTYP=IATYMA-1+IMA
              CALL JENUNO(JEXNUM('&CATA.TM.NOMTM',ZI(IADTYP)),TYMA)
              WRITE(IFM,*)
              WRITE(IFM,*) ' LA MAILLE POSSEDE DES NOEUDS CONFONDUS',
     &            ' GEOMETRIQUEMENT '
              WRITE(IFM,*) ' MAILLE:',NOXA,' DM/DP=',DRAP,
     &            ' TYPE:',TYMA
              ENDIF
            ENDIF
C
        ENDIF
        IT=IT+NBNM
 200  CONTINUE
      IF (ALARME) THEN
         CALL U2MESS('A','MODELISA4_9')
      ENDIF
C     ON ARRETE EN ERREUR SUR MAILLE DEGENEREE
      IF (ERREUR) THEN
         CALL U2MESS('F','MODELISA4_10')
      ENDIF
C
C     -----------------------------------------------------------
C     MENAGE DANS LE MAILLAGE : ON DETRUIT NOEUDS ORPHELINS ET
C                               MAILLES DOUBLES
C     -----------------------------------------------------------
C
C     CA RESTE A FAIRE ...
C     LES NOEUDS ORPHELINS SONT RANGES DANS &&CHCKMA.NSOLO(1:KNSO)
C     LES MAILLES DOUBLES SONT RANGEES DANS &&CHCKMA.MDOUBLE(1:KMDB)
C
      CALL JEDETR('&&CHCKMA.NSOLO          ')
      CALL JEDETR('&&CHCKMA.MDOUBLE')
      CALL JEDETR('&&CHCKMA.CONNECINVERSE  ')
      CALL JEDEMA ( )
      END
