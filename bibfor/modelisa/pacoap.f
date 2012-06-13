      SUBROUTINE PACOAP(LISI1Z,LISI2Z,LONLIS,CENTRE,THETA,T,NOMAZ,
     &                  LISO1Z,LISO2Z)
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      INTEGER       LONLIS
      CHARACTER*(*) LISI1Z, LISI2Z, NOMAZ, LISO1Z, LISO2Z
      REAL*8        CENTRE(3), THETA(3), T(3)
C---------------------------------------------------------------------
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
C---------------------------------------------------------------------
C     BUT: TRIER 2 LISTES DE NOEUDS LISI1Z ET LISI2Z DE MANIERE A
C     METTRE EN VIS A VIS LES NOEUDS DES 2 LISTES VIA
C     LA TRANSFORMATION  OM.THETA+T.
C     LES LISTES TRIEES OBTENUES A PARTIR DE LISI1Z ET LISI2Z
C     SONT RESPECTIVEMENT LISO1Z ET LISO2Z, LA CORRESPONDANCE
C     ENTRE LES NOEUDS DES 2 LISTES EST ASSUREE DE LA MANIERE
C     SUIVANTE :
C          POUR I =1, LONLIS
C          LISO1Z(I) EST EN VIS-AVIS AVEC LISO2Z(I)
C
C     LES LISTES LISI1Z, LISI2Z, LISO1Z ET LISO2Z CONTIENNENT
C     LES NOMS DES NOEUDS (CE SONT DES LISTES DE K8).
C
C---------------------------------------------------------------------
C ARGUMENTS D'ENTREE:
C IN   LISI1Z     K24 : NOM DE LA 1ERE LISTE
C IN   LISI2Z     K24 : NOM DE LA 2EME LISTE
C IN   LONLIS     I   : LONGUEUR COMMUNE DE CES 2 LISTES
C IN   CENTRE(3)  R   : COORDONNEES DU CENTRE DE ROTATION
C IN   THETA(3)   R   : ANGLES DE ROTATION
C IN   T(3)       R   : COORDONNEES DE LA TRANSLATION
C IN   NOMAZ      K8  : NOM DU MAILLAGE
C OUT  LISO1Z     K24 : NOM DE LA 1ERE LISTE TRIEE
C OUT  LISO2Z     K24 : NOM DE LA 2EME LISTE TRIEE
C
C
      INTEGER       I, I1, I2, IAGEOM, IDLIN1, IDLIN2,IDLINV
      INTEGER       IDLOU1, IDLOU2, IDLOU3, IDLOU4, IER, IEXCOR, IRET
      INTEGER       INO1, INO2, J, J1, J2, JNULI1, JNULI2, K
      INTEGER       NUNO1, NUNO2

      REAL*8        D, DMIN
      REAL*8        R8DGRD, R8GAEM, PADIST
      REAL*8        MROT(3,3), X1(3), X2(3)

      CHARACTER*8   NOMA, M8BLAN
      CHARACTER*8   NOMNO1, NOMNO2, NOMO1, NOMO2
      CHARACTER*24  LISIN1, LISIN2, LISOU1, LISOU2
      CHARACTER*24  VALK(5)
      CHARACTER*24  NOEUMA
C
C --- DEBUT
C
      CALL JEMARQ()
      LISIN1 = LISI1Z
      LISIN2 = LISI2Z
      LISOU1 = LISO1Z
      LISOU2 = LISO2Z
      NOMA   = NOMAZ
      IER = 0
C
      NOEUMA = NOMA//'.NOMNOE'
      M8BLAN = '        '
      CALL JEVEUO(NOMA//'.COORDO    .VALE','L',IAGEOM)
C
C --- CONSTITUTION DE LA MATRICE DE ROTATION
C
      THETA(1) = THETA(1)*R8DGRD()
      THETA(2) = THETA(2)*R8DGRD()
      THETA(3) = THETA(3)*R8DGRD()
C
      CALL MATROT ( THETA , MROT )
C
C --- CREATION SUR LA VOLATILE DES LISTES DE K8 LISOU1 ET LISOU2
C --- DE LONGUEUR LONLIS
C
      CALL JEEXIN(LISOU1, IRET)
      IF (IRET.NE.0) THEN
          CALL JEDETR(LISOU1)
      ENDIF
      CALL JEEXIN(LISOU2, IRET)
      IF (IRET.NE.0) THEN
          CALL JEDETR(LISOU2)
      ENDIF
      CALL WKVECT(LISOU1,'V V K8',LONLIS,IDLOU1)
      CALL WKVECT(LISOU2,'V V K8',LONLIS,IDLOU2)
C
      CALL JEVEUO(LISIN1,'L',IDLIN1)
      CALL JEVEUO(LISIN2,'L',IDLIN2)
C
C --- VECTEURS DE TRAVAIL
C
      CALL WKVECT('&&PACOAP.LISOU3','V V K8',LONLIS,IDLOU3)
      CALL WKVECT('&&PACOAP.LISOU4','V V K8',LONLIS,IDLOU4)
      CALL WKVECT('&&PACOAP.LISINV','V V K8',LONLIS,IDLINV)
C
C     -- ON FABRIQUE UN OBJET QUI CONTIENDRA LES NUMEROS
C     -- DES NOEUDS DE LISIN1 ET LISIN2 :
      CALL WKVECT('&&PACOAP.NUM_LISIN1','V V I',LONLIS,JNULI1)
      CALL WKVECT('&&PACOAP.NUM_LISIN2','V V I',LONLIS,JNULI2)
      DO 1,K=1,LONLIS
        CALL JENONU(JEXNOM(NOEUMA,ZK8(IDLIN1-1+K)),ZI(JNULI1-1+K))
        CALL JENONU(JEXNOM(NOEUMA,ZK8(IDLIN2-1+K)),ZI(JNULI2-1+K))
 1    CONTINUE
C
C --- CONSTITUTION DE LA PREMIERE CORRESPONDANCE ENTRE LES LISTES
C --- DE NOEUDS LISIN1 ET LISIN2 ENTRE NO1 DONNE ET NO2 SELON LE
C --- CRITERE : NO2 = NO DANS LISIN2 / D(NO1,NO2) = MIN D(NO1,NO)
C
      DO 10 I1 = 1, LONLIS
        NOMNO1 = ZK8(IDLIN1+I1-1)
C       CALL JENONU(JEXNOM(NOEUMA,NOMNO1),NUNO1)
        NUNO1=ZI(JNULI1-1+I1)
        CALL PAROTR(NOMA,IAGEOM,NUNO1,0,CENTRE,MROT,T,X1)
        DMIN = R8GAEM()
        J2 = 0
        DO 20 I2 = 1, LONLIS
          NOMO2 = ZK8(IDLIN2+I2-1)
C         CALL JENONU(JEXNOM(NOEUMA,NOMO2),INO2)
          INO2=ZI(JNULI2-1+I2)
C         CALL PACOOR(NOMA,INO2,0,X2)
          X2(1)=ZR(IAGEOM-1+3*(INO2-1)+1)
          X2(2)=ZR(IAGEOM-1+3*(INO2-1)+2)
          X2(3)=ZR(IAGEOM-1+3*(INO2-1)+3)
          D = PADIST( 3, X1, X2 )
          IF (D.LT.DMIN) THEN
            DMIN   = D
            NOMNO2 = NOMO2
            NUNO2  = INO2
            J2     = I2
          ENDIF
20      CONTINUE
C
        IF (J2.EQ.0) CALL U2MESK('F','MODELISA6_3',1,NOMNO1)
C
        IF (ZK8(IDLINV+J2-1).EQ.M8BLAN) THEN
            ZK8(IDLOU1+I1-1) = NOMNO1
            ZK8(IDLOU2+I1-1) = NOMNO2
            ZK8(IDLINV+J2-1) = NOMNO1
        ELSE
            IER = IER + 1
           VALK (1) = NOMNO2
           VALK (2) = NOMNO1
           VALK (3) = ZK8(IDLINV+J2-1)
            CALL U2MESG('E', 'MODELISA8_77',3,VALK,0,0,0,0.D0)
        ENDIF
C
10    CONTINUE
C
      IF ( IER .NE. 0 ) THEN
         CALL U2MESS('F','MODELISA6_4')
      ENDIF
C
      DO 30 I = 1, LONLIS
         ZK8(IDLINV+I-1) = M8BLAN
30    CONTINUE
C
C --- CONSTITUTION DE LA SECONDE CORRESPONDANCE ENTRE LES LISTES
C --- DE NOEUDS LISIN1 ET LISIN2 ENTRE NO2 DONNE ET NO1 SELON LE
C --- CRITERE : NO1 = NO DANS LISIN1 / D(NO1,NO2) = MIN D(NO,NO2)
C --- LA CORRESPONDANCE EST DEFINIE PAR LA CONSTITUTION DES LISTES
C --- LISOU3 ET LISOU4.
C
      DO 40 I2 = 1, LONLIS
        NOMNO2 = ZK8(IDLIN2+I2-1)
        NUNO2=ZI(JNULI2-1+I2)
        X2(1)=ZR(IAGEOM-1+3*(NUNO2-1)+1)
        X2(2)=ZR(IAGEOM-1+3*(NUNO2-1)+2)
        X2(3)=ZR(IAGEOM-1+3*(NUNO2-1)+3)
        DMIN = R8GAEM()
        J1 = 0
        DO 50 I1 = 1, LONLIS
          NOMO1 = ZK8(IDLIN1+I1-1)
          INO1=ZI(JNULI1-1+I1)
          CALL PAROTR(NOMA,IAGEOM,INO1,0,CENTRE,MROT,T,X1)
          D = PADIST( 3, X1, X2 )
          IF (D.LT.DMIN) THEN
            DMIN   = D
            NOMNO1 = NOMO1
            NUNO1  = INO1
            J1     = I1
          ENDIF
50      CONTINUE
C
        IF (J1.EQ.0) CALL U2MESK('F','MODELISA6_3',1,NOMNO2)
C
        IF (ZK8(IDLINV+J1-1).EQ.M8BLAN) THEN
            ZK8(IDLOU3+I2-1) = NOMNO1
            ZK8(IDLOU4+I2-1) = NOMNO2
            ZK8(IDLINV+J1-1) = NOMNO2
        ELSE
            IER = IER + 1
           VALK (1) = NOMNO1
           VALK (2) = NOMNO2
           VALK (3) = ZK8(IDLINV+J1-1)
            CALL U2MESG('E', 'MODELISA8_77',3,VALK,0,0,0,0.D0)
        ENDIF
C
40    CONTINUE
C
      IF ( IER .NE. 0 ) THEN
         CALL U2MESS('F','MODELISA6_4')
      ENDIF
C
C --- VERIFICATION DE LA COHERENCE DES COUPLES FORMES D'UNE PART
C --- PAR LISOU1 ET LISOU2 ET D'AUTRE-PART DES COUPLES 'INVERSES'
C --- FORMES PAR LISOU3 ET LISOU4
C
      DO 60 I = 1, LONLIS
        IEXCOR = 0
        DO 70 J = 1, LONLIS
           IF(ZK8(IDLOU1+I-1).EQ.ZK8(IDLOU3+J-1)) THEN
              IEXCOR = 1
              IF(ZK8(IDLOU2+I-1).NE.ZK8(IDLOU4+J-1)) THEN
                 IER = IER + 1
           VALK (1) = LISIN1
           VALK (2) = LISIN2
           VALK (3) = ZK8(IDLOU1+I-1)
           VALK (4) = ZK8(IDLOU2+I-1)
           VALK (5) = ZK8(IDLOU4+J-1)
                 CALL U2MESG('E', 'MODELISA8_87',5,VALK,0,0,0,0.D0)
              ENDIF
           ENDIF
70      CONTINUE
C
        IF (IEXCOR.EQ.0) THEN
           IER = IER + 1
           VALK (1) = LISIN1
           VALK (2) = LISIN2
           VALK (3) = ZK8(IDLOU1+I-1)
           VALK (4) = ' '
           VALK (5) = ' '
           CALL U2MESG('E', 'MODELISA8_88',5,VALK,0,0,0,0.D0)
        ENDIF
C
60    CONTINUE
C
      IF ( IER .NE. 0 ) THEN
         CALL U2MESS('F','MODELISA6_4')
      ENDIF
C
C --- MENAGE
C
      CALL JEDETR ('&&PACOAP.LISOU3')
      CALL JEDETR ('&&PACOAP.LISOU4')
      CALL JEDETR ('&&PACOAP.LISINV')
      CALL JEDETR ('&&PACOAP.NUM_LISIN1')
      CALL JEDETR ('&&PACOAP.NUM_LISIN2')
C
      CALL JEDEMA()
      END
