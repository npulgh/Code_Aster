      SUBROUTINE XPOAJM(MA2,JTYPM2,ITYPSE,JCNSE,IM,N,NDIME,PREFNO,
     &                  JDIRNO,NNM,INM,INMTOT,NBMAC,HE,JNIVGR,IAGMA,
     &                  NGRM,JDIRGR)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 04/09/2007   AUTEUR DURAND C.DURAND 
C ======================================================================
C COPYRIGHT (C) 1991 - 2007  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE GENIAUT S.GENIAUT

      IMPLICIT NONE

      CHARACTER*2   PREFNO(4)
      CHARACTER*8   MA2
      INTEGER       JTYPM2,ITYPSE,NNM,INM,INMTOT,NBMAC,JDIRGR
      INTEGER       NDIME,JCNSE,IM,N,JDIRNO,HE,JNIVGR,IAGMA,NGRM

C
C   ON AJOUTE UNE NOUVELLE MAILLE AU NOUVEAU MAILLAGE X-FEM
C
C   IN
C     ITYPSE : NUMEROS DU TYPE DE SOUS-ELEMENT
C     JCNSE  : ADRESSE DE LA CONNECTIVITÉ LOCALE DES SOUS-ELEMENTS
C     IM     : POSITION LOCALE DU SOUS-ELEMENT
C     N      : NOMBRE DE NOEUDS DE LA MAILLE PARENT
C     NDIME  : DIMENSION TOPOLOGIQUE DE LA MAILLE
C     PREFNO : PREFERENCES POUR LE NOMAGE DES NOUVELLES ENTITES
C     JDIRNO : ADRESSE DU TABLEAU DIRNO LOCAL
C     NNM    : NOMBRE DE NOUVELLES MAILLES A CREER SUR LA MAILLE PARENT
C     NBMAC  : NOMBRE DE MAILLES CLASSIQUES DU MAILLAGE FISSURE
C     HE     : VALEUR DE LA FONCTION HEAVISIDE SUR LE SOUS-ELEMENTS
C     JNIVGR : ADRESSE DU VECTEUR DE REMPLISSAGE DES GROUP_MA DE MAXFEM
C     IAGMA  : ADRESSE DES NUMEROS DANS MA1 DES GROUP_MA CONTENANT IMA
C     NGRM   : NOMBRE DE GROUP_MA CONTENANT IMA
C     JDIRGR : ADRESSE DU TABLEAU D'INDIRECTION GLOBAL DES GROUP_MA
C
C   OUT
C     MA2    : NOM DU MAILLAGE FISSURE
C     JTYPM2 : ADRESSE DE L'OBJET .TYPMAIL DU MAILLAGE FISSURE
C     INM    : COMPTEUR LOCAL DU NOMBRE DE NOUVELLES MAILLES CREEES
C     INMTOT : COMPTEUR TOTAL DU NOMBRE DE NOUVELLES MAILLES CREEES



C -------------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ----------------
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      CHARACTER*32 JEXNOM,JEXNUM,JEXATR
C---------------- FIN COMMUNS NORMALISES  JEVEUX  ----------------------


      INTEGER       IACON2,J,NNOSE,INO1,INO2,NDOUBL,IG1,IG2,IAGMA2,I
      CHARACTER*6   CHN
      CHARACTER*8   VALK(2),K8B
      CHARACTER*19  MA2CON
      DATA          VALK /'MAILLES','XPOAJM'/
      
      
      CALL JEMARQ()

      IF (INMTOT.GE.999999) CALL U2MESK('F','XFEM_8',1,VALK)

      INM    = INM    + 1
      INMTOT = INMTOT + 1
      IF (INM.GT.NNM) CALL U2MESK('F','XFEM_9',2,VALK)
      CALL CODENT(INMTOT,'G',CHN)

      CALL JECROC(JEXNOM(MA2//'.NOMMAI',PREFNO(4)//CHN))        

      ZI(JTYPM2-1+NBMAC + INMTOT) = ITYPSE

C     NBNOSE : NOMBRE DE NOEUDS D'UN SOUS-ELEMENT
      NNOSE = NDIME +1
      MA2CON = MA2//'.CONNEX'
      CALL JEECRA(JEXNUM(MA2CON,NBMAC+INMTOT),'LONMAX',NNOSE,K8B)
      CALL JEVEUO(JEXNUM(MA2CON,NBMAC+INMTOT),'E',IACON2)

C     ----------------------------------------------------------------
C     ON INCREMENTE LES GROUP_MA
C     BOUCLE SUR LES GROUP_MA CONTENANT LA MAILLE IMA
      DO 110 I=1,NGRM
C       NUMEROS DU GROUP_MA DANS MA1 ET MA2
        IG1 = ZI(IAGMA-1+I)
        IG2 = ZI(JDIRGR-1+IG1)
C       SI CE GROUP_MA N'EXISTE PAS DANS MA2, ON PASSE AU SUIVANT
        IF (IG2.EQ.0) GOTO 110
        CALL JEVEUO(JEXNUM(MA2//'.GROUPEMA',IG2),'E',IAGMA2)
C       NIVEAU DE REMPLISSAGE DU GROUP_MA
        ZI(JNIVGR-1+IG2) = ZI(JNIVGR-1+IG2) + 1
        ZI(IAGMA2-1+ ZI(JNIVGR-1+IG2)) = NBMAC + INMTOT
 110  CONTINUE
C     ----------------------------------------------------------------

      DO 410 J=1,NNOSE
        INO1 = ZI(JCNSE-1+NNOSE*(IM-1)+J)
        IF (INO1.GT.1000) THEN
           INO1 = INO1 - 1000 + N
        ENDIF

C       DOUBLE ?
        NDOUBL = ZI(JDIRNO-1+3*(INO1-1)+1)

C       POUR LES DOUBLES :
C       CHOIX DU NOEUD "-" OU "+" SUIVANT LE SIGNE DE HE   
        IF (NDOUBL.EQ.2) THEN
          IF (HE.EQ.-1) INO2 = ZI(JDIRNO-1+3*(INO1-1)+2)
          IF (HE.EQ.1)  INO2 = ZI(JDIRNO-1+3*(INO1-1)+3)
          CALL ASSERT(HE.EQ.1.OR.HE.EQ.-1)
        ELSEIF (NDOUBL.EQ.1) THEN
          INO2 = ZI(JDIRNO-1+3*(INO1-1)+2)
        ENDIF

        ZI(IACON2-1+J)=INO2
 410  CONTINUE

      CALL JEDEMA()
      END
