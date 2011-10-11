      SUBROUTINE FONNOE ( RESU, NOMA, NOMOBJ, TYPFON, NBNOFF)
      IMPLICIT   NONE
      CHARACTER*6         TYPFON, NOMOBJ
      CHARACTER*8         RESU, NOMA
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 10/10/2011   AUTEUR MACOCCO K.MACOCCO 
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
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.         
C ======================================================================
C-----------------------------------------------------------------------
C FONCTION REALISEE:
C
C     CONSTRUCTION DU FOND DE FISSURE A PARTIR DE NOEUDS OU DE GROUPES 
C     DE NOEUDS RENSEIGNES DANS DEFI_FOND_FISS
C
C     ENTREES:
C        RESU       : NOM DU CONCEPT RESULTAT DE L'OPERATEUR
C        NOMA       : NOM DU MAILLAGE
C        NOMOBJ     : NOM DU VECTEUR CONTENANT LES DONNEES RELATIVES
C                     AUX NOEUDS
C        TYPFON     : TYPE DE FOND IL PEUT VALOIR OUVERT/FERME/INF/SUP
C     SORTIES:
C        NBNOFF     : NOMBRE DE NOEUDS EN FOND DE FISSURE
C-----------------------------------------------------------------------
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
C
      INTEGER            ZI
      COMMON  / IVARJE / ZI(1)
      REAL*8             ZR
      COMMON  / RVARJE / ZR(1)
      COMPLEX*16         ZC
      COMMON  / CVARJE / ZC(1)
      LOGICAL            ZL
      COMMON  / LVARJE / ZL(1)
      CHARACTER*8        ZK8
      CHARACTER*16                ZK16
      CHARACTER*24                          ZK24
      CHARACTER*32                                    ZK32
      CHARACTER*80                                              ZK80
      COMMON  / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) , ZK80(1)
      CHARACTER*32       JEXNUM, JEXNOM, JEXATR
C
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------
      INTEGER       JDRVLC, JCNCIN, JNOE1, JNOE2, JADR
      INTEGER       IATYMA, IBID, JTYP
      INTEGER       K,ITYP,J
      INTEGER       NCI, NUMA, NUMB
      INTEGER       JJJ,INO,IT,NBNOFF,NBMA,NBMB,NA,NB,ADRA,ADRB
      INTEGER       IRET
      CHARACTER*6   NOMPRO
      CHARACTER*8   K8B, NOEUD, TYPE,MOTCLE(2),TYPMCL(2),TYPMP,VALK(8)
      CHARACTER*8   TYPM
      CHARACTER*24  NOEORD,TRAV
      CHARACTER*24  NCNCIN,ENTREE,OBTRAV
      LOGICAL       LFON,TEST,ISMALI
C DEB-------------------------------------------------------------------
      CALL JEMARQ()
      NOMPRO = 'FONNOE'
C      
C ---  TYPE DE FOND TRAITE
C      -----------------------------------
C      
      LFON = .FALSE.
      IF(TYPFON.EQ.'INF') THEN
         NOEORD = RESU//'.FOND_INF.NOEU'
         LFON = .TRUE.
      ELSEIF(TYPFON.EQ.'SUP') THEN
         NOEORD = RESU//'.FOND_SUP.NOEU'
         LFON = .TRUE.
      ELSE
         NOEORD = RESU//'.FOND.NOEU'
      ENDIF
C
C ---  RECUPERATIONS RELATIVES AU MAILLAGE
C      -----------------------------------
C      
      CALL JEVEUO(NOMA//'.TYPMAIL','L',IATYMA)

      NCNCIN = '&&'//NOMPRO//'.CONNECINVERSE'
      CALL JEEXIN ( NCNCIN, NCI )
      IF (NCI .EQ. 0) THEN
        CALL CNCINV (NOMA, IBID, 0, 'V', NCNCIN )
        CALL JEVEUO ( JEXATR(NCNCIN,'LONCUM'), 'L', JDRVLC )
        CALL JEVEUO ( JEXNUM(NCNCIN,1)       , 'L', JCNCIN )      
      ENDIF

C
C --- CALCUL DU NOMBRE DE NOEUDS
      MOTCLE(1) = 'GROUP_NO'
      MOTCLE(2) = 'NOEUD'
      TYPMCL(1) = 'GROUP_NO'
      TYPMCL(2) = 'NOEUD'      
      TRAV = '&&'//NOMPRO//'.NOEUD'
      CALL RELIEM ( ' ', NOMA, 'NO_NOEUD', 'FOND_FISS', 1, 2,
     &                                  MOTCLE, TYPMCL, TRAV, NBNOFF )
      OBTRAV = '&&'//NOMOBJ//'.NOEUD'
      CALL JEEXIN ( OBTRAV, IRET )
      IF (IRET.NE.0) THEN
        CALL JEVEUO (OBTRAV,'L',JJJ)
        ENTREE = NOMA//'.NOMNOE'
      ELSE
        OBTRAV = '&&'//NOMOBJ//'.GROUP_NO'
        CALL JEVEUO (OBTRAV,'L',JJJ)
        ENTREE = NOMA//'.GROUPENO'
        CALL JEVEUO (JEXNOM(ENTREE,ZK8(JJJ)),'L',JADR)
      ENDIF
      
      TYPMP ='        '
      IT = 1
      DO 210 INO = 1 , NBNOFF-1
C       NUMERO DU NOEUD INO ET INO+1
        IF (IRET.NE.0) THEN
          CALL JENONU (JEXNOM(ENTREE,ZK8(JJJ-1 + INO  )),NA)
          CALL JENONU (JEXNOM(ENTREE,ZK8(JJJ-1 + INO+1)),NB)
        ELSE
          NA = ZI(JADR-1 + INO)
          NB = ZI(JADR-1 + INO+1)            
        ENDIF
C       NOMBRE DE MAILLES CONNECTEES AU NOEUD INO ET INO+1
        NBMA = ZI(JDRVLC-1 + NA+1) - ZI(JDRVLC-1 + NA)
        NBMB = ZI(JDRVLC-1 + NB+1) - ZI(JDRVLC-1 + NB)
C       NUMERO DE LA PREMIERE MAILLE CONNECTEE AU NOEUD INO ET INO+1
        ADRA = ZI(JDRVLC-1 + NA)
        ADRB = ZI(JDRVLC-1 + NB)
C       RECHERCHE DES MAILLES COMMUNES
        DO 212 J = 1,NBMA
C         POUR LA J IEME MAILLE RELATIVE AU NOEUD INO
          NUMA = ZI(JCNCIN-1 + ADRA+J-1)
          DO 214 K = 1,NBMB
C           POUR LA K IEME MAILLE RELATIVE AU NOEUD INO+1
            NUMB = ZI(JCNCIN-1 + ADRB+K-1)
            ITYP = IATYMA-1+NUMB
C           RECUPERATION DE LA KIEME MAILLE RELATIVE AU NOEUD INO+1
            CALL JENUNO(JEXNUM('&CATA.TM.NOMTM',ZI(ITYP)),
     &                        TYPE)
C           RECUPERATION DE LA K IEME MAILLE RELATIVE AU NOEUD INO+1
            IF (TYPE(1:3).EQ.'SEG ') THEN
              IF ((IT.GT.1) .AND.
     &            (TYPE.NE.TYPMP)) THEN
                CALL U2MESS('F','RUPTURE0_60')
              ENDIF      
              TYPMP = TYPE
              IT = IT + 1
C             DANS LE CAS LFON (INF ET SUP) IL EST NECESSAIRE D'AVOIR
C             DES MAILLES SEG SI CE N'EST PAS LE CAS ON ECHOUE
              IF(LFON .AND. NUMA.EQ.NUMB) GOTO 216
            ENDIF
C           DANS LE CAS (OUVERT OU FERME) IL N'EST NECESSAIRE PAS 
C           D'AVOIR DES MAILLES SEG
            IF (.NOT.LFON .AND. NUMA .EQ. NUMB ) GOTO 216
 214      CONTINUE
 212    CONTINUE
        CALL U2MESS('F','RUPTURE0_66')
 216    CONTINUE
        IF (TYPMP.EQ.'        ') THEN
          NUMA = ZI(JCNCIN-1 + ADRA)
          ITYP = IATYMA-1+NUMA
          CALL JENUNO(JEXNUM('&CATA.TM.NOMTM',ZI(ITYP)),TYPE)
          TEST = ISMALI(TYPE)
          IF (TEST) THEN
            TYPMP = 'NOE2'
          ELSE
            TYPMP = 'NOE3'
          ENDIF
        ENDIF
        CALL JEDETR(TRAV)
 210  CONTINUE
C
C       CONSTRUCTION DES NOEUDS DU FOND SI "NOEUD" RENSEIGNE
C     -------------------------------------------------------------
C
      CALL WKVECT(NOEORD,'G V K8',NBNOFF,JNOE1)
      IF (IRET.NE.0) THEN
        DO 213 INO = 1 , NBNOFF
          ZK8(JNOE1-1 + INO) = ZK8(JJJ-1 + INO)
 213    CONTINUE
        
      ELSE          
          CALL JEVEUO (JEXNOM(ENTREE,ZK8(JJJ)),'L',JADR)
          DO 2223 INO = 1 , NBNOFF
            CALL JENUNO(JEXNUM(NOMA//'.NOMNOE',ZI(JADR-1 + INO)),
     &                  NOEUD)
            ZK8(JNOE1-1 + INO) = NOEUD
 2223     CONTINUE
       ENDIF
       
C
C
C     CONSTRUCTION DU TYPE DE MAILLES DES NOEUDS DU FOND DE FISSURE
C     -------------------------------------------------------------
C
      IF (NBNOFF.EQ.1) TYPMP = '        '
      CALL JEEXIN ( RESU//'.FOND.TYPE', IRET )
      IF (IRET.EQ.0) THEN
        CALL WKVECT(RESU//'.FOND.TYPE','G V K8',1,JNOE2)
        ZK8(JNOE2) = TYPMP
      ELSE
        CALL JEVEUO( RESU//'.FOND.TYPE','L',JTYP)
        TYPM=ZK8(JTYP)
        IF (TYPMP.NE.TYPM) THEN
          VALK(1) = TYPMP
          VALK(2) = TYPM
          CALL U2MESK('F','RUPTURE0_68',2,VALK)  
        ENDIF   
      ENDIF
      CALL JELIRA (NOEORD , 'LONUTI', NBNOFF, K8B)
      
      CALL JEDETR(NCNCIN)
      CALL JEDEMA()
      END
