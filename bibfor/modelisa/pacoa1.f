      SUBROUTINE PACOA1 ( NOEUD1, NOEUD2, LONLIS, NOMAZ,
     &                            LISO1Z, LISO2Z )
      IMPLICIT   NONE
      INCLUDE 'jeveux.h'

      CHARACTER*32 JEXNUM,JEXNOM
      INTEGER           LONLIS, NOEUD1(*), NOEUD2(*)
      CHARACTER*(*)     NOMAZ, LISO1Z, LISO2Z
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 18/12/2012   AUTEUR SELLENET N.SELLENET 
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
C     BUT: TRIER 2 LISTES DE NOEUDS NOEUD1 ET LISI2Z DE MANIERE A
C     METTRE EN VIS A VIS LES NOEUDS DES 2 LISTES
C     LES LISTES TRIEES OBTENUES A PARTIR DE NOEUD1 ET LISI2Z
C     SONT RESPECTIVEMENT LISO1Z ET LISO2Z, LA CORRESPONDANCE
C     ENTRE LES NOEUDS DES 2 LISTES EST ASSUREE DE LA MANIERE
C     SUIVANTE :
C          POUR I =1, LONLIS
C          LISO1Z(I) EST EN VIS-AVIS AVEC LISO2Z(I)
C
C     LES LISTES NOEUD1, LISI2Z, LISO1Z ET LISO2Z CONTIENNENT
C     LES NUMEROS DES NOEUDS (CE SONT DES LISTES DE I).
C
C     ROUTINE INSPIREE DE  PACOAP
C
C-----------------------------------------------------------------------
C ARGUMENTS D'ENTREE:
C IN   NOEUD1     I   : 1ERE LISTE DES NUMEROS DE NOEUDS
C IN   LISI2Z     I   : 2EME LISTE DES NUMEROS DE NOEUDS
C IN   LONLIS     I   : LONGUEUR COMMUNE DE CES 2 LISTES
C IN   NOMAZ      K8  : NOM DU MAILLAGE
C OUT  LISO1Z     K24 : NOM DE LA 1ERE LISTE TRIEE
C OUT  LISO2Z     K24 : NOM DE LA 2EME LISTE TRIEE
C
      INTEGER       IAGEOM, IRET, IDLOU1, IDLOU2, IDLOU3, IDLOU4,
     &              IDLINV, I1, I2, INO1, NUNO1, INO2, NUNO2, J1, J2,
     &              I, J, IEXCOR, TROUV1, TROUV2, JFAC1, JFAC2,
     &              JFOND,IM, NBFA, NBFO
      REAL*8        DMIN, D, R8GAEM, X1(3), X2(3), PADIST
      CHARACTER*8   NOMA, K8B
      CHARACTER*8   NOMNO1, NOMNO2, NOMNO3
      CHARACTER*24  LISOU1, LISOU2
      CHARACTER*24 VALK(3)
      CHARACTER*24  NOMNOE,GRPNOE
C     ------------------------------------------------------------------
C
      CALL JEMARQ()
      LISOU1 = LISO1Z
      LISOU2 = LISO2Z
      NOMA   = NOMAZ
C
      NOMNOE = NOMA//'.NOMNOE         '
      GRPNOE = NOMA//'.GROUPENO       '
      CALL JEVEUO ( NOMA//'.COORDO    .VALE', 'L', IAGEOM )
C
      CALL JEEXIN ( JEXNOM(GRPNOE,'FACE1'), IRET )
      IF (IRET.EQ.0) THEN
        NBFA = 0
        NBFO = 0
      ELSE
        CALL JEVEUO ( JEXNOM(GRPNOE,'FACE1'), 'L', JFAC1 )
        CALL JEVEUO ( JEXNOM(GRPNOE,'FACE2'), 'L', JFAC2 )
        CALL JELIRA ( JEXNOM(GRPNOE,'FACE2'),'LONUTI',NBFA,K8B)
        CALL JEVEUO ( JEXNOM(GRPNOE,'FONDFISS'), 'L', JFOND )
        CALL JELIRA ( JEXNOM(GRPNOE,'FONDFISS'),'LONUTI',NBFO,K8B)
      END IF
C
      CALL JEEXIN ( LISOU1 , IRET )
      IF ( IRET .NE. 0 ) CALL JEDETR ( LISOU1 )
      CALL JEEXIN ( LISOU2 , IRET )
      IF ( IRET .NE. 0 ) CALL JEDETR ( LISOU2 )
C
C --- CREATION SUR LA VOLATILE DES LISTES DE K8 LISOU1 ET LISOU2
C --- DE LONGUEUR LONLIS
C
      CALL WKVECT ( LISOU1, 'V V I', LONLIS, IDLOU1 )
      CALL WKVECT ( LISOU2, 'V V I', LONLIS, IDLOU2 )
C
C --- VECTEURS DE TRAVAIL
C
      CALL WKVECT ( '&&PACOA1.LISOU3', 'V V I', LONLIS, IDLOU3 )
      CALL WKVECT ( '&&PACOA1.LISOU4', 'V V I', LONLIS, IDLOU4 )
      CALL WKVECT ( '&&PACOA1.LISINV', 'V V I', LONLIS, IDLINV )
      DO 5 I1 = 1, LONLIS
         ZI(IDLINV+I1-1) = 0
 5    CONTINUE
C
C --- CONSTITUTION DE LA PREMIERE CORRESPONDANCE ENTRE LES LISTES
C --- DE NOEUDS NOEUD1 ET NOEUD2 ENTRE NO1 DONNE ET NO2 SELON LE
C --- CRITERE : NO2 = NO DANS NOEUD2 / D(NO1,NO2) = MIN D(NO1,NO)
C
      DO 10 I1 = 1 , LONLIS
        NUNO1  = NOEUD1(I1)
        X1(1)  = ZR(IAGEOM-1+3*(NUNO1-1)+1)
        X1(2)  = ZR(IAGEOM-1+3*(NUNO1-1)+2)
        X1(3)  = ZR(IAGEOM-1+3*(NUNO1-1)+3)
        DMIN   = R8GAEM()
        J2 = 0
C
        TROUV1 = 0
        DO 11 IM = 1 , NBFO
           IF ( ZI(JFOND+IM-1) .EQ. NUNO1 ) GOTO 13
11      CONTINUE
        DO 12 IM = 1 , NBFA
          IF ( ZI(JFAC1+ IM-1) .EQ. NUNO1 ) THEN
            TROUV1 = 1
            GOTO 13
          END IF
          IF ( ZI(JFAC2+ IM-1) .EQ. NUNO1 ) THEN
            TROUV1 = 2
            GOTO 13
          END IF
12      CONTINUE
C
13      CONTINUE
        DO 20 I2 = 1 , LONLIS
          INO2  = NOEUD2(I2)
          X2(1) = ZR(IAGEOM-1+3*(INO2-1)+1)
          X2(2) = ZR(IAGEOM-1+3*(INO2-1)+2)
          X2(3) = ZR(IAGEOM-1+3*(INO2-1)+3)
          D = PADIST( 3, X1, X2 )
C
          TROUV2 = 0
          DO 21 IM = 1 , NBFO
           IF ( ZI(JFOND+IM-1) .EQ. INO2 ) GOTO 23
21        CONTINUE
          DO 22 IM = 1 , NBFA
            IF ( ZI(JFAC1+ IM-1) .EQ. INO2 ) THEN
              TROUV2 = 1
              GOTO 23
            END IF
            IF ( ZI(JFAC2+ IM-1) .EQ. INO2 ) THEN
              TROUV2 = 2
              GOTO 23
            END IF
22        CONTINUE
C
23        CONTINUE
          IF (( D .LT. DMIN ).AND.(TROUV1.EQ.TROUV2)) THEN
            DMIN   = D
            NUNO2  = INO2
            J2     = I2
          ENDIF
20      CONTINUE
C
        IF (J2.EQ.0) CALL U2MESK('F','MODELISA6_3',1,NOMNO1)
C
        IF ( ZI(IDLINV+J2-1) .EQ. 0 ) THEN
            ZI(IDLOU1+I1-1) = NUNO1
            ZI(IDLOU2+I1-1) = NUNO2
            ZI(IDLINV+J2-1) = NUNO1
        ELSE
            CALL JENUNO ( JEXNUM(NOMNOE,NUNO1), NOMNO1)
            CALL JENUNO ( JEXNUM(NOMNOE,NUNO2), NOMNO2)
            CALL JENUNO ( JEXNUM(NOMNOE,ZI(IDLINV+J2-1)), NOMNO3)
           VALK (1) = NOMNO2
           VALK (2) = NOMNO1
           VALK (3) = NOMNO3
            CALL U2MESG('F', 'MODELISA8_77',3,VALK,0,0,0,0.D0)
        ENDIF
C
10    CONTINUE
C
      DO 30 I1 = 1, LONLIS
         ZI(IDLINV+I1-1) = 0
30    CONTINUE
C
C --- CONSTITUTION DE LA SECONDE CORRESPONDANCE ENTRE LES LISTES
C --- DE NOEUDS NOEUD1 ET NOEUD2 ENTRE NO2 DONNE ET NO1 SELON LE
C --- CRITERE : NO1 = NO DANS NOEUD1 / D(NO1,NO2) = MIN D(NO,NO2)
C --- LA CORRESPONDANCE EST DEFINIE PAR LA CONSTITUTION DES LISTES
C --- LISOU3 ET LISOU4.
C
      DO 40 I2 = 1, LONLIS
        NUNO2  = NOEUD2(I2)
        X2(1)  = ZR(IAGEOM-1+3*(NUNO2-1)+1)
        X2(2)  = ZR(IAGEOM-1+3*(NUNO2-1)+2)
        X2(3)  = ZR(IAGEOM-1+3*(NUNO2-1)+3)
        DMIN   = R8GAEM()
        J1 = 0
C
        TROUV2 = 0
        DO 41 IM = 1 , NBFO
           IF ( ZI(JFOND+IM-1) .EQ. NUNO2 ) GOTO 43
41      CONTINUE
        DO 42 IM = 1 , NBFA
           IF ( ZI(JFAC1+ IM-1) .EQ. NUNO2 ) THEN
             TROUV2 = 1
             GOTO 43
           END IF
           IF ( ZI(JFAC2+ IM-1) .EQ. NUNO2 ) THEN
             TROUV2 = 2
             GOTO 43
           END IF
42      CONTINUE
C
43      CONTINUE
        DO 50 I1 = 1, LONLIS
          INO1  = NOEUD1(I1)
          X1(1) = ZR(IAGEOM-1+3*(INO1-1)+1)
          X1(2) = ZR(IAGEOM-1+3*(INO1-1)+2)
          X1(3) = ZR(IAGEOM-1+3*(INO1-1)+3)
          D = PADIST( 3, X1, X2 )
C
          TROUV1 = 0
          DO 51 IM = 1 , NBFO
           IF ( ZI(JFOND+IM-1) .EQ. INO1 ) GOTO 53
51        CONTINUE
          DO 52 IM = 1 , NBFA
             IF ( ZI(JFAC1+ IM-1) .EQ. INO1 ) THEN
                TROUV1 = 1
                GOTO 53
             END IF
             IF ( ZI(JFAC2+ IM-1) .EQ. INO1 ) THEN
                TROUV1 = 2
                GOTO 53
             END IF
52        CONTINUE
C
53        CONTINUE
          IF (( D .LT. DMIN ).AND.(TROUV1.EQ.TROUV2)) THEN
             DMIN   = D
             NUNO1  = INO1
             J1     = I1
          ENDIF
50      CONTINUE
C
        IF (J1.EQ.0) CALL U2MESK('F','MODELISA6_3',1,NOMNO2)
C
        IF ( ZI(IDLINV+J1-1).EQ. 0 ) THEN
            ZI(IDLOU3+I2-1) = NUNO1
            ZI(IDLOU4+I2-1) = NUNO2
            ZI(IDLINV+J1-1) = NUNO2
        ELSE
            CALL JENUNO ( JEXNUM(NOMNOE,NUNO1), NOMNO1)
            CALL JENUNO ( JEXNUM(NOMNOE,NUNO2), NOMNO2)
            CALL JENUNO ( JEXNUM(NOMNOE,ZI(IDLINV+J1-1)), NOMNO3)
           VALK (1) = NOMNO1
           VALK (2) = NOMNO2
           VALK (3) = NOMNO3
            CALL U2MESG('F', 'MODELISA8_77',3,VALK,0,0,0,0.D0)
        ENDIF
C
40    CONTINUE
C
C --- VERIFICATION DE LA COHERENCE DES COUPLES FORMES D'UNE PART
C --- PAR LISOU1 ET LISOU2 ET D'AUTRE-PART DES COUPLES 'INVERSES'
C --- FORMES PAR LISOU3 ET LISOU4
C
      DO 60 I = 1, LONLIS
        IEXCOR = 0
        DO 70 J = 1, LONLIS
           IF(ZI(IDLOU1+I-1).EQ.ZI(IDLOU3+J-1)) THEN
              IEXCOR = 1
              IF(ZI(IDLOU2+I-1).NE.ZI(IDLOU4+J-1)) THEN
                 CALL JENUNO ( JEXNUM(NOMNOE,ZI(IDLOU1+I-1)), NOMNO1)
                 CALL JENUNO ( JEXNUM(NOMNOE,ZI(IDLOU2+I-1)), NOMNO2)
                 CALL JENUNO ( JEXNUM(NOMNOE,ZI(IDLOU4+J-1)), NOMNO3)
           VALK (1) = NOMNO1
           VALK (2) = NOMNO2
           VALK (3) = NOMNO3
                 CALL U2MESG('F', 'MODELISA8_79',3,VALK,0,0,0,0.D0)
              ENDIF
           ENDIF
70      CONTINUE
C
        IF ( IEXCOR .EQ. 0 ) THEN
           CALL JENUNO ( JEXNUM(NOMNOE,ZI(IDLOU1+I-1)), NOMNO1)
           VALK (1) = NOMNO1
           VALK (2) = ' '
           VALK (3) = ' '
           CALL U2MESG('F', 'MODELISA8_80',3,VALK,0,0,0,0.D0)
        ENDIF
C
60    CONTINUE
C
C --- MENAGE
C
      CALL JEDETR ('&&PACOA1.LISOU3')
      CALL JEDETR ('&&PACOA1.LISOU4')
      CALL JEDETR ('&&PACOA1.LISINV')
C
      CALL JEDEMA()
      END
