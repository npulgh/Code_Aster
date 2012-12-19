      SUBROUTINE XPOAJM(MAXFEM,JTYPM2,ITYPSE,JCNSE,IM,N,NNOSE,
     &                  PREFNO,JDIRNO,NNM,INM,INMTOT,NBMAC,HE,JNIVGR,
     &                  IAGMA,NGRM,JDIRGR,OPMAIL,NFISS,NDIM,NDIME,
     &                  JCONX1,JCONX2,JCONQ1,JCONQ2,IMA,IAD1,NNN,INN,
     &                  INNTOT,NBNOC,NBNOFI,INOFI,IACOO1,
     &                  IACOO2,IAD9,NINTER,IAINC,
     &                  ELREFP,JLSN,JLST,TYPMA,IGEOM,JFISNO,CONTAC,
     &                  CMP,NBCMP,NFH,NFE,DDLC,JCNSV1,JCNSV2,JCNSL2)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 19/12/2012   AUTEUR PELLET J.PELLET 
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
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C RESPONSABLE GENIAUT S.GENIAUT
C TOLE CRP_21 CRS_1404

      IMPLICIT NONE

      INCLUDE 'jeveux.h'

      CHARACTER*32 JEXNUM,JEXNOM
      INTEGER       NFISS,NNN,INN,INNTOT,NDIM,JCONX1,JCONX2
      INTEGER       JCONQ1,JCONQ2,IACOO1,IACOO2,JCNSL2
      INTEGER       NBNOC,NBNOFI,INOFI
      INTEGER       IMA,IAD1,JLSN,JLST,IGEOM,NDIME,IAD9
      INTEGER       JFISNO,CMP(*),NBCMP,NFH,NFE,DDLC,JCNSV1,JCNSV2
      INTEGER       NINTER,IAINC,CONTAC
      CHARACTER*2   PREFNO(4)
      CHARACTER*8   MAXFEM,ELREFP,TYPMA
      INTEGER       JTYPM2,ITYPSE,NNM,INM,INMTOT,NBMAC,JDIRGR
      INTEGER       JCNSE,IM,N,NNOSE,JDIRNO,HE(NFISS),JNIVGR,IAGMA,NGRM
      LOGICAL       OPMAIL

C
C   ON AJOUTE UNE NOUVELLE MAILLE AU NOUVEAU MAILLAGE X-FEM
C
C   IN

C     ITYPSE : NUMEROS DU TYPE DE SOUS-ELEMENT
C     JCNSE  : ADRESSE DE LA CONNECTIVIT� LOCALE DES SOUS-ELEMENTS
C     IM     : POSITION LOCALE DU SOUS-ELEMENT
C     N      : NOMBRE DE NOEUDS DE LA MAILLE PARENT
C     NNOSE  : NOMBRE DE NOEUDS DU SOUS �L�MENT
C     PREFNO : PREFERENCES POUR LE NOMAGE DES NOUVELLES ENTITES
C     JDIRNO : ADRESSE DU TABLEAU DIRNO LOCAL
C     NNM    : NOMBRE DE NOUVELLES MAILLES A CREER SUR LA MAILLE PARENT
C     NBMAC  : NOMBRE DE MAILLES CLASSIQUES DU MAILLAGE FISSURE
C     HE     : VALEURS DE(S) FONCTION(S) HEAVISIDE SUR LE SOUS �L�MENT
C     JNIVGR : ADRESSE DU VECTEUR DE REMPLISSAGE DES GROUP_MA DE MAXFEM
C     IAGMA  : ADRESSE DES NUMEROS DANS MA1 DES GROUP_MA CONTENANT IMA
C     NGRM   : NOMBRE DE GROUP_MA CONTENANT IMA
C     JDIRGR : ADRESSE DU TABLEAU D'INDIRECTION GLOBAL DES GROUP_MA
C     OPMAIL : .TRUE. SI POST_MAIL_XFEM
C     NFISS  : NOMBRE DE FISSURES "VUES" PAR LA MAILLE
C     NDIM   : DIMENSION DU MAILLAGE
C     NDIME  : DIMENSION TOPOLOGIQUE DE LA MAILLE PARENT
C     JCONX1 :�ADRESSE DE LA CONNECTIVITE DU MAILLAGE SAIN
C     JCONX2 : LONGUEUR CUMULEE DE LA CONNECTIVITE DU MAILLAGE SAIN
C     JCONQ1 : ADRESSE DE LA CONNECTIVITE DU MAILLAGE DU MOD�LE
C     JCONQ2 : LONGUEUR CUMULEE DE LA CONNECTIVITE DU MAILLAGE DU MOD�LE
C     IMA    : NUMERO DE MAILLE COURANTE PARENT
C     IAD1   : POINTEUR DES COORDON�ES DES POINTS D'INTERSECTION
C     NNN    : NOMBRE DE NOUVEAU NOEUDS A CREER SUR L'�L�MENT PARENT
C     NBNOC  : NOMBRE DE NOEUDS CLASSIQUES DU MAILLAGE FISSURE
C     IACOO1 : ADRESSE DES COORDONNES DES NOEUDS DU MAILLAGE SAIN
C     IACOO2 :  ADRESSE DES COORDONNES DES NOEUDS DU MAILLAGE FISSURE
C     IAD9   : POINTEUR DES COOR DES POINTS MILIEUX DES SE QUADRATIQUES
C     NINTER : NOMBRE D'ARETES INTERSECT�S DE L'ELEMENT PARENT
C     IAINC  : ADRESSE DE TOPOFAC.AI DE L'ELEMENT PARENT
C     ELREFP : �L�MENT DE R�F�RENCE PARENT
C     JLSN   : ADRESSE DU CHAM_NO_S DE LA LEVEL NORMALE
C     JLST   : ADRESSE DU CHAM_NO_S DE LA LEVEL TANGENTE
C     TYPMA  : TYPE DE LA MAILLE PARENTE
C     IGEOM  : COORDONN�ES DES NOEUDS DE L'�L�MENT PARENT
C     JFISNO : POINTEUR DE FISSNO DANS L'�L�MENT PARENT
C     CMP    : POSITION DES DDLS DE DEPL X-FEM DANS LE CHAMP_NO DE DEPL1
C     NBCMP  : NOMBRE DE COMPOSANTES DU CHAMP_NO DE DEPL1
C     NFH    : NOMBRE DE FONCTIONS HEAVISIDE (PAR NOEUD)
C     NFE    : NOMBRE DE FONCTIONS SINGULI�RES D'ENRICHISSEMENT (1 A 4)
C     DDLC   : NOMBRE DE DDL DE CONTACT DE L'�L�MENT PARENT
C     JCNSV1 : ADRESSE DU CNSV DU CHAM_NO DE DEPLACEMENT 1
C
C   OUT
C     MAXFEM : NOM DU MAILLAGE FISSURE
C     JTYPM2 : ADRESSE DE L'OBJET .TYPMAIL DU MAILLAGE FISSURE
C     INM    : COMPTEUR LOCAL DU NOMBRE DE NOUVELLES MAILLES CREEES
C     INMTOT : COMPTEUR TOTAL DU NOMBRE DE NOUVELLES MAILLES CREEES
C     INN    : COMPTEUR LOCAL DU NOMBRE DE NOUVEAUX NOEUDS CREEES
C     INNTOT : COMPTEUR TOTAL DU NOMBRE DE NOUVEAUX NOEUDS CREEES
C     NBNOFI : NOMBRE DE NOEUDS SITUES SUR LA FISSURE
C     INOFI  : LISTE DES NOEUDS SITUES SUR LA FISSURE
C     NBNOLA : NOMBRE DE NOEUDS SITUES SUR LA FISSURE AVEC DES LAGS
C     INOLA  : LISTE DES NOEUDS SITUES SUR LA FISSURE AVEC DES LAGS
C     JCNSV2 : ADRESSE DU CNSV DU CHAM_NO DE DEPLACEMENT 2
C     JCNSL2 : ADRESSE DU CNSL DU CHAM_NO DE DEPLACEMENT 2

C
      INTEGER       IACON2,J,INO,IG1,IG2,IAGMA2,I
      INTEGER       IFISS,IAD
      REAL*8        LSN(NFISS),LST(NFISS),CO(3)
      CHARACTER*6   CHN
      CHARACTER*8   VALK(2),K8B
      CHARACTER*19  MA2CON
      LOGICAL       LNOEUD
      DATA          VALK /'MAILLES','XPOAJM'/
C
C     ------------------------------------------------------------------

      CALL JEMARQ()

      IF (INMTOT.GE.999999) CALL U2MESK('F','XFEM_8',1,VALK)

      IF (OPMAIL) THEN
        INM    = INM    + 1
        INMTOT = INMTOT + 1
        CALL ASSERT(INM.LE.NNM)
        CALL CODENT(INMTOT,'G',CHN)
        CALL JECROC(JEXNOM(MAXFEM//'.NOMMAI',PREFNO(4)//CHN))
        ZI(JTYPM2-1+NBMAC + INMTOT) = ITYPSE
        MA2CON = MAXFEM//'.CONNEX'
        CALL JEECRA(JEXNUM(MA2CON,NBMAC+INMTOT),'LONMAX',NNOSE,K8B)
        CALL JEVEUO(JEXNUM(MA2CON,NBMAC+INMTOT),'E',IACON2)

C       ON INCREMENTE LES GROUP_MA
C       BOUCLE SUR LES GROUP_MA CONTENANT LA MAILLE IMA
        DO 110 I=1,NGRM
C         NUMEROS DU GROUP_MA DANS MA1 ET MA2
          IG1 = ZI(IAGMA-1+I)
          IG2 = ZI(JDIRGR-1+IG1)
C         SI CE GROUP_MA N'EXISTE PAS DANS MA2, ON PASSE AU SUIVANT
          IF (IG2.EQ.0) GOTO 110
          CALL JEVEUO(JEXNUM(MAXFEM//'.GROUPEMA',IG2),'E',IAGMA2)
C         NIVEAU DE REMPLISSAGE DU GROUP_MA
          ZI(JNIVGR-1+IG2) = ZI(JNIVGR-1+IG2) + 1
          ZI(IAGMA2-1+ ZI(JNIVGR-1+IG2)) = NBMAC + INMTOT
 110    CONTINUE
      ENDIF
      DO 410 J=1,NNOSE
        INO = ZI(JCNSE-1+NNOSE*(IM-1)+J)
C --- ON REGARDE SI LE NOEUD APPARTIENT � LA LISTE
        DO 420 I = 1, INN
          IF (ZI(JDIRNO-1+(2+NFISS)*(I-1)+1).EQ.INO) THEN
            LNOEUD = .TRUE.
            DO 430 IFISS = 1,NFISS
              LNOEUD = LNOEUD.AND.
     &          ZI(JDIRNO-1+(2+NFISS)*(I-1)+2+IFISS).EQ.HE(IFISS)
 430        CONTINUE
C --- IL APPARTIENT A LA LISTE, ON L'ATTACHE � LA MAILLE
            IF (LNOEUD) THEN
              IF (OPMAIL) ZI(IACON2-1+J)=ZI(JDIRNO-1+(2+NFISS)*(I-1)+2)
              GOTO 410
            ENDIF
          ENDIF
 420    CONTINUE
        IF (INO.LT.1000) THEN
          IAD = IACOO1
        ELSEIF (INO.GT.1000.AND.INO.LT.2000) THEN
          IAD = IAD1+NDIM*(INO-1001)
        ELSEIF (INO.GT.2000.AND.INO.LT.3000) THEN
          IAD = IAD9+NDIM*(INO-2001)
        ELSEIF (INO.GT.3000) THEN
          IAD = IAD9+NDIM*(INO-3001)
        ENDIF
        IF (OPMAIL) THEN
C --- IL N'APPARTIENT PAS A LA LISTE, ON LE CREE AVANT DE L'ATTACHER
          CALL XPOLSN(ELREFP,INO,N,JLSN,JLST,IMA,IAD,IGEOM,NFISS,
     &                  NDIME,NDIM,JCONX1,JCONX2,CO,LSN,LST)
          CALL XPOAJN(MAXFEM,INO,LSN,JDIRNO,PREFNO,NFISS,HE,
     &                  NNN,INN,INNTOT,NBNOC,NBNOFI,INOFI,
     &                  CO,IACOO2)
          ZI(IACON2-1+J)= ZI(JDIRNO-1+(2+NFISS)*(INN-1)+2)
        ELSE
C --- IL N'APPARTIENT PAS A LA LISTE, ON CALCULE SON D�PLACEMENT
          CALL XPOLSN(ELREFP,INO,N,JLSN,JLST,IMA,IAD,IGEOM,NFISS,
     &                NDIME,NDIM,JCONQ1,JCONQ2,CO,LSN,LST)
          CALL XPOAJD(ELREFP,INO,N,LSN,LST,NINTER,
     &                IAINC,TYPMA,CO,IGEOM,JDIRNO,NFISS,JFISNO,
     &                HE,NDIME,NDIM,CMP,NBCMP,NFH,NFE,DDLC,IMA,JCONQ1,
     &                JCONQ2,JCNSV1,JCNSV2,JCNSL2,NBNOC,INNTOT,
     &                INN,NNN,CONTAC)
        ENDIF

 410  CONTINUE

      CALL JEDEMA()
      END
